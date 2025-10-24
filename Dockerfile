FROM docker.mgkim.net/amazoncorretto:17-alpine-jdk-docker
WORKDIR /app
COPY ./target/sample-ci.jar /app
ENTRYPOINT ["/bin/bash", "-c", "\
java -jar /app/sample-ci.jar"]
