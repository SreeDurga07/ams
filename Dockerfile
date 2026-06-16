# Use Tomcat 10 with Java 17 (compatible with Jakarta EE)
FROM tomcat:10.1-jdk17-temurin

# Set working directory
WORKDIR /usr/local/tomcat

# Remove default applications
RUN rm -rf /usr/local/tomcat/webapps/*

# Add JDBC drivers. PostgreSQL is used by Render; MySQL remains useful locally.
RUN cd /usr/local/tomcat/lib && \
    wget -q https://jdbc.postgresql.org/download/postgresql-42.7.7.jar && \
    wget -q https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/9.3.0/mysql-connector-j-9.3.0.jar && \
    chmod 644 postgresql-42.7.7.jar mysql-connector-j-9.3.0.jar

# Assemble the webapp from tracked project files.
RUN mkdir -p /usr/local/tomcat/webapps/ROOT/css \
    /usr/local/tomcat/webapps/ROOT/js \
    /usr/local/tomcat/webapps/ROOT/includes \
    /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/com/ams/util \
    /usr/local/tomcat/webapps/ROOT/database
COPY *.jsp /usr/local/tomcat/webapps/ROOT/
COPY style.css /usr/local/tomcat/webapps/ROOT/css/style.css
COPY script.js /usr/local/tomcat/webapps/ROOT/js/script.js
COPY header.jsp /usr/local/tomcat/webapps/ROOT/includes/header.jsp
COPY footer.jsp /usr/local/tomcat/webapps/ROOT/includes/footer.jsp
COPY sidebar.jsp /usr/local/tomcat/webapps/ROOT/includes/sidebar.jsp
COPY web.xml /usr/local/tomcat/webapps/ROOT/WEB-INF/web.xml
COPY ams_schema.sql /usr/local/tomcat/webapps/ROOT/database/ams_schema.sql
COPY DBConnection.java /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/com/ams/util/DBConnection.java
COPY db.properties.docker /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/db.properties
COPY ams_schema_postgresql.sql /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/ams_schema_postgresql.sql
RUN javac -d /usr/local/tomcat/webapps/ROOT/WEB-INF/classes \
    /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/com/ams/util/DBConnection.java

# Expose Tomcat port
EXPOSE 8080

# Start Tomcat on Render's assigned port when provided.
CMD ["sh", "-c", "sed -i \"s/port=\\\"8080\\\"/port=\\\"${PORT:-8080}\\\"/\" /usr/local/tomcat/conf/server.xml && catalina.sh run"]
