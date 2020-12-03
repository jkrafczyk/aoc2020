WITH applied_policy AS (
    SELECT 
        p.*,
        LENGTH(p.password) - LENGTH(REPLACE(p.password, p.policy_char, '')) AS policy_char_count
    FROM passwords p
)
SELECT count(*)
FROM applied_policy
WHERE policy_char_count >= n1 AND policy_char_count <= n2