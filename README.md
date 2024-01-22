# AsyncTMDBKit

![TMDB](tmdb.jpeg)

A basic implementation of the [TMDB API](https://developers.themoviedb.org/3) using Swift and `async`/`await`

This is primaryly a learning process for using `async`/`await`

Currently supports:

* Find by external id
* Seach movies (`https://api.themoviedb.org/3/search/movie?api_key=<<api_key>>&language=en-US&page=1&include_adult=false`) (paginated and unpaginated)
* Search TV (`https://api.themoviedb.org/3/search/tv?api_key=b8031409dad8c17a516fc3f8468be7ba&language=en-US&page=1&include_adult=false`) (paginated and unpaginated)
* Movie details (by id) (`https://api.themoviedb.org/3/movie/{movie_id}?api_key=b8031409dad8c17a516fc3f8468be7ba&language=en-US`)
* TV series details (by id) (`https://api.themoviedb.org/3/tv/{tv_id}?api_key=b8031409dad8c17a516fc3f8468be7ba&language=en-US`)
* TV seies seasons (by id and season) (`https://api.themoviedb.org/3/tv/{tv_id}/season/{season_number}?api_key=b8031409dad8c17a516fc3f8468be7ba&language=en-US`)
* Configuration (`https://api.themoviedb.org/3/configuration?api_key=<<api_key>>`)
* Image request/download by size (defined by the configuration and API)
