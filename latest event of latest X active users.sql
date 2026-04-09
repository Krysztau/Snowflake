-- Imagine users activity where you want to pick latest activity per user and then from that set get only 2 users for which last activity was "most fresh" 

WITH DANE AS 
(SELECT 
'A' AS EMAIL
, 1 AS CZAS
, '001' AS DOCNUM

UNION ALL SELECT 'A', 2, '002'
UNION ALL SELECT 'C', 3, '003'
UNION ALL SELECT 'B', 4, '004'
UNION ALL SELECT 'B', 6, '005'  ---- 
UNION ALL SELECT 'A', 7, '006'
UNION ALL SELECT 'C', 10, '007'   ----
UNION ALL SELECT 'A', 20, '008'  -----
UNION ALL SELECT 'A', 17, '009'
UNION ALL SELECT 'B', 5, '010'
UNION ALL SELECT 'C', 4, '011'
)

SELECT EMAIL, DOCNUM FROM DANE
QUALIFY ROW_NUMBER() OVER (PARTITION BY EMAIL ORDER BY CZAS DESC) = 1    --- for each email get only latest row
    -- AND ROW_NUMBER() OVER (  ORDER BY CZAS DESC) <= 2   nie dziala!!!!

--- from all data pick only 2 latest active emails
order by CZAS ASC
LIMIT 2
