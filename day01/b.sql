SELECT a.n * b.n * c.n
FROM
    numbers a, numbers b, numbers c
WHERE
    c.n > b.n AND b.n > a.n AND  --Not required, but makes it faster. Alternatively, use LIMIT 1.
    a.n + b.n + c.n = 2020
;