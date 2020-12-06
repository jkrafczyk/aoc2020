WITH answered_questions_per_group AS (
    SELECT groupId, responseId, question
    FROM yeses y
    INNER JOIN responses 
    USING (responseId)
),
matching_answers AS (SELECT 
    *,
    (SELECT COUNT(*) FROM (SELECT DISTINCT responseId FROM answered_questions_per_group WHERE groupId=a.groupId)) AS responsesInGroup, 
    (SELECT COUNT(*) FROM (SELECT DISTINCT responseId FROM answered_questions_per_group WHERE groupId=a.groupId AND question=a.question)) AS responsesInGroupForThisQuestion
FROM answered_questions_per_group a
WHERE responsesInGroup = responsesInGroupForThisQuestion
),
fully_answered_questions_per_group AS 
    (SELECT DISTINCT groupId, question FROM matching_answers)
SELECT COUNT(*) FROM fully_answered_questions_per_group
; 