FROM ruby:2.6.3-alpine AS gem
ENV RAILS_ENV production
WORKDIR /myapp
RUN apk add --update --no-cache nodejs yarn postgresql-client postgresql-dev tzdata build-base
# install gems
COPY Gemfile .
COPY Gemfile.lock .
RUN bundle install --deployment --without development test
# install npm packages
# COPY package.json .
# COPY yarn.lock .
# RUN yarn install --frozen-lockfile
# compile assets
COPY Rakefile .
COPY bin bin
COPY .browserslistrc .
COPY postcss.config.js .
COPY babel.config.js .
COPY config config
COPY app/assets app/assets
COPY app/javascript app/javascript
# Assets, to fix missing secret key issue during building
RUN SECRET_KEY_BASE=dumb bundle exec rails assets:precompile
FROM ruby:2.6.3-alpine
ENV RAILS_ENV production
ENV RAILS_LOG_TO_STDOUT 1
ENV RAILS_SERVE_STATIC_FILES 1
WORKDIR /myapp
RUN apk add --update --no-cache postgresql-client postgresql-dev tzdata
COPY . /myapp
COPY --from=gem /usr/local/bundle /usr/local/bundle
COPY --from=gem /myapp/vendor/bundle /myapp/vendor/bundle
COPY --from=gem /myapp/public/assets /myapp/public/assets
COPY --from=gem /myapp/public/packs /myapp/public/packs
# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 80
# Start the main process.
WORKDIR /myapp
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
