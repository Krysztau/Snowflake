

with some_bs as
(select 'a' col1, 1 col2, 100 COL3
union all select 'a', 3, 101
union all select 'b', 2, 102
union all select 'a', 2, 104
union all select 'b', 1, 101
union all select 'c', 1, 103
union all select 'c', 2, 103
union all select 'b', 3, 107
union all select 'a', 5, 102
union all select 'a', 5, 100
)
select
col1
, LISTAGG(COL2, ', ') as col2_list
, LISTAGG(DISTINCT COL2, ', ') as col2_list_distinct
, LISTAGG(DISTINCT COL2, ', ') WITHIN GROUP (ORDER BY COL2) as col2_list_distinct_ORDERED
, MAX_BY(COL2, COL3) MAX_COL2_BY_3
-- , LISTAGG(DISTINCT COL2, ',') as col2_list_distinct3)

from some_bs
group by col1
;
