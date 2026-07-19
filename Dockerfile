# syntax=docker/dockerfile:1

# ---------- Stage 1: install deps + build ----------
FROM node:20-alpine AS build
WORKDIR /app

# Copy manifests first so npm ci is cached unless deps change
COPY app/package*.json ./
RUN npm ci --omit=dev

COPY app/ .

# ---------- Stage 2: minimal runtime image ----------
FROM node:20-alpine AS production

# Patch OS packages, then drop the package cache
RUN apk update && apk upgrade && rm -rf /var/cache/apk/*

# Non-root user/group (Alpine images run as root by default)
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Only copy what's needed to run the app — no build tools, no dev deps
COPY --from=build --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=build --chown=appuser:appgroup /app/package*.json ./
COPY --from=build --chown=appuser:appgroup /app/server.js ./

USER appuser

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', r => process.exit(r.statusCode===200?0:1)).on('error', () => process.exit(1))"

ENTRYPOINT ["node", "server.js"]
