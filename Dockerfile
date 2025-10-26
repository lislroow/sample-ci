FROM docker.mgkim.net/amazoncorretto:17-alpine-jdk-docker

# internal build
ARG APP_NAME
ARG CLIENT_CERT_PASSWORD
RUN mkdir -p /root/.m2
COPY settings.xml /root/.m2
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
