# A few AOC 2020 solutions in SQL

## Requirements
A somewhat recent version of sqlite3 needs to be available in $PATH. Until (including) day 9, all solutions should work with sqlite 3.24.0. Day 10 uses window functions and requires sqlite 3.25.0 or later.

## Usage
Use `run.sh` to run the solutions for all days in order.  
Use `run.sh day01` to run both parts of day 1.  
Use `run.sh day01 b` to run only the second part of day 1.  

## Directory layout
```
.
├── README.md
├── day01
│   ├── a.sql
│   ├── b.sql
│   ├── common.sql
│   └── input
├── day02
│   ├── a.sql
│   ├── b.sql
│   ├── common.sql
│   └── input
[...]
└── run.sh
```

* One directory for each day
* Each directory contains a file called 'input' with my input for that day of AoC 2020.
* Solutions for the first and second part of a day are a.sql and b.sql, respectively.
* Any code that has to be executed for both days (e.g. input pre-processing / parsing) is in common.sql