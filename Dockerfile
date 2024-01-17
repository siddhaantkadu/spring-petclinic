FROM amazoncorretto:17-alpine3.17-jdk

# LABELS
LABEL author="siddhant"
LABEL project="spring-pet-clinic"

COPY **/spring-petclinic-*.jar /spring-petclinic-3.2.0.jar
EXPOSE 8080
ENTRYPOINT [ "java", "-jar" ]
CMD [ "spring-petclinic-3.2.0.jar" ]