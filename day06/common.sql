CREATE TABLE groups(groupId INTEGER PRIMARY KEY, editing BOOLEAN);
CREATE TABLE responses(groupId INTEGER, responseId INTEGER PRIMARY KEY);
CREATE TABLE yeses(responseId INTEGER, question CHAR);

CREATE INDEX ix_resp_groupId ON responses(groupId);
CREATE INDEX ix_yes_responseId ON yeses(responseId);

CREATE VIEW parse_line(line) AS SELECT NULL;
CREATE TRIGGER tr_parse_line 
INSTEAD OF INSERT ON parse_line
BEGIN
    --Start-of-passport end end-of-passport handling:
    UPDATE groups SET editing = FALSE WHERE new.line == '' OR new.line IS NULL;
    INSERT INTO groups(editing) 
        SELECT TRUE WHERE (new.line != '' AND new.line IS NOT NULL) AND (SELECT COUNT(*) FROM groups WHERE editing=TRUE)==0;

    --Don't try to parse anything if line is null or empty:
    SELECT RAISE(IGNORE) WHERE new.line == '' OR new.line IS NULL;

    INSERT INTO responses(groupId) 
    VALUES 
        ((SELECT groupId FROM groups WHERE editing=TRUE));

    INSERT INTO yeses(responseId, question) 
        WITH RECURSIVE 
        question AS (
            SELECT 
                new.line AS remainder,
                NULL as question
            UNION ALL
            SELECT 
                SUBSTR(remainder, 2) AS remainder,
                SUBSTR(remainder, 1, 1) AS question
            FROM question
            WHERE remainder != ''
        )
        SELECT 
            (SELECT max(responseId) FROM responses),
            question 
        FROM question WHERE question IS NOT NULL;
END;

INSERT INTO parse_line SELECT line FROM input;
INSERT INTO parse_line(line) VALUES (NULL);