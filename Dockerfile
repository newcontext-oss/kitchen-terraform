FROM joshmahowald/cloud-workstation AS baseworkstation



FROM ruby:alpine
RUN apk --update add bash  \
  ca-certificates openssl && update-ca-certificates  


ENV PROJ_DIR=/usr/local/src/kitchen-terraform
WORKDIR $PROJ_DIR

RUN apk add --virtual build-deps gcc libc-dev make

ADD . ${PROJ_DIR}
COPY docker-entry.sh /usr/local/bin
RUN bundle install

RUN apk add --no-cache openssh 
COPY --from=baseworkstation /usr/local/bin/terraform /usr/local/bin/ 
COPY --from=baseworkstation /usr/local/bin/docker /usr/local/bin/ 

RUN chmod 755 /usr/local/bin/docker-entry.sh
ENTRYPOINT ["/usr/local/bin/docker-entry.sh"]