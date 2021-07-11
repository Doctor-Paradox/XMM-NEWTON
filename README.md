# XMM-NEWTON
This script reduces XMM-Newton's pointed observation data for imaging mode.
To install:
  extract zip file, open extracted folder in terminal and immediately run:
  bash installer.sh
Usage:
  for GUI mode:
  xmmadvanced -g 2>&1 | tee whatever_name_for_logfile.log
  for CLI mode:
  xmmadvanced -c
  for help:
  xmmadvanced 
Note:
  some features are missing in CLI mode so GUI mode is preffered.
