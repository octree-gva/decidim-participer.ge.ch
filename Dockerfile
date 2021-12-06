# Docker image for Decidim instance.
# ===
# This image is not suited for a development environment.
# The build is done in 3 steps:
#   2. Dependancy: a heavier image to build assets and native gems
#   3. Final: will take results of dependancy to serve a small and minimal image.
# 
# The idea behind this process is to expose in the deployed image as few as possible dependancies.
# Reducing this way the number of security issues.
# 
# Arguments
# ===
#   * ALPINE_RUBY_VERSION: the version of alpine ruby to use, without "ruby-" prefix
#   * BUNDLER_VERSION: bundler version
#   * NODE_VERSION: node version with "v" prefix
#   * USER: the username of the user that will run the app
#   * USER_UID: System non-root user UID 
#   * GROUP: group name that will run the app
#   * GROUP_UID: group UID that will run the app
#
# Filesystem
# ===
#   * /home/<USER>/app : Working directory
#   * /home/<USER>/vendor : Installed gems
#
# Volumes
# ===
# Some volumes will be mapped by defaults:
#   * storage
#   * public
#   * log
#   * ../vendor: to cache gems
ARG ALPINE_RUBY_VERSION=2.7.3
ARG BUNDLER_VERSION=2.2.22
ARG NODE_VERSION=v16.13.0 # Should exists for alpine, see https://unofficial-builds.nodejs.org/download/release/
ARG USER=decidim
ARG USER_UID=1000
ARG GROUP=admin
ARG GROUP_UID=1000

########################################################################
# Dependancy layer
########################################################################
FROM ruby:${ALPINE_RUBY_VERSION}-alpine  AS dependancy
ARG BUNDLER_VERSION
ARG NODE_VERSION
ARG USER

ENV USER=$USER 

ENV BUNDLER_VERSION=$BUNDLER_VERSION \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3 \
    NODE_VERSION=$NODE_VERSION \
    RAILS_ROOT=/home/$USER/app \ 
    NVM_DIR=/usr/local/nvm \
    NVM_NODEJS_ORG_MIRROR=https://unofficial-builds.nodejs.org/download/release \
    NVM_ARCH=x64-musl  \
    RAILS_ENV=production \
    RACK_ENV=production

ENV PATH=$PATH:$NVM_DIR

WORKDIR $RAILS_ROOT

RUN mkdir -p $NVM_DIR

# Install dependencies:
# - build-base: To ensure certain gems can be compiled
# - postgresql-dev postgresql-client: Communicate with postgres through the postgres gem
# - libxslt-dev libxml2-dev: Nokogiri native dependencies
# - imagemagick: for image processing
# - git: for gemfiles using git 
# - bash curl: to download nvm and install it
# - libstdc++: to build NVM
RUN apk update && apk upgrade && \
    gem update --system && \
    gem install bundler --version "$BUNDLER_VERSION" && \
    apk --update --no-cache add \
        build-base \
        tzdata \
        postgresql-dev postgresql-client \
        libxslt-dev libxml2-dev \
        imagemagick \
        git \
        bash curl \
        libstdc++ \
        && rm -rf /var/cache/apk/*

# Install nvm, to have the approriate node version to compile assets
RUN touch $RAILS_ROOT/.profile && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash; \
    source $NVM_DIR/nvm.sh; \
    echo "nvm_get_arch() { nvm_echo \"x64-musl\"; }" >> $RAILS_ROOT/.profile; source $RAILS_ROOT/.profile;\
    nvm install $NODE_VERSION

# Install gems
COPY Gemfile Gemfile.lock ./

# Configure bundler path, and install gems if needed (dev, test and production)
RUN bundle config set without 'development test' && \
    bundle install && \
    rm -rf /usr/local/bundle/cache/ /usr/local/bundle/bundler/gems/*/.git

COPY . ./

# Pre-compile assets
RUN source $NVM_DIR/nvm.sh; nvm use $NODE_VERSION && \
    SECRET_KEY_BASE=assets bundle exec rails assets:precompile
    
########################################################################
# Final layer
########################################################################
FROM ruby:${ALPINE_RUBY_VERSION}-alpine
LABEL maintainer="hello@octree.ch"
ARG ALPINE_RUBY_VERSION
ARG BUNDLER_VERSION
ARG USER
ARG USER_UID
ARG GROUP
ARG GROUP_UID

ENV USER=$USER \
    USER_UID=$USER_UID \
    GROUP=$GROUP\
    GROUP_UID=$GROUP_UID \
    RAILS_ENV=production \
    RACK_ENV=production \
    TZ=Europe/Zurich \
    LANG=C.UTF-8 \
    RAILS_SERVE_STATIC_FILES=false \
    BUNDLER_VERSION=$BUNDLER_VERSION \
    RAILS_ROOT=/home/$USER/app

ENV PATH=$PATH:$RAILS_ROOT/bin

WORKDIR $RAILS_ROOT

RUN apk update && \
    apk upgrade && \
    gem update --system && \
    gem install bundler --version "$BUNDLER_VERSION" && \
    apk add --no-cache \
        postgresql-dev \
        tzdata \
        imagemagick \
        bash \
        vim \
        && rm -rf /var/cache/apk/*

# Create system user to run as non-root.
RUN addgroup -S $GROUP -g $GROUP_UID && \
    adduser -S -g '' -u $USER_UID -G $GROUP $USER

VOLUME /home/$USER/app/storage
VOLUME /home/$USER/app/public
VOLUME /home/$USER/app/log

# Copy app & gems
COPY --from=dependancy /usr/local/bundle/ /usr/local/bundle/
COPY --chown=$USER:$GROUP --from=dependancy /home/$USER/app ./

# Add imagemagick policy
RUN mv $RAILS_ROOT/.docker/imagemagick-policy.xml /etc/ImageMagick-7/policy.xml && \
    # Set bundle config again, to have passing bundle check
    bundle config set without 'development test'

# Switch to non-root system user
USER $USER

# Run bootsnap caching to load fast rails app
RUN bundle exec bootsnap precompile --gemfile app/ lib/

# Define bash as the default shell
SHELL ["/bin/bash", "-l", "-c"]

ENTRYPOINT [".docker/entrypoint.sh"]

CMD ["bundle", "exec", "rails", "server"]