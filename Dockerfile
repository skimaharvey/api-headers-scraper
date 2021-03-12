FROM ruby:2.6.3-alpine
# Ubuntu
# RUN apt-get update -qq && apt-get install -y nodejs sqlite3 yarn postgresql-client 
# Alpine
RUN apk update && apk add nodejs yarn postgresql-client postgresql-dev tzdata build-base sqlite-dev
RUN mkdir /myapp
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install 
COPY . /myapp
RUN bundle exec rake yarn:install
# Set production environment
ENV RAILS_ENV production
# Assets, to fix missing secret key issue during building
RUN SECRET_KEY_BASE=dumb bundle exec rails assets:precompile
# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 80
# Start the main proces
WORKDIR /myapp
# CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]

CMD ["bundle", "exec", "rails", "server","-p", "5000", "--pid", "tmp/pids/server241f231.pid"]
 
 #bundle exec rails server -p 4000 --pid tmp/pids/server2.pid