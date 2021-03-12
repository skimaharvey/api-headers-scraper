FROM ruby:2.6.3-alpine
# Ubuntu
#RUN apt-get update -qq && apt-get install -y nodejs yarn postgresql-client postgresql-dev
# Alpine
RUN apk update && apk add nodejs yarn postgresql-client postgresql-dev tzdata build-base
RUN mkdir /myapp
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install --deployment --without development test
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
# Start the main process.
WORKDIR /myapp

CMD ["rails", "server", "-b", "0.0.0.0"]
