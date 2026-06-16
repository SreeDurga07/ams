# Use Tomcat 10 with Java 17 (compatible with Jakarta EE)
FROM tomcat:10-jdk17-eclipse-temurin

# Set working directory
WORKDIR /usr/local/tomcat

# Remove default applications
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the AMS application to Tomcat webapps directory
COPY AMS_Website/ /usr/local/tomcat/webapps/ROOT/

# Copy db.properties with environment variable support
COPY db.properties.docker /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/db.properties

# Expose Tomcat port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
