WITH answered_questions_per_group AS (
    SELECT DISTINCT groupId, question
    FROM yeses y
    INNER JOIN responses 
    USING (responseId)
) 
SELECT COUNT(*) FROM answered_questions_per_group;