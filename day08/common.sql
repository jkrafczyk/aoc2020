CREATE TABLE program(
    line_number INTEGER PRIMARY KEY,
    operation VARCHAR,
    operand INTEGER
);

INSERT INTO program(line_number, operation, operand) 
    WITH parts AS (
        SELECT 
            rowid as line_number, 
            SUBSTR(line, 1, INSTR(line, ' ')-1) AS operation,
            CAST(SUBSTR(line, INSTR(line, ' ')+1) AS INTEGER) AS operand
        FROM input
        WHERE line != ''
    )
    SELECT * FROM parts;

PRAGMA recursive_triggers = ON;

CREATE TABLE execution_trace(
    operation_order INTEGER PRIMARY KEY,
    line_number INTEGER,
    acc INTEGER,
    termination_reason VARCHAR
);

CREATE VIEW run_program(line_number, acc) AS SELECT (NULL, NULL);
CREATE TRIGGER tr_run_program 
INSTEAD OF INSERT ON run_program
BEGIN
    --When infinite loop: Log trace and abort:
    INSERT INTO execution_trace(line_number, acc, termination_reason)
        SELECT
            new.line_number,
            new.acc,
            'loop'
        WHERE EXISTS(SELECT * FROM execution_trace WHERE line_number = new.line_number);

    --When jumping _immediately_ after end-of-program:
    INSERT INTO execution_trace(line_number, acc, termination_reason)
        SELECT
            new.line_number,
            new.acc,
            'success'
        WHERE new.line_number = 1 + (SELECT MAX(line_number) FROM program);

    --Terminate on loop and success cases:
    SELECT 
        RAISE(IGNORE)
    WHERE EXISTS(SELECT * FROM execution_trace WHERE termination_reason IS NOT NULL);

    --When jumping far outside end-of-program:
    INSERT INTO execution_trace(line_number, acc, termination_reason)
        SELECT
            new.line_number,
            new.acc,
            'error'
        WHERE NOT EXISTS(SELECT * FROM program WHERE line_number = new.line_number);

    --Terminate on error cases:
    SELECT 
        RAISE(IGNORE)
    WHERE EXISTS(SELECT * FROM execution_trace WHERE termination_reason IS NOT NULL);

    INSERT INTO execution_trace(line_number, acc) VALUES (new.line_number, new.acc);

    INSERT INTO run_program(line_number, acc)
    SELECT
        CASE 
            WHEN p.operation = 'jmp' THEN new.line_number + p.operand
            ELSE new.line_number + 1
        END line_number,
        CASE 
            WHEN p.operation = 'acc' THEN new.acc + p.operand
            ELSE new.acc
        END acc
    FROM program p WHERE line_number = new.line_number;
END;     