FROM arm64v8/oraclelinux:8.10

# Manadatory Package installation + Create Volume
RUN yum -y --setopt=install_weak_deps=False --setopt=tsflags=nodocs install curl unzip java-17-headless python39 python39-pip \
  && yum clean all \
  && rm -rf /var/cache/yum /var/cache/dnf /tmp/* /var/tmp/* \
  && groupadd oinstall \
  && useradd -g oinstall oracle \
  && mkdir -p /u01/ords/ /u01/config_ords /u01/logs_ords /u01/certs /u01/passwords \
  && chown -R oracle:oinstall /u01 \
  && /usr/bin/python3.9 -m pip install --no-cache-dir oracledb

ENV ORDS_PATH="/u01/ords" \
    PATH=${PATH}:/u01/ords/bin:/usr/bin/python3.9

RUN curl -L -o "${ORDS_PATH}"/ords-25.4.0.364.1739.zip https://download.oracle.com/otn_software/java/ords/ords-25.4.0.364.1739.zip \
  && unzip "${ORDS_PATH}"/ords-25.4.0.364.1739.zip -d "${ORDS_PATH}" \
  && rm "${ORDS_PATH}"/*.zip

COPY --chown=oracle:oinstall --chmod=775 *.sh *.py "${ORDS_PATH}"

EXPOSE 8080 8443
# Switch User-Context to oracle - since it shouldn't run on root
USER oracle
CMD ["/u01/ords/startup_ords.sh"]