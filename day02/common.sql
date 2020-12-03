CREATE TABLE passwords(policy_char, n1, n2, password);
INSERT INTO passwords 
    WITH line_offsets AS (
        SELECT 
            input.line AS line,
            1 AS start_of_n1,
            INSTR(input.line, '-')-1 AS end_of_n1,
            INSTR(input.line, '-')+1 AS start_of_n2,
            INSTR(input.line, ' ')-1 AS end_of_n2,
            INSTR(input.line, ' ')+1 AS start_of_policy_char,
            INSTR(input.line, ': ')+2 AS start_of_password 
        FROM input
    ), parsed_line AS (
        SELECT 
            o.line AS line,
            CAST (SUBSTR(o.line, o.start_of_n1, 1 + o.end_of_n1 - o.start_of_n1) AS INTEGER) AS n1,
            CAST (SUBSTR(o.line, o.start_of_n2, 1 + o.end_of_n2 - o.start_of_n2) AS INTEGER) AS n2,
            SUBSTR(o.line, o.start_of_policy_char, 1) AS policy_char,
            SUBSTR(o.line, o.start_of_password) AS password
        FROM line_offsets o
    )
    SELECT policy_char, n1, n2, password FROM parsed_line;