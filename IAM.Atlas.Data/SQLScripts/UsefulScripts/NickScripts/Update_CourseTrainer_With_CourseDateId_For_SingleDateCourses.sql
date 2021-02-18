UPDATE CT 
SET CT.CourseDateId = CD.Id 
FROM CourseTrainer CT 
INNER JOIN ( 
        SELECT CD.CourseId, COUNT(*) CNT 
        FROM CourseDate CD 
        GROUP BY CD.CourseId 
        HAVING COUNT(*) = 1) T ON T.CourseId = CT.CourseId 
INNER JOIN CourseDate CD ON CD.CourseId = CT.CourseId 
WHERE CT.CourseDateId IS NULL 

