# Container for developing and building God's Eye View.
#
#   docker compose up                          # dev server on http://localhost:4173
#   docker compose run --rm gev npm test       # any npm script, inside the image
#   docker compose run --rm gev npm run build
#
# The engines field wants Node 24.14+ or 26; the allocation benchmarks are
# calibrated on 24, so stay on 24.
FROM node:24-bookworm-slim

# puppeteer and sharp are dev dependencies. Chrome is only needed by the
# qa-*.mjs / test:track browser gates; skip the download and install a browser
# separately if you want to run those in the container.
ENV PUPPETEER_SKIP_DOWNLOAD=1 \
    HOST=0.0.0.0 \
    PORT=4173

# Several unit tests and the format/boundary/layer-token checks shell out to
# git (fixture repos, git ls-files), so the slim image needs it.
RUN apt-get update \
 && apt-get install -y --no-install-recommends git ca-certificates \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
RUN chown node:node /app
USER node

# Dependencies first so source edits do not invalidate this layer.
COPY --chown=node:node package.json package-lock.json ./
RUN npm ci

COPY --chown=node:node . .

EXPOSE 4173
CMD ["npm", "run", "dev"]
