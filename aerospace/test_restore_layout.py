"""Contract tests for Tomas's five-workspace setup. Run with Homebrew Python."""
import importlib.util
from pathlib import Path
import tomllib
import unittest

HERE = Path(__file__).resolve().parent

class ConfigTests(unittest.TestCase):
    def test_hermes_bundled_launcher_and_routing(self):
        config = tomllib.loads((HERE / 'aerospace.toml').read_text())
        bundle = 'com.nousresearch.hermes-bundled'
        self.assertEqual(config['mode']['main']['binding']['cmd-ctrl-alt-shift-h'],
                         f'exec-and-forget open -b {bundle}')
        rules = [r for r in config['on-window-detected'] if bundle in r['if']]
        self.assertEqual(len(rules), 1)
        self.assertIn('move-node-to-workspace "3-🤖-Agents"', rules[0]['run'])

    def test_monitor_assignments_and_restore_shortcut(self):
        config = tomllib.loads((Path.home() / '.aerospace.toml').read_text())
        assignment = config.get('workspace-to-monitor-force-assignment', {})
        for workspace in ('1-💼-Work', '2-📅-Plan', '3-🤖-Agents', '4-🏡-Personal'):
            self.assertEqual(assignment.get(workspace), ['LG HDR WQHD', 'built-in'])
        self.assertEqual(assignment.get('5-💬-Comms'), 'built-in')
        self.assertIn('restore-layout.py', config['mode']['main']['binding']['alt-shift-r'])
        self.assertEqual(config['mode']['main']['binding']['alt-1'], 'workspace "1-💼-Work"')
        self.assertTrue(any('Bitwarden' in rule['if'] for rule in config['on-window-detected']))

    def test_sketchybar_disabled_and_gap_reclaimed(self):
        config = tomllib.loads((Path.home() / '.aerospace.toml').read_text())
        self.assertFalse(any('sketchybar' in command for command in config['after-startup-command']))
        self.assertNotIn('sketchybar', str(config.get('exec-on-workspace-change', [])))
        self.assertNotIn('sketchybar', str(config.get('on-focus-changed', [])))
        self.assertEqual(config['gaps']['outer']['top'], 20)
        self.assertIn('follow-clawd.sh', str(config['exec-on-workspace-change']))

class RestoreTests(unittest.TestCase):
    def test_work_restores_sixty_forty_split(self):
        spec = importlib.util.spec_from_file_location('restore_layout', HERE / 'restore-layout.py')
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        windows = [
            {'window-id': 1, 'app-name': 'Google Chrome', 'workspace': '1-💼-Work', 'window-layout': 'h_tiles'},
            {'window-id': 2, 'app-name': 'Obsidian', 'workspace': '1-💼-Work', 'window-layout': 'h_tiles'},
        ]
        try:
            plan = module.build_plan(windows, work_width=3380)
        except TypeError:
            self.fail('The layout planner does not yet support a monitor-aware 60/40 split')
        resize = ['resize', '--window-id', '2', 'width', '-338']
        self.assertIn(resize, plan)
        self.assertGreater(plan.index(resize), plan.index(['balance-sizes', '--workspace', '1-💼-Work']))

    def test_three_planning_apps_become_gmail_left_and_stacked_right(self):
        path = HERE / 'restore-layout.py'
        self.assertTrue(path.exists(), 'Restore-layout implementation is missing')
        spec = importlib.util.spec_from_file_location('restore_layout', path)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        windows = [
            {'window-id': 10, 'app-name': 'Gmail', 'workspace': '2-📅-Plan', 'window-layout': 'h_tiles'},
            {'window-id': 20, 'app-name': 'Calendar', 'workspace': '2-📅-Plan', 'window-layout': 'h_tiles'},
            {'window-id': 30, 'app-name': 'Things', 'workspace': '2-📅-Plan', 'window-layout': 'h_tiles'},
        ]
        plan = module.build_plan(windows)
        self.assertIn(['join-with', '--window-id', '20', 'right'], plan)
        self.assertIn(['layout', '--window-id', '20', 'tiles', 'vertical'], plan)
        self.assertFalse(any(command[0] in ('focus', 'workspace') for command in plan))
        for command in plan:
            if command[0] == 'move':
                self.assertIn('--boundaries-action', command,
                              'Reordering must stop at the edge, not create implicit containers')
                self.assertEqual(command[command.index('--boundaries-action') + 1], 'stop')
        for workspace in ('1-💼-Work', '2-📅-Plan', '3-🤖-Agents', '4-🏡-Personal', '5-💬-Comms'):
            self.assertIn(['layout', '--workspace', workspace, '--root', 'tiles', 'horizontal'], plan)
        self.assertFalse(any('accordion' in part for command in plan for part in command))
        config = tomllib.loads((Path.home() / '.aerospace.toml').read_text())
        self.assertEqual(config['default-root-container-layout'], 'tiles')
        self.assertFalse(any('accordion' in rule['run'] for rule in config['on-window-detected']))

if __name__ == '__main__':
    unittest.main()
