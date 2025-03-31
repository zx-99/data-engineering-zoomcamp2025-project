{{
    config(
        materialized='table'
    )
}}

select distinct
    spotify_id,
    danceability,
    energy,
    key,
    loudness,
    mode,
    speechiness,
    acousticness,
    instrumentalness,
    liveness,
    valence,
    tempo,
    time_signature
from {{ ref('stg_raw_spotify') }}
