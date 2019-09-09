FROM decidim/decidim:0.17.2

LABEL maintainer="hello@octree.ch"

ENV RAILS_ENV=production
ENV PORT=3000
ENV RAILS_SERVE_STATIC_FILES=true
ENV SECRET_KEY_BASE=no_need_for_such_secrecy

COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY . .
RUN bundle install
RUN bundle exec rake assets:precompile

VOLUME /code/storage
VOLUME /code/log

ENTRYPOINT []
CMD bundle exec rails s -b 0.0.0.0