WITH parsed_fields AS (
    SELECT 
        CAST(byr AS INTEGER) AS byr,
        CAST(iyr AS INTEGER) AS iyr,
        CAST(eyr AS INTEGER) AS eyr,
        SUBSTR(hgt, LENGTH(hgt)-1) AS hgt_unit,
        CAST(SUBSTR(hgt, 1, LENGTH(hgt)-2) AS INTEGER) AS hgt,
        SUBSTR(hcl, 1, 1) AS hcl_prefix,
        SUBSTR(hcl, 2) AS hcl,
        ecl AS ecl,
        pid AS pid,
        CAST(pid AS INTEGER) AS pid_int,
        cid
    FROM passports p WHERE 
    --All required fields present:
    byr IS NOT NULL
    AND iyr IS NOT NULL
    AND eyr IS NOT NULL
    AND hgt IS NOT NULL
    AND hcl IS NOT NULL
    AND ecl IS NOT NULL
    AND pid IS NOT NULL
), valid_rows AS (
SELECT * FROM parsed_fields 
WHERE
    byr BETWEEN 1920 AND 2002
    AND iyr BETWEEN 2010 AND 2020
    AND eyr BETWEEN 2020 AND 2030
    AND CASE
        WHEN hgt_unit = 'cm' THEN hgt BETWEEN 150 AND 193
        WHEN hgt_unit = 'in' THEN hgt BETWEEN 59 AND 76
        ELSE FALSE
    END
    AND hcl_prefix = '#'
    AND LENGTH(hcl) = 6
    --Sqlite has no functions to parse hex, and no built-in regex support. 
    AND (SUBSTR(hcl, 1, 1) BETWEEN '0' AND '9' OR SUBSTR(hcl, 1, 1) BETWEEN 'a' AND 'f')
    AND (SUBSTR(hcl, 2, 1) BETWEEN '0' AND '9' OR SUBSTR(hcl, 2, 1) BETWEEN 'a' AND 'f')
    AND (SUBSTR(hcl, 3, 1) BETWEEN '0' AND '9' OR SUBSTR(hcl, 3, 1) BETWEEN 'a' AND 'f')
    AND (SUBSTR(hcl, 4, 1) BETWEEN '0' AND '9' OR SUBSTR(hcl, 4, 1) BETWEEN 'a' AND 'f')
    AND (SUBSTR(hcl, 5, 1) BETWEEN '0' AND '9' OR SUBSTR(hcl, 5, 1) BETWEEN 'a' AND 'f')
    AND (SUBSTR(hcl, 6, 1) BETWEEN '0' AND '9' OR SUBSTR(hcl, 6, 1) BETWEEN 'a' AND 'f')

    --Skip full validation of hcl for now
    AND ecl IN ('amb', 'blu', 'brn', 'gry', 'grn', 'hzl', 'oth')
    AND (
            (pid_int = 0 AND pid = '000000000')
        OR  (LENGTH(pid) = 9)
    )
)
SELECT COUNT(*) FROM valid_rows;