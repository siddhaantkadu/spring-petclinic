FROM amazoncorretto:17-alpine3.17-jdk
LABEL author="siddhant"
LABEL project="spring-pet-clinic"
ARG USER="iaas"
ARG GROUP="iaas"
ARG UID="1000"
ARG GID="1000"
ARG USER_HOME="petclinic"
RUN addgroup -g ${UID} ${USER} && \
    adduser -h "/${USER_HOME}" -u ${GID} -G ${GROUP} -s /bin/bash -D ${USER}
USER ${USER}
