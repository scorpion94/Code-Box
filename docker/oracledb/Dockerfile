FROM container-registry.oracle.com/database/free:latest

ENV APEX_PATH="/opt/oracle/apex_242"

RUN mkdir -p "${APEX_PATH}" \
    && curl -L -o "${APEX_PATH}"/apex_24.2_en.zip https://download.oracle.com/otn_software/apex/apex_24.2_en.zip \
    && unzip "${APEX_PATH}"/apex_24.2_en.zip -d "${APEX_PATH}" \
    && rm -f "${APEX_PATH}"/apex_24.2_en.zip



# Scripts must be copied into startup to be executed
COPY --chmod=775 apex_install.sh /opt/oracle/scripts/startup
COPY --chmod=775 apex_pw_workaround.sh "${APEX_PATH}"
