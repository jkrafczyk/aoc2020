SELECT COUNT(*) 
FROM passports 
WHERE
    byr IS NOT NULL
    AND iyr IS NOT NULL
    AND eyr IS NOT NULL
    AND hgt IS NOT NULL
    AND hcl IS NOT NULL
    AND ecl IS NOT NULL
    AND pid IS NOT NULL;
