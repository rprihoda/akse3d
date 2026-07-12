# Multi-stage Dockerfile for Akse 3D Node.js app
# Uses SvelteKit with @sveltejs/adapter-static

# Stage 1: Build the application
FROM node:22-alpine AS builder

WORKDIR /app

# Copy package files
COPY package.json package-lock.json ./

# Install all dependencies (including devDependencies for build)
RUN npm ci

# Copy source files
COPY . .

# Build the app using vite
RUN npm run build

# Stage 2: Production image - lightweight static server
FROM node:22-alpine AS runner

WORKDIR /app

# Install a lightweight static server
RUN npm install -g serve

# Copy built files from builder
# SvelteKit with adapter-static outputs to build/ by default
COPY --from=builder /app/build ./build
COPY --from=builder /app/static ./static

# Expose port (default 3000 for serve)
EXPOSE 3000

# Run static server from build directory
CMD ["serve", "-s", "build", "-l", "3000"]
