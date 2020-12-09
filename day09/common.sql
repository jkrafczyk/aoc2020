CREATE TABLE numbers(
    idx INTEGER PRIMARY KEY,
    n INTEGER
);
CREATE INDEX ix_n ON numbers(n, idx);

INSERT INTO numbers(n) 
    SELECT CAST(line AS INTEGER) 
    FROM input
    WHERE line != '';

CREATE TABLE config AS SELECT 25 AS preamble_length;

CREATE TABLE invalid_number
    AS SELECT
        n1.n AS n
    FROM numbers n1
    WHERE 
        --skip the preamble
        n1.idx > (SELECT preamble_length FROM config) AND NOT EXISTS(
            --Find matching distinct number pair in previous 25 numbers
            SELECT * FROM numbers n2, numbers n3
            WHERE 
                n2.idx >= n1.idx -(SELECT preamble_length FROM config)
                AND n3.idx > n2.idx
                AND n1.n = n2.n + n3.n
    )
    ORDER BY idx
    LIMIT 1;