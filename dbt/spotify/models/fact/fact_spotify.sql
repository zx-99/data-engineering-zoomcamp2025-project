{{
    config(
        materialized='table'
    )
}}

with base as (
    select
        spotify_id,
        snapshot_date,
        daily_rank,
        daily_movement,
        weekly_movement,
        popularity,
        is_explicit,
        country
    from {{ ref('stg_raw_spotify') }}
),
song as (
    select 
        spotify_id,
        name as song_name,
        album_name,
        album_release_date,
        duration_ms,
        is_explicit
    from {{ ref('dim_song') }}
),
audio as (
    select *
    from {{ ref('dim_audio_features') }}
),
country_dim as (
    select *
    from {{ ref('dim_country') }}
),
artist_agg as (
    select 
        spotify_id,
        STRING_AGG(artist, ', ') as artists_denorm
    from {{ ref('dim_artist') }}
    group by spotify_id
)

select 
    f.spotify_id,
    coalesce(aa.artists_denorm, s.song_name) as artists,
    s.song_name,
    s.album_name,
    s.album_release_date,
    s.duration_ms,
    s.is_explicit,
    f.snapshot_date,
    f.daily_rank,
    f.daily_movement,
    f.weekly_movement,
    f.popularity,
    cd.country,
    aud.danceability,
    aud.energy,
    aud.key,
    aud.loudness,
    aud.mode,
    aud.speechiness,
    aud.acousticness,
    aud.instrumentalness,
    aud.liveness,
    aud.valence,
    aud.tempo,
    aud.time_signature
from base f
left join song s on f.spotify_id = s.spotify_id
left join audio aud on f.spotify_id = aud.spotify_id
left join country_dim cd on f.country = cd.iso_code
left join artist_agg aa on f.spotify_id = aa.spotify_id
