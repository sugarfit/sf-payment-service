FROM public.ecr.aws/docker/library/openjdk:21-bookworm

ARG APP_NAME

ARG ENVIRONMENT

ENV destination=/home/ubuntu/deployment

ADD ./${APP_NAME}-deploy/ ${destination}

RUN mkdir -p /logs/${APP_NAME}

WORKDIR ${destination}

ENV ENVIRONMENT=${ENVIRONMENT}

RUN chmod +x entrypoint.sh

ENTRYPOINT ./entrypoint.sh