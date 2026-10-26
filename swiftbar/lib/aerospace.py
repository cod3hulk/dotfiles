"""Event-driven AeroSpace menu for SwiftBar (stdlib only)."""
import json
import time
import os
from pathlib import Path
import select
import signal
import subprocess
import sys


def query(*args):
    result = subprocess.run([AEROSPACE, *args], capture_output=True, text=True, timeout=5)
    if result.returncode:
        raise OSError(result.stderr.strip() or f'AeroSpace exited {result.returncode}')
    return result.stdout


def snapshot(command=query):
    occupied = set(command('list-windows', '--all', '--format', '%{workspace}').splitlines())
    visible = {w['workspace'] for w in json.loads(command('list-workspaces', '--monitor', 'all', '--visible', '--json'))}
    focused = json.loads(command('list-workspaces', '--focused', '--json'))
    return occupied, visible, focused[0]['workspace'] if focused else None


def main():
    import argparse
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--once', action='store_true', help='Print one read-only snapshot and exit')
    parser.add_argument('--settings', type=Path, default=Path(__file__).resolve().parents[1] / 'settings.json')
    args = parser.parse_args()

    def frame():
        settings = json.loads(args.settings.read_text())
        validate_settings(settings)
        return render(settings, *snapshot())

    if args.once:
        try:
            print(frame(), end='', flush=True)
            return 0
        except (OSError, ValueError, subprocess.SubprocessError) as error:
            print(f'aerospace: {error}', file=sys.stderr)
            return 1

    def cycle(emit):
        # Query before subscribing to detect a missing/unstarted server immediately.
        emit(frame())
        with subprocess.Popen([AEROSPACE, 'subscribe', '--all'], stdout=subprocess.PIPE,
                              stderr=None, bufsize=0) as process:
            assert process.stdout is not None
            try:
                while True:
                    ready, _, _ = select.select([process.stdout], [], [], 15)
                    if ready:
                        if not os.read(process.stdout.fileno(), 65536):
                            raise OSError('AeroSpace event stream disconnected')
                    # Every event batch triggers a fresh snapshot. Periodic reconciliation
                    # also catches window occupancy changes that do not emit focus events.
                    emit(frame())
            finally:
                if process.poll() is None:
                    process.terminate()
                try:
                    process.wait(timeout=3)
                except subprocess.TimeoutExpired:
                    process.kill()
                    process.wait()

    signal.signal(signal.SIGTERM, lambda *_: (_ for _ in ()).throw(KeyboardInterrupt()))
    serve(cycle, sys.stdout, sys.stderr)
    return 0


def serve(cycle, output, errors, sleep=time.sleep):
    first = True
    previous = None

    def emit(frame):
        nonlocal first, previous
        if frame == previous:
            return
        output.write(('' if first else '~~~\n') + frame)
        output.flush()
        first, previous = False, frame

    try:
        while True:
            try:
                cycle(emit)
                raise OSError('AeroSpace event stream disconnected')
            except (OSError, ValueError, RuntimeError, subprocess.SubprocessError) as error:
                print(f'aerospace: {error}', file=errors, flush=True)
                emit('AeroSpace unavailable | size=15\n---\nWaiting for AeroSpace; retrying…\n')
                sleep(2)
    except KeyboardInterrupt:
        return

AEROSPACE = '/opt/homebrew/bin/aerospace'


def validate_settings(settings):
    if not isinstance(settings, dict):
        raise ValueError('settings must be an object')
    size = settings.get('size', 15)
    if isinstance(size, bool) or not isinstance(size, (int, float)) or not 6 <= size <= 72:
        raise ValueError('size must be between 6 and 72')
    workspaces = settings.get('workspaces')
    if not isinstance(workspaces, list) or not workspaces:
        raise ValueError('workspaces must be a nonempty list')
    names = set()
    for workspace in workspaces:
        if not isinstance(workspace, dict):
            raise ValueError('workspace must be an object')
        for key in ('name', 'label'):
            value = workspace.get(key)
            if not isinstance(value, str) or not value or any(ord(c) < 32 or c in '|*' for c in value):
                raise ValueError(f'invalid workspace {key}')
        if any(c.isspace() for c in workspace['name']) or workspace['name'].startswith('-'):
            raise ValueError('workspace names must be valid AeroSpace names')
        if workspace['name'] in names:
            raise ValueError('duplicate workspace name')
        names.add(workspace['name'])
    font = settings.get('font')
    if font is not None and (not isinstance(font, str) or not font or any(ord(c) < 32 or c in '|"\\\\' for c in font)):
        raise ValueError('invalid font')


def render(settings, occupied, visible, focused):
    workspaces = settings['workspaces']
    labels = [f"**[● {w['label']}]**" if w['name'] == focused else w['label']
              for w in workspaces if w['name'] in occupied | visible]
    style = f"size={settings.get('size', 15)} md=true"
    if settings.get('font'):
        style += ' font=' + json.dumps(settings['font'], ensure_ascii=False)
    lines = [(' │ '.join(labels) or 'AeroSpace') + ' | ' + style, '---']
    for w in workspaces:
        lines.append(w['label'] + ' | bash=' + AEROSPACE +
                     ' param1=workspace param2=' + json.dumps(w['name'], ensure_ascii=False) +
                     ' terminal=false refresh=true' +
                     (' checked=true' if w['name'] == focused else ''))
    return '\n'.join(lines) + '\n'


if __name__ == '__main__':
    sys.exit(main())
