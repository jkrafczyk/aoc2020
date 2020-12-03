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