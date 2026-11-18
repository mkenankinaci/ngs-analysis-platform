FROM ensemblorg/ensembl-vep:release_116.3

USER root

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Istanbul
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV VEP_CACHE_DIR=/root/.vep
ENV SNPEFF_DATA_DIR=/data/reference/snpeff/data

SHELL ["/bin/bash", "-c"]

ARG GATK_VERSION=4.6.2.0

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    wget \
    curl \
    unzip \
    gzip \
    bzip2 \
    xz-utils \
    git \
    procps \
    iproute2 \
    net-tools \
    python3 \
    python3-pip \
    python3-venv \
    openjdk-17-jre-headless \
    openssh-server \
    bwa \
    samtools \
    fastqc \
    fastp \
    picard \
    bcftools \
    tabix \
    snpeff \
    && rm -rf /var/lib/apt/lists/*

RUN wget -O /tmp/gatk.zip \
    https://github.com/broadinstitute/gatk/releases/download/${GATK_VERSION}/gatk-${GATK_VERSION}.zip && \
    unzip /tmp/gatk.zip -d /opt && \
    ln -sf /opt/gatk-${GATK_VERSION}/gatk /usr/local/bin/gatk && \
    rm -f /tmp/gatk.zip

RUN if [ -f /opt/vep/src/ensembl-vep/vep ]; then \
      ln -sf /opt/vep/src/ensembl-vep/vep /usr/local/bin/vep; \
    elif [ -f /opt/vep/vep ]; then \
      ln -sf /opt/vep/vep /usr/local/bin/vep; \
    else \
      echo "VEP script not found" && exit 1; \
    fi && chmod +x /usr/local/bin/vep

RUN SNPEFF_JAR="$(find /usr/share /usr/lib -type f \( -iname 'snpEff.jar' -o -iname 'snpeff.jar' \) 2>/dev/null | head -n 1)" && \
    test -n "$SNPEFF_JAR" && \
    printf '#!/usr/bin/env bash\njava -Xmx8g -Ddata.dir=/data/reference/snpeff/data -jar "%s" "$@"\n' "$SNPEFF_JAR" > /usr/local/bin/snpEff && \
    chmod +x /usr/local/bin/snpEff

RUN mkdir -p /data /run/sshd /root/.vep
COPY sshd_config /usr/local/etc/sshd_config
COPY start-sshd.sh /usr/local/bin/start-sshd.sh
RUN chmod 0755 /usr/local/bin/start-sshd.sh

EXPOSE 22
WORKDIR /
ENTRYPOINT ["/usr/local/bin/start-sshd.sh"]
