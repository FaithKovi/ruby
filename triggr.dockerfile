FROM ruby:3.3-alpine

# Install dependencies for Ruby, Rails, and native extensions
RUN apk add --no-cache \
    build-base \
    libpq-dev \
    postgresql-dev \
    nodejs \
    yarn \
    tzdata \
    git \
    yaml-dev

WORKDIR /app

# Install bundler
RUN gem install bundler --no-document

# Install gems (cached by Gemfile first)
COPY Gemfile Gemfile.lock ./
RUN bundle config set without 'development test' && \
    bundle install --jobs 4 --retry 3

# Copy app source
COPY . .

# Precompile assets if Rails
RUN if [ -f "bin/rails" ]; then bundle exec rails assets:precompile; fi

EXPOSE 3000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
