------------------------------------------------------
-------------------- Problem 1 : ---------------------
----------------- Answer    : 17.5% ------------------
------------------------------------------------------

SELECT
  (round(summary.numerator/ summary.denom, 4)*100) as rates
FROM (
  SELECT
    count(case when b.station_id is null then a.tripduration else null end) as denom
    , count(case when b.station_id is null and c.station_id is null then a.tripduration else null end) as numerator
  FROM (
    SELECT
      *
    FROM `bigquery-public-data.new_york_citibike.citibike_trips`
    WHERE start_station_id is not null
  ) a 
  left join `bigquery-public-data.new_york_citibike.citibike_stations` b
    on a.start_station_id = b.station_id
  left join `bigquery-public-data.new_york_citibike.citibike_stations` c
    on a.end_station_id = c.station_id
) summary

------------------------------------------------------
-------------------- Problem 2A : --------------------
------------------------------------------------------

SELECT
    summary.month
    , summary.segment
    , count(distinct summary.user_id) as tot_users
FROM (
    SELECT
        datas.*
        , case
            when datas.trips = 0 then 'Inactive'
            when datas.trips between 1 and 10 then 'Casual'
            when datas.trips > 10 then 'Power'
        end as segment
    FROM (
        SELECT
            mob.Month
            , core.user_id
            , case 
                when core.trips is null then 0
                else core.trips
            end as trips
        FROM (
            SELECT Month
            FROM UNNEST(
                GENERATE_DATE_ARRAY(DATE_TRUNC(DATE('2018-01-01'), MONTH), CURRENT_DATE(), INTERVAL 1 MONTH)
            ) AS Month
        ) AS mob
        LEFT JOIN (
            SELECT
                a.user_id
                , a.month
                , count(distinct a.start_station_name) as trips
            FROM (
                SELECT
                    concat(usertype, '/', birth_year, '/', gender) as user_id
                    , date_trunc(date(starttime), month) as month
                    , *
                FROM `bigquery-public-data.new_york_citibike.citibike_trips`
                WHERE date(starttime) >= date('2018-01-01')
            ) a
            group by 1,2
        ) core on mob.month = core.month
    ) datas
) summary
group by 1,2
order by 1,2

------------------------------------------------------
-------------------- Problem 2B : --------------------
------------------------------------------------------

select
    month1.month as month
    , month1.next_month as next_month
    , month1.segment as segment_on_month
    , case
        when month2.segment is null then 'Inactive'
        else month2.segment
    end as segment_on_next_month
    , count(distinct month1.user_id) as tot_users
from (
    SELECT
        datas.*
        , case
            when datas.trips = 0 then 'Inactive'
            when datas.trips between 1 and 10 then 'Casual'
            when datas.trips > 10 then 'Power'
        end as segment
        , DATE_ADD(datas.Month, INTERVAL 1 MONTH) as next_month
    FROM (
        SELECT
            mob.Month
            , core.user_id
            , case 
                when core.trips is null then 0
                else core.trips
            end as trips
        FROM (
            SELECT Month
            FROM UNNEST(
                GENERATE_DATE_ARRAY(DATE_TRUNC(DATE('2018-01-01'), MONTH), CURRENT_DATE(), INTERVAL 1 MONTH)
            ) AS Month
        ) AS mob
        LEFT JOIN (
            SELECT
                a.user_id
                , a.month
                , count(distinct a.start_station_name) as trips
            FROM (
                SELECT
                    concat(usertype, '/', birth_year, '/', gender) as user_id
                    , date_trunc(date(starttime), month) as month
                    , *
                FROM `bigquery-public-data.new_york_citibike.citibike_trips`
                WHERE date(starttime) >= date('2018-01-01')
            ) a
            group by 1,2
        ) core on mob.month = core.month
    ) datas
) month1
left join (
    SELECT
        datas.*
        , case
            when datas.trips = 0 then 'Inactive'
            when datas.trips between 1 and 10 then 'Casual'
            when datas.trips > 10 then 'Power'
        end as segment
    FROM (
        SELECT
            mob.Month
            , core.user_id
            , case 
                when core.trips is null then 0
                else core.trips
            end as trips
        FROM (
            SELECT Month
            FROM UNNEST(
                GENERATE_DATE_ARRAY(DATE_TRUNC(DATE('2018-01-01'), MONTH), CURRENT_DATE(), INTERVAL 1 MONTH)
            ) AS Month
        ) AS mob
        LEFT JOIN (
            SELECT
                a.user_id
                , a.month
                , count(distinct a.start_station_name) as trips
            FROM (
                SELECT
                    concat(usertype, '/', birth_year, '/', gender) as user_id
                    , date_trunc(date(starttime), month) as month
                    , *
                FROM `bigquery-public-data.new_york_citibike.citibike_trips`
                WHERE date(starttime) >= date('2018-01-01')
            ) a
            group by 1,2
        ) core on mob.month = core.month
    ) datas
) month2 on month1.user_id = month2.user_id
and month1.next_month = month2.month
group by 1,2,3,4
order by 1,3
