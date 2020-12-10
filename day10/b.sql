PRAGMA recursive_triggers = ON;

--This solution is... not pretty.
--Normally, the solution would be very simple and recursive, but that's prohibitively slow.

--Simple approach, in pseudo-code:
--  def permutations(x)
--    if x == adapter_voltage:
--      return 1
--    return sum(
--      permutations(y) for all y between x+1 and x+3
--    )
--  print(permutations(0))
--
--Doing this in sqlite is a bit difficult, because a have neither return values nor local variables. 
--The simplest solution would not directly count the permutations; instead it could enumerate all permutations and write them to a table. 
--The result would then be a COUNT(*) on that table.
--
--Both the simple pseudo-code approach, as well as the sqlite variant described above are too slow.
--Recursive pure functions tend to be easy to improve with memoization, so we could try that:
-- known_results = {adapter_voltage: 1}
-- def permuatations(x):
--   if x in known_results: 
--     return known_results[x]
--   known_results[x] = sum(
--     permutations(y) 
--       for all y between x+1 and x+3
--       ordered so that the shortest permutation is calculated first
--     )
--   return known_results[x] 
-- 
-- Again, not so nice to do without local variables and return values.
-- The SQLite solution below still does pretty much the same, but it only works when
-- all permutation counts for higher joltages have already been calculated.
-- So we call it for the highest possible joltages, then the second highest, and so on, until we call with joltage 0.
-- 
-- "If it's stupid and it works, it's not stupid."

CREATE TABLE results(
    start_joltage INTEGER PRIMARY KEY,
    permutations INTEGER
);

CREATE VIEW count_permutations(start_joltage) AS SELECT NULL, NULL;
CREATE TRIGGER tr_count_permutations
INSTEAD OF INSERT ON count_permutations
BEGIN
    --Do we already have a result for this? -> Abort.
    SELECT RAISE(IGNORE)
        WHERE EXISTS(SELECT * FROM results WHERE start_joltage = new.start_joltage);

    INSERT INTO results(start_joltage, permutations)
        SELECT 
            new.start_joltage, 
            1 
        WHERE NOT EXISTS(SELECT * FROM adapters WHERE joltage > new.start_joltage);
    SELECT RAISE(IGNORE)
        WHERE NOT EXISTS(SELECT * FROM adapters WHERE joltage > new.start_joltage);

    INSERT INTO count_permutations
        SELECT joltage 
        FROM adapters 
        WHERE joltage BETWEEN new.start_joltage + 1 AND new.start_joltage + 3
        ORDER BY joltage DESC;

    INSERT INTO results(start_joltage, permutations)
        SELECT new.start_joltage, (SELECT SUM(permutations) FROM results WHERE start_joltage BETWEEN new.start_joltage + 1 AND new.start_joltage + 3);    
END;


INSERT INTO count_permutations SELECT joltage FROM adapters ORDER BY joltage DESC;
INSERT INTO count_permutations VALUES(0);

SELECT * FROM results WHERE start_joltage = 0;