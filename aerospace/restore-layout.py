#!/opt/homebrew/bin/python3
"""Restore the five-workspace arrangement without activating apps or launching any.
Alt+Shift+R reroutes open windows and rebuilds the tiling containers.
Use --plan to inspect layout commands without changing anything.
"""
import argparse
import json
from pathlib import Path
import subprocess
import sys
import fcntl
import tomllib

AEROSPACE = '/opt/homebrew/bin/aerospace'
FIELDS = '%{window-id} %{app-name} %{app-bundle-id} %{workspace} %{window-layout} %{window-parent-container-layout}'


def build_plan(windows, work_width=None):
    commands = []
    for workspace in ('1-💼-Work', '2-📅-Plan', '3-🤖-Agents', '4-🏡-Personal', '5-💬-Comms'):
        commands.append(['flatten-workspace-tree', '--workspace', workspace])
        layout = 'tiles'
        commands.append(['layout', '--workspace', workspace, '--root', layout, 'horizontal'])
    for workspace, names in [('1-💼-Work', ['Google Chrome', 'Obsidian']), ('2-📅-Plan', ['Gmail', 'Calendar', 'Things'])]:
        selected = [w for name in names for w in sorted(windows, key=lambda w: w['window-id'])
                    if w['app-name'] == name and w['workspace'] == workspace
                    and w.get('window-layout') != 'floating']
        # Repeated left moves establish a deterministic order from any starting order.
        for window in reversed(selected):
            for _ in selected:
                commands.append(['move', '--window-id', str(window['window-id']), '--boundaries', 'workspace', '--boundaries-action', 'stop', 'left'])
        groups = ([w for w in selected if w['app-name'] == 'Google Chrome'],
                  [w for w in selected if w['app-name'] != 'Google Chrome']) if workspace == '1-💼-Work' else (
                  [w for w in selected if w['app-name'] == 'Gmail'],
                  [w for w in selected if w['app-name'] in ('Calendar', 'Things')])
        for group in groups:
            # Join right-to-left, letting an existing nested group move as one node.
            for i in range(len(group) - 2, -1, -1):
                commands.append(['join-with', '--window-id', str(group[i]['window-id']), 'right'])
                commands.append(['layout', '--window-id', str(group[i]['window-id']), 'tiles', 'vertical'])
        commands.append(['balance-sizes', '--workspace', workspace])
        if workspace == '1-💼-Work' and work_width and all(groups):
            # After balancing the two root columns, shrink Obsidian by 10% of
            # usable width, giving Chrome 60% and Obsidian 40%.
            commands.append(['resize', '--window-id', str(groups[1][0]['window-id']),
                             'width', f'-{round(work_width * 0.1)}'])
    return commands


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--plan', action='store_true')
    args = parser.parse_args()
    # Concurrent shortcuts/startup callbacks must not interleave tree operations.
    with (Path(__file__).parent / '.restore-layout.lock').open('w') as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            print('A restore is already running.')
            return
        if not args.plan:
            subprocess.run([AEROSPACE, 'run-callback', '--for-every-window', 'on-window-detected'], check=True)
        windows = json.loads(subprocess.check_output([AEROSPACE, 'list-windows', '--all', '--format', FIELDS, '--json'], text=True))
        screens_js = '''ObjC.import("AppKit"); var screens=$.NSScreen.screens; var result=[];
            for(var i=0;i<screens.count;i++){var screen=screens.objectAtIndex(i);
            result.push({name:ObjC.unwrap(screen.localizedName),width:screen.frame.size.width});}
            JSON.stringify(result)'''
        screens = json.loads(subprocess.check_output(['/usr/bin/osascript', '-l', 'JavaScript', '-e', screens_js], text=True))
        workspaces = json.loads(subprocess.check_output([AEROSPACE, 'list-workspaces', '--all', '--format', '%{workspace} %{monitor-name}', '--json'], text=True))
        monitor = next(w['monitor-name'] for w in workspaces if w['workspace'] == '1-💼-Work')
        width = next(s['width'] for s in screens if s['name'] == monitor)
        config = tomllib.loads((Path.home() / '.aerospace.toml').read_text())
        gaps = config.get('gaps', {})
        deductions = [gaps.get('outer', {}).get('left', 0), gaps.get('outer', {}).get('right', 0), gaps.get('inner', {}).get('horizontal', 0)]
        if not all(isinstance(value, (int, float)) for value in deductions):
            raise ValueError('Restore requires scalar horizontal gaps; update it for per-monitor gap rules.')
        plan = build_plan(windows, work_width=width - sum(deductions))
        if args.plan:
            print(json.dumps(plan, indent=2))
            return
        for command in plan:
            subprocess.run([AEROSPACE, *command], check=True)
        print('Restored Work, Plan, Agents, Personal and Comms.')


if __name__ == '__main__':
    try:
        main()
    except (subprocess.CalledProcessError, ValueError, OSError) as error:
        print(f'Layout restore failed: {error}', file=sys.stderr)
        sys.exit(1)
