FROM docker.mgkim.net/amazoncorretto:17-alpine-jdk-docker

# internal build
ARG APP_NAME
ARG NEXUS_USERNAME
ARG NEXUS_PASSWORD
ARG CLIENT_CERT_PASSWORD
RUN mkdir -p /root/.m2 && \
  cat > /root/.m2/settings.xml <<EOF
<settings>
  <servers>
    <server>
      <id>maven-releases</id>
      <username>${NEXUS_USERNAME}</username>
      <password>${NEXUS_PASSWORD}</password>
    </server>
    <server>
      <id>maven-snapshots</id>
      <username>${NEXUS_USERNAME}</username>
      <password>${NEXUS_PASSWORD}</password>
    </server>
  </servers>
</settings>
EOF
COPY client-cert.jks /root/.m2

WORKDIR /src
COPY pom.xml ./
COPY mvnw ./
COPY .mvn ./.mvn
RUN chmod +x ./mvnw
RUN ./mvnw dependency:go-offline -B


COPY src ./src
RUN ./mvnw clean deploy -DskipTests -B -s /root/.m2/settings.xml \
  -Djavax.net.ssl.keyStore=/root/.m2/client-cert.jks \
  -Djavax.net.ssl.keyStorePassword=${CLIENT_CERT_PASSWORD}
RUN mkdir -p /app \
  && cp -p /src/target/*.jar /app/sample-ci.jar

ENTRYPOINT ["java", "-jar", "/app/sample-ci.jar"]
