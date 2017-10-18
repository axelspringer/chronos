FROM axelspringer/mesos:1.4.0 as build

ARG CHRONOS_VERSION
ENV VERSION ${CHRONOS_VERSION:-3.0.2}

RUN \
    # Update the packages.
    apt-get -y update && \
    # Install neat tools
    apt-get install -y tar wget git ca-certificates-java && \
    # Install a few utility tools.
    apt-get install -y openjdk-8-jdk && \
    # Install the latest OpenJDK.
    apt-get install -y autoconf libtool && \
    # Install other Mesos dependencies.
    apt-get -y --no-install-recommends install ant maven build-essential && \
    # Install Node.js
    wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.5/install.sh | bash && \
    export NVM_DIR="$HOME/.nvm" && \
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \
    nvm install stable && \
    # Download chronos
    wget -L -O /tmp/chronos.tar.gz  https://github.com/mesos/chronos/archive/v${VERSION}.tar.gz && \
    # Extract
    tar -xzvf /tmp/chronos.tar.gz -C /tmp && \
    # Change to directory and deploy
    cd /tmp/chronos-${VERSION} && mvn package -Dmaven.test.skip

FROM axelspringer/mesos:1.4.0
MAINTAINER Sebastian Doell <sebastian.doell@axelspringer.com>

ARG CHRONOS_VERSION
ENV VERSION ${CHRONOS_VERSION:-3.0.2}

COPY \
      --from=build /tmp/chronos-${VERSION}/target/chronos-3.0.1-SNAPSHOT.jar /chronos/chronos.jar

ADD \
    init.sh /

RUN \
    # Chmod
    chmod +x /init.sh && \
    # Update repositories
    apt-get -y update && \
    # Install neat tools
    apt-get install -y ca-certificates-java && \
    # jdk setup
    /var/lib/dpkg/info/ca-certificates-java.postinst configure && \
    ln -svT "/usr/lib/jvm/java-8-openjdk-$(dpkg --print-architecture)" /docker-java-home && \
    # clean up
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 8080

ENV JAVA_HOME /docker-java-home
ENTRYPOINT ["/init.sh"]