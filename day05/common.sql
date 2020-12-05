CREATE TABLE boarding_passes(
    code,
    row,
    column,
    seatId,
    PRIMARY KEY (code)
);

INSERT INTO boarding_passes(code) SELECT line FROM input WHERE line != '';

UPDATE boarding_passes SET column = (WITH RECURSIVE column AS 
(
    SELECT 
        0 AS min_val,
        7 AS max_val,
        SUBSTR(code, 8) AS bsp
    UNION ALL
    SELECT
        CASE
            WHEN SUBSTR(bsp, 1, 1) = 'L' THEN min_val
            ELSE (min_val+max_val+1)/2
        END AS min_val,
        CASE
            WHEN SUBSTR(bsp, 1, 1) = 'L' THEN (min_val+max_val)/2
            ELSE max_val
        END AS max_val,
        SUBSTR(bsp, 2) AS bsp
    FROM column WHERE bsp != ''
) 
SELECT min_val FROM column WHERE bsp = '');

UPDATE boarding_passes SET row = (WITH RECURSIVE row AS 
(
    SELECT 
        0 AS min_val,
        127 AS max_val,
        SUBSTR(code, 1, 7) AS bsp
    UNION ALL
    SELECT
        CASE
            WHEN SUBSTR(bsp, 1, 1) = 'F' THEN min_val
            ELSE (min_val+max_val+1)/2
        END AS min_val,
        CASE
            WHEN SUBSTR(bsp, 1, 1) = 'F' THEN (min_val+max_val)/2
            ELSE max_val
        END AS max_val,
        SUBSTR(bsp, 2) AS bsp
    FROM row WHERE bsp != ''
) SELECT min_val FROM row WHERE bsp = '');

UPDATE boarding_passes SET seatId = row * 8 + column;