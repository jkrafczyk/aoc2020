CREATE TABLE seats(
    row INTEGER,
    col INTEGER,
    state CHAR,
    PRIMARY KEY(row, col)
);
CREATE INDEX ix_seats_by_col ON seats(col, row);
CREATE TABLE copy AS SELECT * FROM seats;

DELETE FROM input WHERE line = '';

INSERT INTO seats(row, col, state)
    WITH RECURSIVE
        cell AS (
            SELECT 
                line AS remainder,
                0 AS col,
                rowid AS row,
                NULL AS state 
            FROM input
            UNION ALL
            SELECT
                SUBSTR(remainder, 2) AS remainder,
                col + 1 AS col,
                row AS row,
                SUBSTR(remainder, 1, 1) AS state
            FROM cell WHERE remainder != ''
        )
    SELECT row, col, state FROM cell WHERE state IS NOT NULL;

CREATE VIEW rendered_lines AS
    WITH RECURSIVE
        line AS (
            SELECT 
                row,
                col,
                state AS line
            FROM
                seats
            WHERE col = 1
            UNION ALL
            SELECT 
                line.row,
                cell.col,
                line.line || cell.state
            FROM
                line
            INNER JOIN
                seats cell
            ON
                line.row = cell.row 
                AND cell.col = line.col + 1
        )
    SELECT 
        row, line
    FROM line
    WHERE col = (SELECT MAX(col) FROM seats);

CREATE VIEW rendered_field AS 
    WITH RECURSIVE 
        field AS (
            SELECT 
                0 AS row,
                '' AS output
            UNION ALL
            SELECT 
                line.row AS row,
                CASE 
                    WHEN field.output = '' THEN printf("%02i %s", line.row, line.line)
                    ELSE printf("%s%s%02i %s", field.output, CHAR(10), line.row, line.line)
                END
            FROM 
                field 
            INNER JOIN 
                rendered_lines line
            ON
                line.row = field.row + 1
        )
    SELECT output FROM field WHERE row = (SELECT MAX(row) FROM seats);