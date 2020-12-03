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
