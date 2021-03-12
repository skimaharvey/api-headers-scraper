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
