#!/bin/zsh

# display available colors in term
function colors() {
    for i in {0..255} ; do
        printf "\x1b[48;5;%sm%3d\e[0m " "$i" "$i"
        if (( i == 15 )) || (( i > 15 )) && (( (i-15) % 6 == 0 )); then
            printf "\n";
        fi
    done
}

# open intellij
function ij() {
    DIR=${1:-.}
    IDEA=`ls -1d /Applications/IntelliJ\ * | tail -n1`
    open_with_app "$DIR"
}

function open_with_app() {
    # were we given a file?
    echo "$1"
    if [ -f "$1" ]; then
        #  echo "opening '$1'"
        open -a "$IDEA" "$1"
    else
        # does our working dir have an .idea directory?
        if [ -d ".idea" ]; then
            echo foo
            #      echo "opening via the .idea dir"
            open -a "$IDEA" .

        # is there an IDEA project file?
        elif [ -f "*.ipr" ]; then
            #      echo "opening via the project file"
            open -a "$IDEA" `ls -1d *.ipr | head -n1`

        # Is there a pom.xml?
        elif [ -f "pom.xml" ]; then
            #      echo "importing from pom"
            open -a "$IDEA" "pom.xml"

        # can't do anything smart; just open IDEA
        else
            #      echo 'cbf'
            open "$IDEA"
        fi
    fi
}

