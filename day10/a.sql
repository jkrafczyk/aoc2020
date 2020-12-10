CREATE TABLE skips AS
    SELECT 
        (lag(joltage, 1, 0) OVER win) AS previous,
        joltage AS current,
        joltage - (lag(joltage, 1, 0) OVER win) as step
    FROM adapters 
    WINDOW win AS (ORDER BY joltage)
    ORDER BY joltage;

--Insert the difference to the devices adapter:
INSERT INTO skips(previous, current, step) 
    SELECT 
        max(joltage),
        max(joltage) + 3,
        3
    FROM adapters;

SELECT 'Joltage skips from|to|distance';
SELECT * FROM skips;

SELECT 'Result:';
SELECT 
    (SELECT COUNT(*) FROM skips WHERE step = 1) AS one_skips,
    (SELECT COUNT(*) FROM skips WHERE step = 3) AS three_skips,
    (SELECT COUNT(*) FROM skips WHERE step = 1) *
    (SELECT COUNT(*) FROM skips WHERE step = 3) AS product
    ;