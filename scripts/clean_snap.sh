#!/bin/bash
#Remove old revisions of snap packages

snap list --all | awk '/disabled/{print $1, $3}' |
    while read snapname revision; do
        echo "snap remove $snapname --revision $revision"
    done
