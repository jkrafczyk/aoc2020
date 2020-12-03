SELECT a.n * b.n
FROM
    numbers a, numbers b
WHERE
    b.n > a.n AND  --Not required, but makes it faster. Alternatively, use LIMIT 1.
    a.n + b.n = 2020
;