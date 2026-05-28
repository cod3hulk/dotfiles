/**
 * Pifile Extension
 *
 * Reads one or more Pifiles (declarative package lists) and ensures all listed
 * packages are installed — like Homebrew's `brew bundle`.
 *
 * Pifile format (plain text, one package per line):
 *   # comments and blank lines are ignored
 *   npm:pi-skillful
 *   npm:@scope/package
 *   git:github.com/user/repo@v1
 *
 * Pifile locations are configured in ~/.pi/agent/pifile.json:
 *   {
 *     "pifiles": [
 *       "~/dotfiles/pi/shared/Pifile",
 *       "~/dotfiles/pi/machines/JNP073W6W6/Pifile"
 *     ],
 *     "checkOnStartup": true
 *   }
 *
 * Defaults (used if no pifile.json exists):
 *   ~/.pi/agent/Pifile       (user-global)
 *   .pi/Pifile               (project-local, if present)
 *
 * Commands:
 *   /pifile          — show status TUI, install missing interactively
 *   /pifile install  — install all missing packages without prompting
 *   /pifile check    — print status without installing
 */

import { exec } from "node:child_process";
import { existsSync, readFileSync } from "node:fs";
import { homedir, hostname } from "node:os";
import { join, resolve } from "node:path";
import { promisify } from "node:util";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { BorderedLoader, DynamicBorder, getAgentDir } from "@earendil-works/pi-coding-agent";
import { Container, type SelectItem, SelectList, Spacer, Text } from "@earendil-works/pi-tui";

const execAsync = promisify(exec);

// ─── Types ────────────────────────────────────────────────────────────────────

interface PifileConfig {
	pifiles?: string[];
	checkOnStartup?: boolean;
}

interface PackageEntry {
	source: string;       // e.g. "npm:pi-skillful"
	installed: boolean;
	pifile: string;       // which Pifile declared it
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

function expandHome(p: string): string {
	return p.startsWith("~/") ? join(homedir(), p.slice(2)) : p;
}

function loadConfig(): PifileConfig {
	const configPath = join(getAgentDir(), "pifile.json");
	if (!existsSync(configPath)) return {};
	try {
		return JSON.parse(readFileSync(configPath, "utf-8")) as PifileConfig;
	} catch {
		return {};
	}
}

function getPifilePaths(cwd: string, config: PifileConfig): string[] {
	if (config.pifiles && config.pifiles.length > 0) {
		return config.pifiles.map(expandHome).map((p) => resolve(p));
	}
	// Defaults
	const paths: string[] = [join(getAgentDir(), "Pifile")];
	const projectPifile = join(cwd, ".pi", "Pifile");
	if (existsSync(projectPifile)) paths.push(projectPifile);
	return paths;
}

function parsePifile(filePath: string): string[] {
	if (!existsSync(filePath)) return [];
	return readFileSync(filePath, "utf-8")
		.split("\n")
		.map((l) => l.trim())
		.filter((l) => l.length > 0 && !l.startsWith("#"));
}

/** Normalise a package source string for comparison (strip trailing whitespace, lowercase npm names) */
function normalise(source: string): string {
	return source.trim().toLowerCase();
}

function getInstalledSources(): string[] {
	const settingsPath = join(getAgentDir(), "settings.json");
	try {
		const settings = JSON.parse(readFileSync(settingsPath, "utf-8")) as {
			packages?: (string | { source: string })[];
		};
		return (settings.packages ?? []).map((p) =>
			typeof p === "string" ? p : p.source,
		);
	} catch {
		return [];
	}
}

function buildEntries(cwd: string, config: PifileConfig): PackageEntry[] {
	const pifilePaths = getPifilePaths(cwd, config);
	const installed = getInstalledSources().map(normalise);

	const seen = new Set<string>();
	const entries: PackageEntry[] = [];

	for (const pifile of pifilePaths) {
		for (const source of parsePifile(pifile)) {
			const key = normalise(source);
			if (seen.has(key)) continue;
			seen.add(key);
			entries.push({ source, installed: installed.includes(key), pifile });
		}
	}
	return entries;
}

function shortPifileName(filePath: string): string {
	const home = homedir();
	return filePath.startsWith(home) ? `~${filePath.slice(home.length)}` : filePath;
}

function piBin(): string {
	return "/opt/homebrew/bin/pi";
}

// ─── Extension ────────────────────────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
	// ── Session start: optional background check ────────────────────────────────
	pi.on("session_start", async (_event, ctx) => {
		const config = loadConfig();
		if (!config.checkOnStartup) return;

		const entries = buildEntries(ctx.cwd, config);
		const missing = entries.filter((e) => !e.installed);
		if (missing.length > 0) {
			ctx.ui.setStatus(
				"pifile",
				ctx.ui.theme.fg("warning", `⚠ pifile: ${missing.length} package${missing.length > 1 ? "s" : ""} missing — run /pifile`),
			);
		}
	});

	// ── /pifile command ─────────────────────────────────────────────────────────
	pi.registerCommand("pifile", {
		description: "Sync pi packages declared in your Pifile(s)",
		handler: async (args, ctx) => {
			if (!ctx.hasUI && args?.trim() !== "check" && args?.trim() !== "install") {
				ctx.ui.notify("pifile requires interactive mode. Use /pifile check or /pifile install.", "error");
				return;
			}

			const config = loadConfig();
			const entries = buildEntries(ctx.cwd, config);

			if (entries.length === 0) {
				ctx.ui.notify("No Pifiles found. Create ~/.pi/agent/Pifile or configure ~/.pi/agent/pifile.json", "warning");
				return;
			}

			const missing = entries.filter((e) => !e.installed);
			const subcommand = args?.trim() ?? "";

			// ── check: just print status ──────────────────────────────────────
			if (subcommand === "check") {
				const lines = entries.map(
					(e) => `${e.installed ? "✓" : "✗"} ${e.source}  (${shortPifileName(e.pifile)})`,
				);
				const summary = missing.length === 0
					? `All ${entries.length} packages installed.`
					: `${missing.length} of ${entries.length} packages missing.`;
				ctx.ui.notify([...lines, "", summary].join("\n"), missing.length > 0 ? "warning" : "info");
				return;
			}

			// ── install: non-interactive bulk install ─────────────────────────
			if (subcommand === "install") {
				if (missing.length === 0) {
					ctx.ui.notify("All packages already installed.", "info");
					return;
				}
				await installPackages(missing.map((e) => e.source), ctx);
				return;
			}

			// ── interactive TUI ───────────────────────────────────────────────
			const action = await ctx.ui.custom<"install" | "cancel">((tui, theme, _kb, done) => {
				const container = new Container();
				container.addChild(new DynamicBorder((s: string) => theme.fg("accent", s)));

				// Header
				const pifileCount = new Set(entries.map((e) => e.pifile)).size;
				container.addChild(
					new Text(
						`${theme.fg("accent", theme.bold("Pifile"))}  ` +
						`${theme.fg("dim", `${entries.length} packages · ${pifileCount} file${pifileCount > 1 ? "s" : ""}`)}`,
						1, 0,
					),
				);
				container.addChild(new Spacer(1));

				// Package list (display only, not interactive)
				for (const e of entries) {
					const icon = e.installed
						? theme.fg("success", "✓")
						: theme.fg("error", "✗");
					const name = e.installed
						? theme.fg("muted", e.source)
						: theme.fg("text", e.source);
					const origin = theme.fg("dim", `  ${shortPifileName(e.pifile)}`);
					container.addChild(new Text(`  ${icon}  ${name}${origin}`, 0, 0));
				}

				container.addChild(new Spacer(1));

				// Action list
				const actions: SelectItem[] = missing.length > 0
					? [
						{
							value: "install",
							label: `Install ${missing.length} missing package${missing.length > 1 ? "s" : ""}`,
							description: missing.map((e) => e.source).join(", "),
						},
						{ value: "cancel", label: "Cancel" },
					]
					: [{ value: "cancel", label: "All packages installed ✓" }];

				const list = new SelectList(actions, actions.length, {
					selectedPrefix: (t) => theme.fg("accent", t),
					selectedText: (t) => theme.fg("accent", t),
					description: (t) => theme.fg("dim", t),
					scrollInfo: (t) => theme.fg("dim", t),
					noMatch: (t) => theme.fg("warning", t),
				});

				list.onSelect = (item) => done(item.value === "install" ? "install" : "cancel");
				list.onCancel = () => done("cancel");
				container.addChild(list);

				container.addChild(
					new Text(theme.fg("dim", "↑↓ navigate  •  enter select  •  esc close"), 1, 0),
				);
				container.addChild(new DynamicBorder((s: string) => theme.fg("accent", s)));

				return {
					render: (w) => container.render(w),
					invalidate: () => container.invalidate(),
					handleInput: (data) => { list.handleInput(data); tui.requestRender(); },
				};
			});

			if (action === "install") {
				await installPackages(missing.map((e) => e.source), ctx);
			}
		},
	});

	// ── Install helper ──────────────────────────────────────────────────────────
	async function installPackages(sources: string[], ctx: ExtensionContext): Promise<void> {
		for (const source of sources) {
			const ok = await ctx.ui.custom<boolean>((tui, theme, _kb, done) => {
				const loader = new BorderedLoader(tui, theme, `Installing ${source}...`);
				loader.onAbort = () => done(false);
				execAsync(`${piBin()} install ${source}`, { signal: loader.signal })
					.then(() => done(true))
					.catch((err: unknown) => {
						ctx.ui.notify(`Failed to install ${source}: ${err instanceof Error ? err.message : String(err)}`, "error");
						done(false);
					});
				return loader;
			});

			if (ok) {
				ctx.ui.notify(`✓ Installed ${source}`, "info");
			}
		}

		ctx.ui.setStatus("pifile", undefined);
		ctx.ui.notify("Done — run /reload to activate installed packages", "info");
	}
}
