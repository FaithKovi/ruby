# syntax=docker/dockerfile:1
FROM ruby:3.3-alpine

# Install build and runtime dependencies
RUN apk add --no-cache \
    build-base \
    linux-headers \
    libpq-dev \
    postgresql-dev \
    nodejs \
    yarn \
    tzdata \
    git

# Set working directory
WORKDIR /app

# Install bundler
RUN gem install bundler --no-document

# Copy Gemfiles first for layer caching
COPY Gemfile Gemfile.lock ./

# Install gems (production mode)
RUN bundle config set without 'development test' && \
    bundle install --jobs 4 --retry 3

# Copy application files
COPY . .

# Precompile assets if it's a Rails app
RUN if [ -f "bin/rails" ]; then bundle exec rails assets:precompile; fi

# Expose Rails default port
EXPOSE 3000

# Start the app server (Puma)
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
