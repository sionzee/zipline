FROM node:22-alpine3.21 AS base

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

RUN npm install -g corepack && \
    corepack enable pnpm && \
    corepack prepare pnpm@latest --activate && \
    apk add --no-cache ffmpeg tzdata

WORKDIR /zipline

COPY prisma ./prisma
COPY package.json .
COPY pnpm-lock.yaml .

# Install dependencies
RUN pnpm install --prod --frozen-lockfile

# Copy source files
COPY src ./src
COPY next.config.js ./next.config.js
COPY tsup.config.ts ./tsup.config.ts
COPY tsconfig.json ./tsconfig.json
COPY mimes.json ./mimes.json
COPY code.json ./code.json

# Set environment variables
ENV NEXT_TELEMETRY_DISABLED=1 \
    NODE_ENV=production

# Build the application
RUN ZIPLINE_BUILD=true pnpm run build && \
    pnpm build:prisma

# Clean up
RUN rm -rf /tmp/* /root/*

CMD ["node", "--enable-source-maps", "build/server"]
