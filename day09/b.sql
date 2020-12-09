
CREATE TABLE contiguous_range(
    start_idx INTEGER,
    start_val INTEGER,
    end_idx INTEGER,
    end_val INTEGER,
    total_val INTEGER,
    ok BOOLEAN
);

CREATE VIEW check_contiguous_range(start_idx) AS SELECT NULL;
CREATE TRIGGER tr_check_contiguous_range 
INSTEAD OF INSERT ON check_contiguous_range
BEGIN
    SELECT RAISE(IGNORE);
END;

INSERT INTO check_contiguous_range VALUES (1);

SELECT 
    (SELECT MIN(n) FROM numbers WHERE idx BETWEEN n1.idx AND n2.idx) +
    (SELECT MAX(n) FROM numbers WHERE idx BETWEEN n1.idx AND n2.idx)
FROM numbers n1, numbers n2
WHERE 
    --Skip numbers than can not be summed with any other number to reach the target
    n1.n <= ((SELECT * FROM invalid_number) - (SELECT min(n) FROM numbers))
    --Search for ranges of two or more numbers
    AND n2.idx > n1.idx
    --Only select ranges that sum to the solution from part 1
    AND (SELECT SUM(n3.n) FROM numbers n3 WHERE n3.idx BETWEEN n1.idx AND n2.idx) = (SELECT * FROM invalid_number)