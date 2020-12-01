#!/usr/bin/env bash
set -euo pipefail

TARGET=2020
NUMBERS=( )
while read -r line; do
    NUMBERS=( "${NUMBERS[@]}" $line)
done < day1.input

for i in $(seq ${#NUMBERS[@]}); do
    ni=${NUMBERS[$i-1]}
    for j in $(seq $i ${#NUMBERS[@]}); do
        nj=${NUMBERS[$j-1]}
        if [[ $((ni+nj)) = 2020 ]]; then
            echo "$((ni*nj))"
            exit 0
        fi
    done
done