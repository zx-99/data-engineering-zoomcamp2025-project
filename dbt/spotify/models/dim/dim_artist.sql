{{
    config(
        materialized='table'
    )
}}

with raw as (
    select
        spotify_id,
        SPLIT(artists, ', ') as artist_array
    from {{ ref('stg_raw_spotify') }}
)

select distinct
    spotify_id,
    artist
from raw, unnest(artist_array) as artist