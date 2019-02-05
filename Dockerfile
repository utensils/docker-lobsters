# Lobsters
#
# VERSION latest

FROM ruby:2.3-alpine

# Setting this to true will retain linux
# build tools and dev packages.
ARG developer_build=false
# Args for labels.
ARG VCS_REF
ARG BUILD_DATE

#Labels
LABEL maintainer="James Brink, brink.james@gmail.com" \
      decription="Lobsters Rails Project" \
      version="latest" \
      org.label-schema.name="lobsters" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/jamesbrink/docker-lobsters" \
      org.label-schema.schema-version="1.0.0-rc1"

# Create lobsters user and group.
RUN addgroup -S lobsters && adduser -S -h /lobsters -s /bin/sh -G lobsters lobsters

# Copy Gemfile to container.
COPY ./lobsters/Gemfile ./lobsters/Gemfile.lock /lobsters/

# Install needed runtime & development dependencies. If this is a developer_build we don't remove
# the build-deps after doing a bundle install.
RUN set -xe; \
    chown -R lobsters:lobsters /lobsters; \
    apk add --no-cache --update --virtual .runtime-deps \
        mariadb-connector-c \
        nodejs \
        npm \
        sqlite-libs \
        tzdata; \
    apk add --no-cache --virtual .build-deps \
        bash \
        build-base \
        curl \
        gcc \
        git \
        gnupg \
        linux-headers \
        mariadb-connector-c-dev \
        mariadb-dev \
        sqlite-dev; \
    export PATH=/lobsters/.gem/ruby/2.3.0/bin:$PATH; \
    export GEM_HOME="/lobsters/.gem"; \
    export GEM_PATH="/lobsters/.gem"; \
    export BUNDLE_PATH="/lobsters/.bundle"; \
    cd /lobsters; \
    su lobsters -c "gem install bundler --user-install"; \
    su lobsters -c "bundle install --no-cache"; \
    su lobsters -c "bundle add puma"; \
    if [ "$developer_build" != "true" ]; \
    then \
        apk del .build-deps; \
    fi; \
    mv /lobsters/Gemfile /lobsters/Gemfile.bak; \
    mv /lobsters/Gemfile.lock /lobsters/Gemfile.lock.bak;

# Copy lobsters into the container.
COPY ./lobsters ./docker-assets /lobsters/

# Set proper permissions and move assets and configs.
RUN set -xe; \
    mv /lobsters/Gemfile.bak /lobsters/Gemfile; \
    mv /lobsters/Gemfile.lock.bak /lobsters/Gemfile.lock; \
    chown -R lobsters:lobsters /lobsters; \
    mv /lobsters/docker-entrypoint.sh /usr/local/bin/; \
    chmod 755 /usr/local/bin/docker-entrypoint.sh; \
    rm /lobsters/Gemfile.lock;

# Drop down to unprivileged users
USER lobsters

# Set our working directory.
WORKDIR /lobsters/

# Set environment variables.
ENV MARIADB_HOST="mariadb" \
    MARIADB_PORT="3306" \
    MARIADB_PASSWORD="password" \
    MARIADB_USER="root" \
    LOBSTER_DATABASE="lobsters" \
    LOBSTER_HOSTNAME="localhost" \
    LOBSTER_SITE_NAME="Example News" \
    RAILS_ENV="development" \
    SECRET_KEY="" \
    GEM_HOME="/lobsters/.gem" \
    GEM_PATH="/lobsters/.gem" \
    BUNDLE_PATH="/lobsters/.bundle" \
    RAILS_MAX_THREADS="5" \
    SMTP_HOST="127.0.0.1" \
    SMTP_PORT="25" \
    SMTP_STARTTLS_AUTO="true" \
    SMTP_USERNAME="lobsters" \
    SMTP_PASSWORD="lobsters" \
    RAILS_LOG_TO_STDOUT="1" \
    PATH="/lobsters/.gem/ruby/2.3.0/bin:$PATH"

# Expose HTTP port.
EXPOSE 3000

# Execute our entry script.
CMD ["/usr/local/bin/docker-entrypoint.sh"]
