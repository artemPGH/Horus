FROM eclipse-temurin:21-jre-jammy

ARG MINECRAFT_VERSION=1.21.1
ARG FABRIC_INSTALLER_VERSION=1.0.1

WORKDIR /app

RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*

RUN curl -L -o installer.jar "https://maven.fabricmc.net/net/fabricmc/fabric-installer/${FABRIC_INSTALLER_VERSION}/fabric-installer-${FABRIC_INSTALLER_VERSION}.jar" && \
    java -jar installer.jar server -mcversion ${MINECRAFT_VERSION} -downloadMinecraft && \
    rm -f installer.jar

COPY server.properties /app/server.properties
COPY ops.json /app/ops.json
COPY whitelist.json /app/whitelist.json
COPY mods/ /app/mods/
COPY config/ /app/config/
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

VOLUME ["/data"]
EXPOSE 25565

ENV EULA=FALSE
ENTRYPOINT ["/entrypoint.sh"]
