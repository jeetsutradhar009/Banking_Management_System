# Stage 1: Maven se project ko build karenge
FROM maven:3.8.5-openjdk-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package

# Stage 2: Tomcat 10 par project ko run karenge
FROM tomcat:10.1-jdk17
# WAR file ko ROOT.war bana kar copy karenge taaki website direct main link par khule
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
CMD ["catalina.sh", "run"]