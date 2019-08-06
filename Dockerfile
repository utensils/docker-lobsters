# Lobsters
#
# VERSION latest
ARG BASE_IMAGE=ruby:2.3-alpine
FROM ${BASE_IMAGE}

# Create lobsters user and group.
RUN set -xe; \
    addgroup -S lobsters; \
    adduser -S -h /lobsters -s /bin/sh -G lobsters lobsters;

# Install needed runtime dependencies.
RUN set -xe; \
    chown -R lobsters:lobsters /lobsters; \
    apk add --no-cache --update --virtual .runtime-deps \
        mariadb-connector-c \
        bash \
        nodejs \
        npm \
        sqlite-libs \
        tzdata;

# Change shell to bash
SHELL ["/bin/bash", "-c"]

# Install needed development dependencies. If this is a developer_build we don't remove
# the build-deps after doing a bundle install.
# Copy Gemfile to container.
COPY --chown=lobsters:lobsters ./lobsters/Gemfile ./lobsters/Gemfile.lock /lobsters/
ARG DEVELOPER_BUILD=false
RUN set -xe; \
    apk add --no-cache --virtual .build-deps \
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
    export SUPATH=$PATH; \
    export GEM_HOME="/lobsters/.gem"; \
    export GEM_PATH="/lobsters/.gem"; \
    export BUNDLE_PATH="/lobsters/.bundle"; \
    cd /lobsters; \
    su lobsters -c "gem install bundler --user-install"; \
    su lobsters -c "gem update"; \
    su lobsters -c "gem install rake -v 12.3.2"; \
    su lobsters -c "bundle install --no-cache"; \
    su lobsters -c "bundle add puma --version '~> 3.12.1'"; \
    if [ "${DEVELOPER_BUILD,,}" != "true" ]; \
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
    chmod 755 /usr/local/bin/docker-entrypoint.sh;

# Drop down to unprivileged users
USER lobsters

# Set our working directory.
WORKDIR /lobsters/

# Build arguments.
ARG VCS_REF
ARG BUILD_DATE
ARG VERSION

# Labels / Metadata.
LABEL \
    org.opencontainers.image.authors="James Brink <brink.james@gmail.com>" \
    org.opencontainers.image.created="${BUILD_DATE}" \
    org.opencontainers.image.description="Lobsters Rails Project" \
    org.opencontainers.image.revision="${VCS_REF}" \
    org.opencontainers.image.source="https://github.com/utensils/docker-lobsters" \
    org.opencontainers.image.title="lobsters" \
    org.opencontainers.image.vendor="Utensils" \
    org.opencontainers.image.version="${VERSION}"

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
