{{
    config(
        materialized='view'
    )
}}


WITH raw AS (
    SELECT *,
    from {{ source('staging', 'spotify_top') }}
    WHERE spotify_id IS NOT NULL and country != ""
)

SELECT 
    spotify_id         as spotify_id,
    name               as name,
    artists            as artists,
    daily_rank         as daily_rank,
    daily_movement     as daily_movement,
    weekly_movement    as weekly_movement,
    country            as country,
    CAST(snapshot_date_ts AS TIMESTAMP) as snapshot_date,
    CAST(album_release_date_ts AS TIMESTAMP) as album_release_date,
    popularity         as popularity,
    is_explicit        as is_explicit,
    duration_ms        as duration_ms,
    album_name         as album_name,
    danceability       as danceability,
    energy             as energy,
    key                as key,
    loudness           as loudness,
    mode               as mode,
    speechiness        as speechiness,
    acousticness       as acousticness,
    instrumentalness   as instrumentalness,
    liveness           as liveness,
    valence            as valence,
    tempo              as tempo,
    time_signature     as time_signature
FROM raw