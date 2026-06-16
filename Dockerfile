# Use Tomcat 10 with Java 17 (compatible with Jakarta EE)
FROM tomcat:10-jdk17-eclipse-temurin

# Set working directory
WORKDIR /usr/local/tomcat

# Remove default applications
RUN rm -rf /usr/local/tomcat/webapps/*

# Add PostgreSQL JDBC Driver (Render uses PostgreSQL)
# Download and add to Tomcat lib directory
RUN cd /usr/local/tomcat/lib && \
    wget https://jdbc.postgresql.org/download/postgresql-42.7.1.jar && \
    chmod 644 postgresql-42.7.1.jar

# Copy the AMS application to Tomcat webapps directory
COPY AMS_Website/ /usr/local/tomcat/webapps/ROOT/

# Copy db.properties with environment variable support (PostgreSQL)
COPY db.properties.docker /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/db.properties

# Expose Tomcat port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
