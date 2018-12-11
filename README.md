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