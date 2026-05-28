/**
 * Pi Package Browser
 *
 * Browse and install pi packages from npm directly inside pi.
 *
 * Usage:
 *   /packages           - browse all pi-package tagged packages
 *   /packages <query>   - search with an initial query (e.g. /packages dracula)
 */

import { exec } from "node:child_process";
import { promisify } from "node:util";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { BorderedLoader, DynamicBorder } from "@earendil-works/pi-coding-agent";
import { Container, type SelectItem, SelectList, Spacer, Text } from "@earendil-works/pi-tui";

const execAsync = promisify(exec);

// ─── Types ────────────────────────────────────────────────────────────────────

interface NpmPackage {
	name: string;
	description?: string;
	version?: string;
	date?: string;
	keywords?: string[];
	maintainers?: { username: string; email?: string }[];
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

async function searchPackages(query: string, signal: AbortSignal): Promise<NpmPackage[]> {
	const searchTerm = query.trim() ? `${query.trim()} pi-package` : "pi-package";
	const { stdout } = await execAsync(`npm search ${JSON.stringify(searchTerm)} --json`, { signal });
	const results = JSON.parse(stdout) as NpmPackage[];
	// Only return packages actually tagged pi-package
	return results.filter((p) => p.keywords?.includes("pi-package"));
}

function findPiBinary(): string {
	// Use the same node process that's running pi to invoke it
	// Fallback chain: well-known paths
	return "/opt/homebrew/bin/pi";
}

function formatDate(iso?: string): string {
	if (!iso) return "";
	const d = new Date(iso);
	return d.toLocaleDateString("en-US", { year: "numeric", month: "short", day: "numeric" });
}

// ─── Extension ────────────────────────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
	pi.registerCommand("packages", {
		description: "Browse and install pi packages from npm",
		handler: async (args, ctx) => {
			if (!ctx.hasUI) {
				ctx.ui.notify("Package browser requires interactive mode", "error");
				return;
			}

			const initialQuery = args?.trim() ?? "";

			// ── Step 1: Fetch packages ──────────────────────────────────────────
			const packages = await ctx.ui.custom<NpmPackage[] | null>((tui, theme, _kb, done) => {
				const label = initialQuery
					? `Searching npm for "${initialQuery}" pi-packages...`
					: "Fetching pi-packages from npm...";
				const loader = new BorderedLoader(tui, theme, label);
				loader.onAbort = () => done(null);

				searchPackages(initialQuery, loader.signal)
					.then((pkgs) => done(pkgs))
					.catch((err: unknown) => {
						const msg = err instanceof Error ? err.message : String(err);
						ctx.ui.notify(`npm search failed: ${msg}`, "error");
						done(null);
					});

				return loader;
			});

			if (!packages) return;

			if (packages.length === 0) {
				ctx.ui.notify(
					initialQuery ? `No pi-packages found matching "${initialQuery}"` : "No pi-packages found on npm",
					"warning",
				);
				return;
			}

			// ── Step 2: Browse ─────────────────────────────────────────────────
			const selected = await ctx.ui.custom<NpmPackage | null>((tui, theme, _kb, done) => {
				const items: SelectItem[] = packages.map((pkg) => ({
					value: pkg.name,
					label: pkg.name,
					description: pkg.description ?? "",
				}));

				const container = new Container();

				// Header
				container.addChild(new DynamicBorder((s: string) => theme.fg("accent", s)));
				container.addChild(
					new Text(
						`${theme.fg("accent", theme.bold("Pi Package Browser"))}  ${theme.fg("dim", `${packages.length} packages`)}`,
						1,
						0,
					),
				);

				// Package list with built-in search
				const list = new SelectList(items, Math.min(items.length, 16), {
					selectedPrefix: (t) => theme.fg("accent", t),
					selectedText: (t) => theme.fg("accent", t),
					description: (t) => theme.fg("muted", t),
					scrollInfo: (t) => theme.fg("dim", t),
					noMatch: (t) => theme.fg("warning", t),
				});

				list.onSelect = (item) => done(packages.find((p) => p.name === item.value) ?? null);
				list.onCancel = () => done(null);
				container.addChild(list);

				// Footer hint
				container.addChild(
					new Text(theme.fg("dim", "↑↓ navigate  •  type to filter  •  enter select  •  esc close"), 1, 0),
				);
				container.addChild(new DynamicBorder((s: string) => theme.fg("accent", s)));

				return {
					render: (w) => container.render(w),
					invalidate: () => container.invalidate(),
					handleInput: (data) => {
						list.handleInput(data);
						tui.requestRender();
					},
				};
			});

			if (!selected) return;

			// ── Step 3: Detail + action ────────────────────────────────────────
			const action = await ctx.ui.custom<"install" | null>((tui, theme, _kb, done) => {
				const actions: SelectItem[] = [
					{ value: "install", label: "Install", description: `pi install npm:${selected.name}` },
					{ value: "back", label: "← Back" },
				];

				const container = new Container();
				container.addChild(new DynamicBorder((s: string) => theme.fg("accent", s)));

				// Package name + version
				const versionStr = selected.version ? theme.fg("dim", `  v${selected.version}`) : "";
				container.addChild(new Text(theme.fg("accent", theme.bold(selected.name)) + versionStr, 1, 0));

				// Description
				if (selected.description) {
					container.addChild(new Text(theme.fg("text", selected.description), 1, 1));
				}

				// Keywords
				const tags = (selected.keywords ?? []).filter((k) => k !== "pi-package");
				if (tags.length > 0) {
					container.addChild(new Text(theme.fg("muted", tags.join("  ·  ")), 1, 0));
				}

				// Meta row: maintainer + date
				const maintainer = selected.maintainers?.[0]?.username;
				const date = formatDate(selected.date);
				const metaParts = [maintainer && `by ${maintainer}`, date].filter(Boolean).join("   ");
				if (metaParts) {
					container.addChild(new Text(theme.fg("dim", metaParts), 1, 0));
				}

				container.addChild(new Spacer(1));

				// Action list
				const list = new SelectList(actions, actions.length, {
					selectedPrefix: (t) => theme.fg("accent", t),
					selectedText: (t) => theme.fg("accent", t),
					description: (t) => theme.fg("muted", t),
					scrollInfo: (t) => theme.fg("dim", t),
					noMatch: (t) => theme.fg("warning", t),
				});

				list.onSelect = (item) => done(item.value === "install" ? "install" : null);
				list.onCancel = () => done(null);
				container.addChild(list);

				container.addChild(
					new Text(theme.fg("dim", "↑↓ navigate  •  enter select  •  esc cancel"), 1, 0),
				);
				container.addChild(new DynamicBorder((s: string) => theme.fg("accent", s)));

				return {
					render: (w) => container.render(w),
					invalidate: () => container.invalidate(),
					handleInput: (data) => {
						list.handleInput(data);
						tui.requestRender();
					},
				};
			});

			if (action !== "install") return;

			// ── Step 4: Install ────────────────────────────────────────────────
			const piBin = findPiBinary();
			const installed = await ctx.ui.custom<boolean>((tui, theme, _kb, done) => {
				const loader = new BorderedLoader(tui, theme, `Installing npm:${selected.name}...`);
				loader.onAbort = () => done(false);

				execAsync(`${piBin} install npm:${selected.name}`, { signal: loader.signal })
					.then(() => done(true))
					.catch((err: unknown) => {
						const msg = err instanceof Error ? err.message : String(err);
						ctx.ui.notify(`Install failed: ${msg}`, "error");
						done(false);
					});

				return loader;
			});

			if (installed) {
				ctx.ui.notify(
					`✓ Installed npm:${selected.name} — run /reload to activate`,
					"info",
				);
			}
		},
	});
}
