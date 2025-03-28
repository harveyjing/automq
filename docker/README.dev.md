# Development Environment Setup for AutoMQ

This directory contains a Docker Compose-based development environment for AutoMQ. It allows you to compile code locally and test changes without rebuilding the Docker image.

## Prerequisites

- Docker and Docker Compose
- JDK 17
- Gradle

## Getting Started

### Step 1: Build the AutoMQ artifacts locally

Run the following command to build the AutoMQ artifacts locally:

```bash
./dev.sh build
```

This will:
1. Run the Gradle build process
2. Generate the automq-*.tgz file
3. Extract the tarball to a location that will be mounted into the container

### Step 2: Start the development environment

Run the following command to start the development environment:

```bash
./dev.sh up
```

This will:
1. Build the development Docker image
2. Start the containers (controller, broker1, broker2, localstack, etc.)
3. Mount your local build artifacts into the containers

### Step 3: Viewing logs

To view logs from the containers:

```bash
./dev.sh logs
```

To view logs for a specific service:

```bash
./dev.sh logs broker1
```

## Development Workflow

1. Make code changes locally
2. Rebuild the artifacts:
   ```bash
   ./dev.sh build
   ```
3. Restart the services to apply changes:
   ```bash
   ./dev.sh restart
   ```

## Stopping the Environment

To stop the development environment:

```bash
./dev.sh down
```

## Configuration

The development environment uses the following environment variables:

- `AUTOMQ_BUILD_DIR`: Directory containing the extracted AutoMQ artifacts (default: `../core/build/distributions/automq`)
- `AUTOMQ_DATA_DIR`: Directory for persistent data (default: `./dev-data`)

You can override these by setting the environment variables before running the commands:

```bash
export AUTOMQ_BUILD_DIR=/path/to/build/output
./dev.sh up
```

## Troubleshooting

- If you encounter issues with mounting directories, make sure the paths exist and have the correct permissions.
- If a service fails to start, check the logs for that specific service.
- To rebuild the development Docker image, run `./dev.sh up --build`.

## Architecture

This development setup:
1. Uses a minimal base image with Java 17 and required dependencies
2. Mounts your locally built artifacts (extracted from the tarball) into the container
3. Uses the extracted configuration from the tarball
4. Supports fast iteration by only requiring recompilation of code, not rebuilding of Docker images 