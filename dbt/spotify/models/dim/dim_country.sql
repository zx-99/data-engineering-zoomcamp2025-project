{{
    config(
        materialized='table'
    )
}}

select distinct
    s.country as iso_code,
    iso.name as country,
    iso.region
from {{ ref('stg_raw_spotify') }} as s
left join {{ ref('iso_country') }} as iso
on s.country = iso.`alpha-2`
where s.country is not null
