# Tmux Agent Indicator Integration

## Overview

The tmux-agent-indicator plugin has been integrated into your tmux configuration to provide visual feedback for Claude Code agent states. You'll see real-time status updates in your tmux status bar and window indicators.

## What's Been Configured

### Plugin Installation
- **Plugin**: `accessd/tmux-agent-indicator` installed via TPM
- **Location**: `~/.tmux/plugins/tmux-agent-indicator`

### Visual Indicators

#### Status Bar (Right Side)
Your status bar now shows:
1. **Session Dots** - Visual indicator of all tmux sessions
   - `●` = current session (purple)
   - `○` = inactive sessions (gray)
   - Red dot = session with agent needing attention

2. **Agent Indicator** - Shows Claude state with emoji
   - `🤖` = Claude agent is active/running
   - Icon animates with "Knight Rider" effect while running

3. **Window Tab Colors** - Active window tab changes color based on agent state
   - Simplified format without powerline arrows for reliability

#### Window Tab Colors (Dracula Classic Theme - Status Bar Only)
- **Running** 🟠: Orange window tab (`#ffb86c`) with black text - Agent is working
- **Needs Input** 🔴: Red window tab (`#ff5555`) with black text - Agent needs attention
- **Done** 🟢: Green window tab (`#50fa7b`) with black text - Agent finished successfully

**Note**: Pane borders and backgrounds are disabled. Only the window tabs in the status bar change color.

### Claude Code Hooks

The following hooks have been added to `~/.claude/settings.json`:

#### UserPromptSubmit Hook
When you submit a prompt to Claude:
1. First resets any previous state (`off`)
2. Then sets state to `running`

#### PermissionRequest Hook
When Claude requests permission:
- Sets state to `needs-input` (yellow indicators)

#### Stop Hook
When Claude finishes or is stopped:
- Sets state to `done` (green border, pink window title)

### Configuration Options

All settings are in `/Users/tomas.ave/.dotfiles/tmux/tmux.conf`:

```tmux
# Toggle features
set -g @agent-indicator-border-enabled 'on'
set -g @agent-indicator-indicator-enabled 'on'
set -g @agent-indicator-reset-on-focus 'on'
set -g @agent-indicator-animation-enabled 'on'

# State colors (Dracula Classic theme - Window Tab Colors Only)
set -g @agent-indicator-border-enabled 'off'
set -g @agent-indicator-background-enabled 'off'
set -g @agent-indicator-running-bg ''
set -g @agent-indicator-running-border ''
set -g @agent-indicator-running-window-title-bg '#ffb86c'
set -g @agent-indicator-running-window-title-fg '#282a36'
set -g @agent-indicator-needs-input-bg ''
set -g @agent-indicator-needs-input-border ''
set -g @agent-indicator-needs-input-window-title-bg '#ff5555'
set -g @agent-indicator-needs-input-window-title-fg '#282a36'
set -g @agent-indicator-done-bg ''
set -g @agent-indicator-done-border ''
set -g @agent-indicator-done-window-title-bg '#50fa7b'
set -g @agent-indicator-done-window-title-fg '#282a36'

# Notifications
set -g @agent-indicator-notification-enabled 'on'
set -g @agent-indicator-notification-states 'needs-input,done'
```

## How It Works

### State Tracking
The plugin tracks three states per tmux pane:
- **running** - Agent is processing your request
- **needs-input** - Agent is waiting for permission or input
- **done** - Agent has completed the task

### State Transitions
```
User submits prompt → running (🤖 icon, 🟠 orange window tab)
                         ↓
Claude needs permission → needs-input (🔴 red window tab)
                         ↓
User grants permission → running (🟠 back to orange tab)
                         ↓
Claude finishes → done (🟢 green window tab)
                         ↓
User focuses pane → reset (tab back to default)
```

### Reset Behavior
With `reset-on-focus` enabled, visual indicators persist until you focus the pane. This means you can:
- See which windows have finished agents across multiple tabs
- Not miss completion notifications if you're working elsewhere
- Clear the indicator by simply switching to that pane

## Usage Examples

### Normal Workflow
1. Start Claude Code in a tmux pane
2. Submit a prompt → Status bar shows 🤖, window tab turns orange
3. Claude requests permission → Window tab turns red
4. You grant permission → Back to running state (orange tab)
5. Claude finishes → Window tab turns green
6. You switch to that pane → Tab returns to normal color

### Multi-Window Monitoring
- Open multiple tmux windows, each running Claude Code sessions
- Session dots show which sessions have agents needing attention (red)
- Orange tabs = working, Red tabs = need input, Green tabs = done
- Quickly identify which Claude instances need your attention by looking at tab colors in status bar

### Testing the Indicator
You can manually test the states:
```bash
# Set to running
~/.tmux/plugins/tmux-agent-indicator/scripts/agent-state.sh --agent claude --state running

# Set to needs-input
~/.tmux/plugins/tmux-agent-indicator/scripts/agent-state.sh --agent claude --state needs-input

# Set to done
~/.tmux/plugins/tmux-agent-indicator/scripts/agent-state.sh --agent claude --state done

# Reset/off
~/.tmux/plugins/tmux-agent-indicator/scripts/agent-state.sh --agent claude --state off
```

## Customization

### Change Icons
Edit `/Users/tomas.ave/.dotfiles/tmux/tmux.conf`:
```tmux
set -g @agent-indicator-icons 'claude=🧠,default=🤖'
```

### Adjust Colors
Modify the state colors to your preference:
```tmux
set -g @agent-indicator-needs-input-border 'yellow'
set -g @agent-indicator-done-border 'green'
```

### Disable Features
Turn off specific visual channels:
```tmux
set -g @agent-indicator-animation-enabled 'off'
set -g @agent-indicator-notification-enabled 'off'
```

## Troubleshooting

### Indicator Not Showing
1. Check tmux environment variable:
   ```bash
   tmux show-environment -g TMUX_AGENT_INDICATOR_DIR
   ```
   Should output: `/Users/tomas.ave/.tmux/plugins/tmux-agent-indicator`

2. Verify plugin is installed:
   ```bash
   ls ~/.tmux/plugins/tmux-agent-indicator/scripts/
   ```

3. Reload tmux config:
   ```bash
   tmux source-file ~/.tmux.conf
   ```

### Hooks Not Firing
1. Check Claude settings:
   ```bash
   jq '.hooks.UserPromptSubmit' ~/.claude/settings.json | grep agent-state
   ```

2. Verify hooks are configured in `~/.claude/settings.json`

3. Restart Claude Code for hooks to take effect

### Colors Not Matching Theme
The colors are configured for the Dracula theme. If using a different theme, adjust the hex values in `tmux.conf` to match your color scheme.

## Backups

Before integration, the following backups were created:
- `~/.dotfiles/tmux/tmux.conf.backup` - Original tmux config
- `~/.claude/settings.json.backup-before-agent-indicator` - Original Claude settings

## References

- **Plugin Repository**: https://github.com/accessd/tmux-agent-indicator
- **Plugin Documentation**: See README in `~/.tmux/plugins/tmux-agent-indicator/`
- **TPM (Plugin Manager)**: https://github.com/tmux-plugins/tpm
- **Claude Code Hooks**: https://docs.anthropic.com/claude-code/hooks

## Next Steps

1. Start a new tmux session or reload your current session
2. Start Claude Code in a tmux pane
3. Submit a prompt and watch the status bar change
4. The indicator will show 🤖 while Claude is working
5. Window colors will change when Claude needs input or finishes

Enjoy your new visual feedback for Claude agent states!
