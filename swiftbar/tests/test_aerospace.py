import importlib.util
import io
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]

class PluginTests(unittest.TestCase):
    def helper(self):
        path = ROOT / 'lib' / 'aerospace.py'
        self.assertTrue(path.exists(), 'Python helper is not implemented')
        spec = importlib.util.spec_from_file_location('plugin', path)
        assert spec is not None and spec.loader is not None
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        return module

    def test_combined_header_filters_and_marks_active(self):
        p = self.helper()
        settings = {'size': 15, 'workspaces': [
            {'name': '1-💼-Work', 'label': '1 💼 Work'},
            {'name': '2-📅-Plan', 'label': '2 📅 Plan'},
            {'name': '3-🤖-Agents', 'label': '3 🤖 Agents'}]}
        output = p.render(settings, {'1-💼-Work'}, {'2-📅-Plan'}, '2-📅-Plan')
        header = output.splitlines()[0]
        self.assertEqual(header, '1 💼 Work │ **[● 2 📅 Plan]** | size=15 md=true')
        self.assertEqual(output.splitlines()[1], '---')
        self.assertIn('param1=workspace param2="2-📅-Plan" terminal=false refresh=true', output)
        self.assertIn('3 🤖 Agents |', output)  # empty spaces remain switchable
        self.assertNotIn('\x1b', output)

    def test_stream_frames_and_recovery(self):
        p = self.helper()
        self.assertTrue(hasattr(p, 'serve'), 'Stream/retry loop is not implemented')
        output, errors = io.StringIO(), io.StringIO()
        attempts = []
        def cycle(emit):
            attempts.append(1)
            if len(attempts) == 1:
                raise OSError('AeroSpace unavailable')
            emit('ready\n---\nmenu\n')
            emit('changed\n---\nmenu\n')
            raise KeyboardInterrupt
        sleeps = []
        p.serve(cycle, output, errors, sleeps.append)
        self.assertEqual(sleeps, [2])
        self.assertIn('unavailable', errors.getvalue())
        self.assertEqual(output.getvalue(), 'AeroSpace unavailable | size=15\n---\nWaiting for AeroSpace; retrying…\n~~~\nready\n---\nmenu\n~~~\nchanged\n---\nmenu\n')

    def test_settings_validation_and_custom_font(self):
        p = self.helper()
        self.assertTrue(hasattr(p, 'validate_settings'), 'Settings validation missing')
        good = {'size': 18, 'font': 'SF Pro Text', 'workspaces': [{'name': 'x', 'label': 'Custom'}]}
        p.validate_settings(good)
        self.assertIn('size=18 md=true font="SF Pro Text"', p.render(good, {'x'}, set(), 'x'))
        for label in ['bad|label', 'bad\nlabel', '**injection**', '\x1b[31mred']:
            with self.assertRaises(ValueError):
                p.validate_settings({'workspaces': [{'name': 'x', 'label': label}]})
        with self.assertRaises(ValueError):
            p.validate_settings({'size': -1, 'workspaces': []})

    def test_read_only_snapshot_uses_actual_cli_shapes(self):
        p = self.helper()
        self.assertTrue(hasattr(p, 'snapshot'), 'Read-only CLI snapshot missing')
        calls = []
        def query(*args):
            calls.append(args)
            if args[0] == 'list-windows':
                return '1-💼-Work\n1-💼-Work\n'
            if '--focused' in args:
                return '[{"workspace":"2-📅-Plan"}]'
            return '[{"workspace":"2-📅-Plan"}]'
        self.assertEqual(p.snapshot(query), ({'1-💼-Work'}, {'2-📅-Plan'}, '2-📅-Plan'))
        self.assertEqual(calls, [('list-windows', '--all', '--format', '%{workspace}'),
                                 ('list-workspaces', '--monitor', 'all', '--visible', '--json'),
                                 ('list-workspaces', '--focused', '--json')])

    def test_entrypoint_live_read_only_once(self):
        import subprocess
        entry = ROOT / 'plugins' / 'aerospace.sh'
        self.assertTrue(entry.exists(), 'Shell entrypoint missing')
        result = subprocess.run([str(entry), '--once'], capture_output=True, text=True, timeout=15)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stderr, '')
        self.assertIn('size=15 md=true', result.stdout)
        self.assertEqual(result.stdout.splitlines()[1], '---')
        self.assertEqual(sum('param1=workspace' in line for line in result.stdout.splitlines()), 5)

    def test_command_timeout_retries(self):
        import subprocess
        p = self.helper()
        errors = io.StringIO()
        attempts = []
        def cycle(emit):
            attempts.append(1)
            if len(attempts) == 1:
                raise subprocess.TimeoutExpired('aerospace', 5)
            raise KeyboardInterrupt
        p.serve(cycle, io.StringIO(), errors, lambda _: None)
        self.assertEqual(len(attempts), 2)
        self.assertIn('timed out', errors.getvalue())

if __name__ == '__main__':
    unittest.main()
