#!/bin/sh
# <xbar.title>AeroSpace Workspaces</xbar.title>
# <xbar.version>1.0</xbar.version>
# <xbar.desc>Combined workspace strip, updated from AeroSpace events.</xbar.desc>
# <swiftbar.type>streamable</swiftbar.type>
# <swiftbar.hideLastUpdated>true</swiftbar.hideLastUpdated>
# Resolve both plugin symlinks and symlinked parent directories without hardcoding a checkout.
exec /opt/homebrew/bin/python3 -B -u -c '
from pathlib import Path
import runpy
import sys
entry = Path(sys.argv.pop(1)).resolve()
runpy.run_path(str(entry.parents[1] / "lib" / "aerospace.py"), run_name="__main__")
' "$0" "$@"
