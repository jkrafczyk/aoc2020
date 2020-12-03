CREATE TABLE slopes(slope_id INTEGER PRIMARY KEY, step_column INTEGER, step_row INTEGER);
INSERT INTO slopes(step_column, step_row) VALUES
    (1, 1),
    (3, 1),
    (5, 1),
    (7, 1),
    (1, 2);

--Try to walk all the paths:
CREATE VIEW slope_cost AS 
    WITH RECURSIVE path_nodes AS (
        SELECT 
            slope_id,
            step_column,
            step_row,
            1 AS row,
            1 AS column
        FROM slopes
        UNION ALL
        SELECT
            pn.slope_id,
            pn.step_column,
            pn.step_row,
            pn.row + pn.step_row,
            CASE --This really should be a simple modulo operation, but i got confused with the 1-based indexing.
                WHEN pn.column + step_column <= (SELECT MAX(column) FROM map) THEN pn.column + step_column
                ELSE pn.column + step_column - (SELECT MAX(COLUMN) FROM map) 
            END
        FROM path_nodes pn
        WHERE pn.row < (SELECT MAX(row) FROM map)
    ), 
    tree_encounters AS (
        SELECT pn.*, m.is_tree 
        FROM path_nodes pn
        INNER JOIN map m 
        USING (row, column)
        WHERE is_tree = TRUE
    )

    SELECT 
        slope_id, 
        COUNT(*) AS cost 
    FROM tree_encounters 
    GROUP BY slope_id
;


WITH RECURSIVE
    total_cost AS (
        SELECT
        0 slope_id,
        1 total_cost
        UNION ALL 
        SELECT 
        sc.slope_id, sc.cost * tc.total_cost
        FROM total_cost tc 
        INNER JOIN slope_cost sc 
        ON sc.slope_id = tc.slope_id + 1
    )       
SELECT max(total_cost) FROM total_cost;