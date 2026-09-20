# syntax=docker/dockerfile:1
# check=error=true



ARG RUBY_VERSION=4.0.7

# Node only builds the AgentPrism viewer.
FROM docker.io/library/node:24.21.0-slim AS agent-assets
WORKDIR /build
COPY package.json package-lock.json .npmrc ./
RUN npm ci
COPY vendor/agent-prism ./vendor/agent-prism
COPY app/frontend/agents ./app/frontend/agents
COPY app/javascript/live_updates.js ./app/javascript/live_updates.js
COPY config/agent_prism_tailwind.cjs ./config/agent_prism_tailwind.cjs
COPY script/build-agents.mjs ./script/build-agents.mjs
COPY tsconfig.agents.json ./
RUN npm run build:agents

FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips postgresql-client && \
    ln -s /usr/lib/$(uname -m)-linux-gnu/libjemalloc.so.2 /usr/local/lib/libjemalloc.so && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    LD_PRELOAD="/usr/local/lib/libjemalloc.so"

FROM base AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libvips libyaml-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY Gemfile Gemfile.lock .ruby-version ./

RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    # -j 1 disable parallel compilation to avoid a QEMU bug: https://github.com/rails/bootsnap/issues/495
    bundle exec bootsnap precompile -j 1 --gemfile

COPY . .
COPY --from=agent-assets /build/app/assets/builds/ ./app/assets/builds/

# -j 1 disable parallel compilation to avoid a QEMU bug: https://github.com/rails/bootsnap/issues/495
RUN bundle exec bootsnap precompile -j 1 app/ lib/

RUN WEB_HOST=build.invalid SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile




FROM base

RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash
USER 1000:1000

COPY --chown=rails:rails --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --chown=rails:rails --from=build /rails /rails

ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]
