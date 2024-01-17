FROM amazoncorretto:17-alpine3.17-jdk

# LABELS
LABEL author="siddhant"
LABEL project="spring-pet-clinic"

# ARGUMENTS 
ARG USER="iaas"
ARG GROUP="iaas"
ARG UID="1000"
ARG GID="1000"
ARG USER_HOME="petclinic"

RUN addgroup -g ${UID} ${USER} && \
    adduser -h "/${USER_HOME}" -u ${GID} -G ${GROUP} -s /bin/bash -D ${USER}

USER ${USER}
WORKDIR /${USER_HOME}

ADD --chown=${USER}:${GROUP} **/Spring*.jar /${USER_HOME}/spring-petclinic-3.2.0.jar
