WITH applied_policy AS (
    SELECT 
        p.*,
        SUBSTR(p.password, n1, 1) AS char1,
        SUBSTR(p.password, n2, 1) AS char2
    FROM passwords p
)
SELECT count(*)
FROM applied_policy
WHERE (char1 == policy_char) != (char2 == policy_char) 