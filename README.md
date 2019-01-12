# README

## DB setup

### Dev

```
CREATE DATABASE yt_recommender_development;
CREATE USER yt_recommender_development WITH PASSWORD 'password';
ALTER USER yt_recommender_development WITH SUPERUSER;
GRANT ALL PRIVILEGES ON DATABASE "yt_recommender_development" to yt_recommender_development;
```

### Test

```
CREATE DATABASE yt_recommender_test;
CREATE USER yt_recommender_test WITH PASSWORD 'password';
ALTER USER yt_recommender_test WITH SUPERUSER;
GRANT ALL PRIVILEGES ON DATABASE "yt_recommender_test" to yt_recommender_test;
```

### db restarting

```
bundle exec rake db:drop RAILS_ENV=development
bundle exec rake db:create RAILS_ENV=development
bundle exec rake db:migrate RAILS_ENV=development
```

### YouTube Channels

sv_catsaway = Channel.create(yt_id: 'UCvxC2_BVnsAcaPEsIUcJx6A')

video_1 = Video.create(channel: sv_catsaway, yt_id: 'W0lhlPdo0mw')
video_2 = Video.create(channel: sv_catsaway, yt_id: 'gQhlw6F603o', previous_video: video_1)
video_3 = Video.create(channel: sv_catsaway, yt_id: 'avIjWNpeZZY', previous_video: video_2)
