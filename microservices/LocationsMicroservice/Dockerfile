
FROM maven:3.9.5-eclipse-temurin-21 AS build

# Set working directory
WORKDIR /build

# Copy the Maven project files
COPY pom.xml .
COPY src ./src

# Build the application (skip tests if you want faster builds)
RUN mvn clean package -DskipTests

# Second stage: Run the app using Amazon Corretto JDK
FROM amazoncorretto:21

# Set working directory
WORKDIR /app

# Copy the built JAR from the builder stage
COPY --from=build /build/target/*.jar app.jar

# Set default command
ENTRYPOINT ["java", "-jar", "app.jar"]
