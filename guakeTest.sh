#!/usr/bin/env bash
guake --rename-current-tab="tab0" --execute-command="ls" &
sleep 1 && guake --new-tab="my/path" --rename-current-tab="tab1" --execute-command="ls" &
sleep 2 && guake --new-tab="my/path" --rename-current-tab="tab2" --execute-command="ls" &
exit 0
