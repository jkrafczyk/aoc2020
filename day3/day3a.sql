CREATE TABLE input(line VARCHAR);

.import ./day3.input input

--Parse map input:
CREATE TABLE map(row INTEGER, column INTEGER, is_tree BOOLEAN, PRIMARY KEY (row,column));

CREATE INDEX map_bounds_row ON map(row); --for max(row) query
CREATE INDEX map_bounds_column ON map(column); --for max(column) query

BEGIN;
INSERT INTO map(row, column, is_tree) 
    WITH RECURSIVE row_columns AS (
        SELECT 
            rowid AS row, 
            0 AS column, 
            true as is_tree,
            line AS remaining
        FROM input
        UNION ALL 
        SELECT 
            c.row AS row,
            c.column + 1 AS column,
            CASE 
                WHEN SUBSTR(c.remaining, 1, 1) = '#' THEN TRUE
                ELSE FALSE
            END,
            SUBSTR(c.remaining, 2)
        FROM row_columns c
        WHERE c.remaining != '' 
    )

    SELECT row, column, is_tree FROM row_columns WHERE column > 0;
COMMIT;

--Try to walk a path:
WITH RECURSIVE path_nodes AS (
    SELECT 
        1 AS row,
        1 AS column
    UNION ALL
    SELECT
        pn.row + 1,
        CASE --This really should be a simple modulo operation, but i got confused with the 1-based indexing.
            WHEN pn.column + 3 <= (SELECT MAX(column) FROM map) THEN pn.column + 3
            ELSE pn.column + 3 - (SELECT MAX(COLUMN) FROM map) 
        END
    FROM path_nodes pn
    WHERE pn.row < (SELECT MAX(row) FROM map)
), 
tree_encounters AS (
    SELECT pn.*, m.is_tree 
    FROM path_nodes pn
    INNER JOIN map m 
    USING (row, column))
SELECT count(*) FROM tree_encounters WHERE is_tree = TRUE;