# Build SPC Using Maven 
FROM maven:3.9.9-amazoncorretto-17 AS mvn 

# MAVEN ARG
ARG GIT_REPO=https://github.com/siddhaantkadu/spring-petclinic.git
ARG APP_DIR=/spring-petclinic

# Install Git and Clone Repo
RUN yum install -y git && git clone ${GIT_REPO} 

# Build Package 
WORKDIR ${APP_DIR}
RUN mvn -Dmaven.test.skip=true package 

# PROD Deployment 
FROM amazoncorretto:17-alpine3.17-jdk

LABEL author="siddhaantkadu"
LABEL application="springpetclinic"

# ENVIRONMENT VARS 
ARG USER="iaas"
ARG GROUP="iaas"
ARG USER_HOME="/home/iaas"
ARG HOME_DIR="/apps/opt/application/springpetclinic"
ARG PORT="8080"
ENV VERBOSE=module

# Create User & Group 
RUN adduser -h ${USER_HOME} -s /bin/bash -D ${USER}

# Switch to Function User 
USER ${USER}

# Copy Jar file to target 
COPY --chown=${USER}:${GROUP} --from=mvn /spring-petclinic/target/spring-petclinic-3.2.0-SNAPSHOT.jar ${HOME_DIR}/spring-petclinic.jar

WORKDIR ${HOME_DIR}

EXPOSE ${PORT}

CMD [ "java", "-jar", "spring-petclinic.jar" ]