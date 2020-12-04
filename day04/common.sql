CREATE TABLE passports(
    ecl VARCHAR DEFAULT NULL,
    pid VARCHAR DEFAULT NULL,
    eyr VARCHAR DEFAULT NULL,
    hcl VARCHAR DEFAULT NULL,
    byr VARCHAR DEFAULT NULL,
    iyr VARCHAR DEFAULT NULL,
    cid VARCHAR DEFAULT NULL,
    hgt VARCHAR DEFAULT NULL,
    editing BOOLEAN --is this the password we're currently editing?
);

--We don't have stored procedures in sqlite3, but a view with
-- and INSTEAD OF INSERT trigger is pretty much the same ;)
CREATE VIEW parse_line(line) AS SELECT NULL;
CREATE TRIGGER tr_parse_line 
INSTEAD OF INSERT ON parse_line
BEGIN
    --Start-of-passport end end-of-passport handling:
    UPDATE passports SET editing = FALSE WHERE new.line == '' OR new.line IS NULL;
    INSERT INTO passports(editing) 
        SELECT TRUE WHERE (new.line != '' AND new.line IS NOT NULL) AND (SELECT COUNT(*) FROM passports WHERE editing=TRUE)==0;
    --Don't try to parse anything if line is null or empty:
    SELECT RAISE(IGNORE) WHERE new.line == '' OR new.line IS NULL;

    --Call next trigger, to keep our 'procedures' short.
    INSERT INTO split_line_into_kv_pairs(line) VALUES (new.line);
END;

CREATE VIEW split_line_into_kv_pairs(line) AS SELECT NULL;
CREATE TRIGGER tr_split_line_into_kv_pairs 
INSTEAD OF INSERT ON split_line_into_kv_pairs
BEGIN
    --Call update passport with each key:value pair of the current line.
    INSERT INTO update_passport(key, value) 
        WITH RECURSIVE split_at_space AS (
        SELECT 
            new.line AS remainder,
            NULL AS item
        UNION ALL
            SELECT
                CASE
                    WHEN INSTR(s.remainder, ' ') > 0 THEN 
                        SUBSTR(s.remainder, INSTR(s.remainder, ' ') + 1)
                    ELSE 
                        ''
                END AS remainder, 
                CASE 
                    WHEN INSTR(s.remainder, ' ') > 0 THEN
                        SUBSTR(s.remainder, 1, INSTR(s.remainder, ' ') - 1)
                    ELSE
                        s.remainder
                END as item
            FROM split_at_space s
            WHERE s.remainder != ''
        ), 

        key_value_pairs AS (
            SELECT 
                SUBSTR(item, 1, INSTR(item, ':') - 1) AS key,
                SUBSTR(item, INSTR(item, ':') + 1) AS value
            FROM split_at_space 
            WHERE item IS NOT NULL
        )

        SELECT key, value FROM key_value_pairs;
END;

CREATE VIEW update_passport(key, value) AS SELECT(NULL, NULL);
CREATE TRIGGER tr_update_passport 
INSTEAD OF INSERT ON update_passport
BEGIN
    UPDATE passports SET byr = new.value WHERE editing = TRUE AND new.key = 'byr';
    UPDATE passports SET iyr = new.value WHERE editing = TRUE AND new.key = 'iyr';
    UPDATE passports SET eyr = new.value WHERE editing = TRUE AND new.key = 'eyr';
    UPDATE passports SET hgt = new.value WHERE editing = TRUE AND new.key = 'hgt';
    UPDATE passports SET hcl = new.value WHERE editing = TRUE AND new.key = 'hcl';
    UPDATE passports SET ecl = new.value WHERE editing = TRUE AND new.key = 'ecl';
    UPDATE passports SET pid = new.value WHERE editing = TRUE AND new.key = 'pid';
    UPDATE passports SET cid = new.value WHERE editing = TRUE AND new.key = 'cid';
END;

INSERT INTO parse_line SELECT * FROM input;
--Clearly mark end of input:
INSERT INTO parse_line(line) VALUES (NULL);
