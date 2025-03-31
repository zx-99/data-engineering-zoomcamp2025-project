{{
    config(
        materialized='table'
    )
}}

with song as (
    select
        spotify_id,
        name,
        album_name,
        album_release_date,
        duration_ms,
        is_explicit
    from {{ ref('stg_raw_spotify') }}
)

select distinct
    spotify_id,
    name,
    album_name,
    album_release_date,
    duration_ms,
    is_explicit
from song
where album_release_date is not null