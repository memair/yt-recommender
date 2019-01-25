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
bundle exec rake youtube:add_channel[https://www.youtube.com/philip_defranco,true,7]
```

### YouTube Channels

extra_credits = Channel.create(yt_id: 'UCCODtTcd5M1JavPCOr_Uydg')
attention_wars = Channel.create(yt_id: 'UCt_t6FwNsqr3WWoL6dFqG9w', default_frequency: 8)
philip_defranco = Channel.create(yt_id: 'UClFSU9_bUb4Rc6OYfTt5SPw', max_age: 7)
sv_catsaway = Channel.create(yt_id: 'UCvxC2_BVnsAcaPEsIUcJx6A', ordered: true)

### Adding channels with rake tasks

`bundle exec rake youtube:add_channel[https://www.youtube.com/philip_defranco,true,7]`
