# syntax=docker/dockerfile:1
FROM ruby:3.3-slim

# Install dependencies
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    nodejs \
    yarn && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install bundler
RUN gem install bundler --no-document

# Copy Gemfiles first for caching
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install --jobs 4 --retry 3

# Copy the rest of the app
COPY . .

# Precompile assets if it's a Rails app
RUN if [ -f "bin/rails" ]; then bundle exec rails assets:precompile; fi

# Expose app port
EXPOSE 3000

# Start server
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
