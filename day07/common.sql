CREATE TABLE bags(color VARCHAR PRIMARY KEY);
CREATE TABLE bag_contents(container VARCHAR, contents VARCHAR, count INTEGER, PRIMARY KEY (container, contents));
CREATE INDEX ix_bag_contents_reverse ON bag_contents(contents, container);

--Could be done with INSERT ... SELECT DISTINCT
-- but with INSERT OR IGNORE, we can use the index on bags to avoid sorting
-- the input lines.
INSERT OR IGNORE INTO bags
    SELECT
    SUBSTR(line, 1, INSTR(line, ' bags contain')-1)
    FROM input
    WHERE line != '';

INSERT INTO bag_contents(container, contents, count) 
    WITH RECURSIVE 
        contents AS (
        SELECT
            SUBSTR(line, 1, INSTR(line, ' bags contain')-1) AS container,
            SUBSTR(line, INSTR(line, 'bags contain')+LENGTH('bags contain')+1) AS remainder,
            '' AS item
        FROM input WHERE line != ''
        UNION ALL
        SELECT
            container,
            CASE
                WHEN INSTR(remainder, ',') > 0 THEN SUBSTR(remainder, INSTR(remainder, ',')+2) --+2 instead of +1, because we want to skip the whitespace after comma.
                ELSE ''
            END AS remainder,
            CASE
                WHEN INSTR(remainder, ',') > 0 THEN SUBSTR(remainder, 1, INSTR(remainder, ',')-1)
                ELSE SUBSTR(remainder, 1, LENGTH(remainder)-1) --Skip the trailing dot.
            END AS item
        FROM contents WHERE remainder != ''
    ), contents_counts AS (
        SELECT 
            container,
            SUBSTR(item, INSTR(item, ' ')+1) item,
            CAST(SUBSTR(item, 1, INSTR(item, ' ')-1) AS INTEGER) count 
        FROM contents
        WHERE item != '' AND item != 'no other bags'
    )
    SELECT 
        container,
        SUBSTR(item, 1, INSTR(item, ' bag')-1),
        count
    FROM contents_counts;
