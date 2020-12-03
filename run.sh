#!/usr/bin/env bash
set -euo pipefail

function indent() {
    sed 's/^/  /'
}

function run-part() {
    local day="$1"
    local part="$2"
    local inputs=( )
    if [[ ! -f "${day}/${part}.sql" ]]; then
        echo "No solution available for ${day} ${part}"
        return 1
    fi
    if [[ -f "${day}/common.sql" ]]; then
        inputs=( "common.sql" )
    fi
    inputs=( ${inputs[@]} "${part}.sql" )
    echo "$part"
    pushd "$day" >& /dev/null
    sqlite3 < <(
        printf "CREATE TABLE input(line VARCHAR);\n.import input input\n"
        cat "${inputs[@]}"
    ) | indent
    popd >& /dev/null
}

run-day () {
    local day="$1"
    echo "$day"
    if [[ -f "${day}/a.sql" ]]; then
        run-part "$day" a | indent
    fi
    if [[ -f "${day}/b.sql" ]]; then
        run-part "$day" b | indent
    fi
}

run-all() {
    for day in day*; do
        if [[ ! -d "$day" ]]; then
            continue
        fi
        run-day "$day"
    done
}

case $# in
    2) echo "$1"
       run-part $@ | indent
       ;;
    1) run-day $@
       ;;
    0) run-all
       ;;
esac   
