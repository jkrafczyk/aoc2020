WITH line_offsets AS (
    SELECT 
        input.line AS line,
        1 AS start_of_min_count,
        INSTR(input.line, '-')-1 AS end_of_min_count,
        INSTR(input.line, '-')+1 AS start_of_max_count,
        INSTR(input.line, ' ')-1 AS end_of_max_count,
        INSTR(input.line, ' ')+1 AS start_of_policy_char,
        INSTR(input.line, ': ')+2 AS start_of_password 
     FROM input
), parsed_line AS (
    SELECT 
        o.line AS line,
        CAST (SUBSTR(o.line, o.start_of_min_count, 1 + o.end_of_min_count - o.start_of_min_count) AS INTEGER) AS min_count,
        CAST (SUBSTR(o.line, o.start_of_max_count, 1 + o.end_of_max_count - o.start_of_max_count) AS INTEGER) AS max_count,
        SUBSTR(o.line, o.start_of_policy_char, 1) AS policy_char,
        SUBSTR(o.line, o.start_of_password) AS password
    FROM line_offsets o
), applied_policy AS (
    SELECT 
        l.*,
        LENGTH(l.password) - LENGTH(REPLACE(l.password, l.policy_char, '')) AS policy_char_count
    FROM parsed_line l
)
SELECT count(*)
FROM applied_policy
WHERE policy_char_count >= min_count AND policy_char_count <= max_count