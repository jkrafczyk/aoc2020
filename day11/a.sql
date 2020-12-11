PRAGMA recursive_triggers = ON;

CREATE VIEW occupied_neighbours AS
    select 
        row, 
        col,
        state,
        (SELECT COUNT(*) FROM seats s2
            WHERE s2.state = '#' 
                AND s2.row BETWEEN s1.row-1 AND s1.row+1
                AND s2.col BETWEEN s1.col-1 AND s1.col+1
                AND (s2.row != s1.row OR s2.col != s1.col)
        ) neighbours
    FROM seats s1;

CREATE TABLE changes (change_count INTEGER);

CREATE VIEW calculate_gol_round(_) AS SELECT NULL;
CREATE TRIGGER tr_calculate_gol_round 
INSTEAD OF INSERT ON calculate_gol_round
BEGIN
    DELETE FROM copy;

    INSERT INTO copy(row,col,state) SELECT
        row,
        col,
        CASE
            WHEN state = '.' THEN '.'
            WHEN state = 'L' AND neighbours = 0 THEN '#'
            WHEN state = '#' AND neighbours >= 4 THEN 'L'
            ELSE state
        END new
    FROM occupied_neighbours;

    INSERT INTO changes
        SELECT COUNT(*) 
            FROM copy 
            INNER JOIN
            seats
            USING (row, col)
            WHERE copy.state != seats.state;
    

    DELETE FROM seats;
    INSERT INTO seats SELECT * FROM copy;
END;

CREATE VIEW calculate_forever(_) AS SELECT NULL;
CREATE TRIGGER tr_calculate_forever
INSTEAD OF INSERT ON calculate_forever
BEGIN
    INSERT INTO calculate_gol_round VALUES (NULL);
    --No more changes? Abort.
    SELECT RAISE(IGNORE) FROM changes WHERE change_count = 0;
    INSERT INTO calculate_forever VALUES (NULL);
END;

INSERT INTO calculate_forever VALUES (NULL);
--SELECT * from rendered_field;
--SELECT * FROM changes;
SELECT COUNT(*) FROM seats WHERE state = '#';
