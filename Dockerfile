#Dockerfile
FROM ruby:2.3.7 AS base
LABEL maintainer="Scott Bishop - ScottBishop70@gmail.com"
# Add encription key to decode secrets
ARG RAILS_MASTER_KEY

# Install tools & libs
RUN apt-get update && \
    apt-get install -y build-essential checkinstall libx11-dev libxext-dev zlib1g-dev libpng-dev libjpeg-dev libfreetype6-dev libxml2-dev nodejs && \
    apt-get install -y imagemagick libmagick++-dev libmagic-dev libmagickwand-dev vim libpq-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -f /etc/ImageMagick-6/policy.xml
# Remove file limits for ImageMagick for builds that calculate lots of diffs

WORKDIR /app
COPY Gemfile* ./
RUN gem install bundler && \
    bundle install

# Copy required files in
FROM base AS builder

COPY Rakefile LICENSE CONTRIBUTORS config.ru ./
COPY bin/ ./bin
COPY config/ ./config
COPY db/ ./db
COPY lib/ ./lib
COPY public/ ./public

# Copy frequently changed files last
COPY app/ ./app

# Precompile rails assets
RUN rake assets:precompile

# Resulting Docker Image
FROM base
COPY --from=builder /app /app

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
