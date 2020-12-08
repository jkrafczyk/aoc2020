CREATE TABLE replacement_results(
    replaced_line INTEGER PRIMARY KEY,
    acc INTEGER,
    termination_reason VARCHAR
);
CREATE TABLE suspicious_lines(
    line_number INTEGER PRIMARY KEY
);

-- CREATE TABLE original_program AS SELECT * FROM program;

CREATE VIEW attempt_program_with_replacements(_) AS SELECT(NULL);
CREATE TRIGGER tr_attempt_program_with_replacements 
INSTEAD OF INSERT ON attempt_program_with_replacements
BEGIN
    --Run the program once, to find out which lines are normally executed:
    --  - changing any lines not executed in the default flow will not change the result
    --  - Also don't count acc-lines as possibly problematic.
    INSERT INTO run_program VALUES (1, 0);
    INSERT INTO suspicious_lines(line_number)
        SELECT trace.line_number 
        FROM execution_trace trace
        INNER JOIN program p
        ON trace.line_number = p.line_number
        WHERE p.operation != 'acc';

    INSERT INTO attempt_program_with_replacement_at(line_number)
    SELECT line_number FROM suspicious_lines;
END;

CREATE VIEW attempt_program_with_replacement_at(line_number) AS SELECT(NULL);
CREATE TRIGGER tr_attempt_program_with_replacement_at
INSTEAD OF INSERT ON attempt_program_with_replacement_at
BEGIN
    --Create new, pristine, execution environment:
    ----Toggle command at location:
    UPDATE program 
        SET operation = CASE
            WHEN operation = 'jmp' THEN 'nop'
            WHEN operation = 'nop' THEN 'jmp'
            ELSE operation
        END
    WHERE line_number = new.line_number;
    
    ----Delete execution trace:
    DELETE FROM execution_trace;

    --Run the program
    INSERT INTO run_program VALUES (1, 0);

    --Reset the program:
    UPDATE program 
        SET operation = CASE
            WHEN operation = 'jmp' THEN 'nop'
            WHEN operation = 'nop' THEN 'jmp'
            ELSE operation
        END
    WHERE line_number = new.line_number;

    --Record the result
    INSERT INTO replacement_results(replaced_line, acc, termination_reason) 
        SELECT new.line_number, acc, termination_reason FROM execution_trace WHERE termination_reason IS NOT NULL;
END;

INSERT INTO attempt_program_with_replacements VALUES (NULL);
SELECT acc FROM replacement_results WHERE termination_reason = 'success';