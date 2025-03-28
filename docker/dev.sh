#!/usr/bin/env bash

# Helper script for local development using Docker

set -e

DOCKER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${DOCKER_DIR}/.." && pwd)"

# Default locations 
export AUTOMQ_BUILD_DIR="${ROOT_DIR}/core/build/distributions/automq"
export AUTOMQ_DATA_DIR="${DOCKER_DIR}/dev-data"

# Create required directories
mkdir -p "${AUTOMQ_DATA_DIR}"

show_help() {
  cat <<EOF
AutoMQ Development Helper Script

Usage: ./dev.sh COMMAND [OPTIONS]

Commands:
  build           Build the AutoMQ artifacts locally
  up              Start the development environment
  down            Stop the development environment
  restart         Restart AutoMQ services after code changes
  logs [service]  View logs (optional: specify service name)
  help            Show this help message

Examples:
  ./dev.sh build           # Build AutoMQ locally
  ./dev.sh up              # Start the development environment
  ./dev.sh logs broker1    # View logs for broker1
  ./dev.sh restart         # Restart after code changes
EOF
}

build_artifacts() {
  echo "Building AutoMQ artifacts..."
  cd "${ROOT_DIR}"
  ./gradlew -Pprefix=automq- clean releaseTarGz
  
  # Clean previous extract
  rm -rf "${AUTOMQ_BUILD_DIR}"

  mkdir -p "${AUTOMQ_BUILD_DIR}/kafka"
  
  find "${ROOT_DIR}/core/build/distributions" -name "automq-*.tgz" -exec tar -xzf {} -C "${AUTOMQ_BUILD_DIR}/kafka" --strip-components=1 \;
  # Copy the scripts directory for running kafka
  cp -r "${DOCKER_DIR}/scripts" "${AUTOMQ_BUILD_DIR}/scripts"
  
  # Make sure all scripts are executable
  find "${AUTOMQ_BUILD_DIR}/scripts" -name "*.sh" -exec chmod +x {} \;
  
  echo "Build complete. Artifacts available at: ${AUTOMQ_BUILD_DIR}"
}

start_environment() {
  echo "Starting development environment..."
  cd "${DOCKER_DIR}"
  docker-compose -f docker-compose.yaml -f docker-compose.dev.yaml up -d --build
  echo "Development environment started."
  echo "Run './dev.sh logs' to see logs"
}

stop_environment() {
  echo "Stopping development environment..."
  cd "${DOCKER_DIR}"
  docker-compose -f docker-compose.yaml -f docker-compose.dev.yaml down
  echo "Development environment stopped."
}

restart_services() {
  echo "Restarting AutoMQ services..."
  cd "${DOCKER_DIR}"
  docker-compose -f docker-compose.yaml -f docker-compose.dev.yaml restart controller broker1 broker2
  echo "Services restarted."
}

view_logs() {
  cd "${DOCKER_DIR}"
  if [ -n "$1" ]; then
    docker-compose -f docker-compose.yaml -f docker-compose.dev.yaml logs -f "$1"
  else
    docker-compose -f docker-compose.yaml -f docker-compose.dev.yaml logs -f
  fi
}

# Process commands
case "$1" in
  build)
    build_artifacts
    ;;
  up)
    start_environment
    ;;
  down)
    stop_environment
    ;;
  restart)
    restart_services
    ;;
  logs)
    view_logs "$2"
    ;;
  help|--help|-h)
    show_help
    ;;
  *)
    echo "Unknown command: $1"
    show_help
    exit 1
    ;;
esac 