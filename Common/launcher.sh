#!/bin/bash
#curdate="`date +%Y%m%d%H%M%S`"
#echo $curdate
/Library/IntelligentAutomation/GUI.app/Contents/MacOS/GUI &
sleep 5
cd /Library/IntelligentAutomation
ulimit -n 4096
./testexecutor
