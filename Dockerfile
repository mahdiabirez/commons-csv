# Apache Commons CSV - Analysis Environment Dockerfile
# Multi-stage build for optimized image size

# Stage 1: Build environment with full Maven cache
FROM eclipse-temurin:21-jdk AS build

# Install Maven
ARG MAVEN_VERSION=3.9.12
RUN apt-get update && \
    apt-get install -y wget && \
    wget https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    tar -xzf apache-maven-${MAVEN_VERSION}-bin.tar.gz -C /opt && \
    ln -s /opt/apache-maven-${MAVEN_VERSION} /opt/maven && \
    rm apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV MAVEN_HOME=/opt/maven
ENV PATH="${MAVEN_HOME}/bin:${PATH}"

# Set working directory
WORKDIR /app

# Copy only pom.xml first to leverage Docker layer caching
COPY pom.xml .

# Download dependencies (this layer will be cached if pom.xml doesn't change)
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Compile the code (skip tests during build)
RUN mvn compile test-compile -Drat.skip=true -B

# Stage 2: Runtime environment with reports
FROM eclipse-temurin:21-jdk

# Install minimal tools
RUN apt-get update && \
    apt-get install -y git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Maven (lighter version for runtime)
ARG MAVEN_VERSION=3.9.12
RUN apt-get update && \
    apt-get install -y wget && \
    wget https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    tar -xzf apache-maven-${MAVEN_VERSION}-bin.tar.gz -C /opt && \
    ln -s /opt/apache-maven-${MAVEN_VERSION} /opt/maven && \
    rm apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV MAVEN_HOME=/opt/maven
ENV PATH="${MAVEN_HOME}/bin:${PATH}"

WORKDIR /app

# Copy project files from build stage
COPY --from=build /app /app

# Create volume mount points for reports
VOLUME ["/app/target"]

# Default command: show available commands
CMD ["sh", "-c", "echo 'Apache Commons CSV - Analysis Environment'; \
     echo ''; \
     echo 'Available commands:'; \
     echo '  maven test                - Run all tests'; \
     echo '  mvn jacoco:report         - Generate coverage report'; \
     echo '  mvn pitest:mutationCoverage - Run mutation testing'; \
     echo '  mvn surefire-report:report - Generate test report'; \
     echo ''; \
     echo 'Reports will be saved to mounted /app/target volume'; \
     echo ''; \
     echo 'Example usage:'; \
     echo '  docker run -v $(pwd)/target:/app/target commons-csv mvn jacoco:report'; \
     echo ''; \
     mvn --version"]

# Labels for metadata
LABEL maintainer="Software Dependability Analysis"
LABEL description="Analysis environment for Apache Commons CSV"
LABEL java.version="21"
LABEL maven.version="3.9.12"
LABEL project="commons-csv"
LABEL version="1.14.2-SNAPSHOT"
