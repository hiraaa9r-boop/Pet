# backend/Dockerfile
# Multi-stage build for MyPetCare Backend (Optimized for Cloud Run)

# Stage 1: Build TypeScript
FROM node:20-alpine AS builder

WORKDIR /usr/src/app

# Copy package files
COPY package*.json ./
COPY tsconfig.json ./

# Install ALL dependencies (including devDependencies for build)
RUN npm ci

# Copy source code
COPY src ./src

# Build TypeScript → JavaScript
RUN npm run build

# Stage 2: Production Runtime
FROM node:20-alpine

WORKDIR /usr/src/app

# Copy package files
COPY package*.json ./

# Install ONLY production dependencies
RUN npm ci --only=production && npm cache clean --force

# Copy built JavaScript from builder stage
COPY --from=builder /usr/src/app/dist ./dist

# Environment variables for production
ENV NODE_ENV=production
ENV PORT=8080

# Expose port (Cloud Run uses PORT env variable)
EXPOSE 8080

# Health check endpoint (ogni 30s, timeout 3s)
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:8080/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Run as non-root user for security
USER node

# Start the server
CMD ["node", "dist/index.js"]
