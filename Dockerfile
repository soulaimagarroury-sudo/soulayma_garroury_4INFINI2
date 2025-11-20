# Dockerfile - place this at the project root

# Stage 1: runtime image
FROM eclipse-temurin:17-jdk-jammy AS runtime

# Set working dir
WORKDIR /app

# Copy the built jar (Jenkins will produce target/*.jar)
# We copy a generic name so ENTRYPOINT is stable
COPY target/*.jar app.jar

# Expose the Spring Boot default port
EXPOSE 8080

# JVM options can be tuned here if needed
ENTRYPOINT ["java","-jar","/app/app.jar"]
