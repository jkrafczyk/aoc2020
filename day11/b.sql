PRAGMA recursive_triggers = ON;

CREATE VIEW seq AS 
    WITH RECURSIVE 
        numbers AS 
        (SELECT 1 as n
        UNION ALL SELECT n + 1 FROM numbers)
    SELECT * 
    FROM numbers 
    LIMIT (SELECT MAX(
        (SELECT MAX(row) FROM seats),
        (SELECT MAX(col) FROM seats)
        )
    );

CREATE TABLE directions(id CHAR PRIMARY KEY, row INTEGER, col INTEGER);
INSERT INTO directions VALUES 
    ('q', -1, -1),
    ('w', -1, 0),
    ('e', -1, 1),
    ('a', 0, -1),
    ('d', 0, 1),
    ('z', 1, -1),
    ('x', 1, 0),
    ('c', 1, 1);

CREATE VIEW lines_v(id, distance, row, col) AS 
    SELECT 
        directions.id,
        seq.n distance,
        directions.row * seq.n,
        directions.col * seq.n
    FROM 
    directions, seq;

--Limit line lenghts to sensible values for non-square fields:
CREATE TABLE lines(direction, distance, row, col, PRIMARY KEY(direction, distance));
CREATE INDEX ix_line_dist ON lines(distance, direction);
CREATE INDEX ix_line_coord ON lines(row, col);
INSERT INTO  lines SELECT * FROM lines_v l;

CREATE VIEW cell_full_neighbourhood AS SELECT 
    c.row row,
    c.col col,
    c.state state,
    d.distance distance,
    d.direction direction,
    n.state neighbour
FROM seats c, seats n, lines d
WHERE n.row = c.row + d.row
AND n.col = c.col + d.col
AND n.state != '.'
ORDER BY d.distance;

CREATE VIEW cell_visible_neighbourhood AS 
    SELECT 
        *
    FROM cell_full_neighbourhood
    GROUP BY
        row, col, direction
    ;

CREATE VIEW occupied_neighbours(row, col, state, neighbours) AS
    SELECT 
        c.*,
        (SELECT COUNT(*) FROM cell_visible_neighbourhood n WHERE n.row = c.row AND n.col = c.col AND n.neighbour = '#')
    FROM seats c;

-- Mostly copied from previous part from here on:
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
            WHEN state = '#' AND neighbours >= 5 THEN 'L'
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
SELECT * from rendered_field;
SELECT * FROM changes;
SELECT COUNT(*) FROM seats WHERE state = '#';
