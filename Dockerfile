FROM joshmahowald/cloud-workstation AS baseworkstation



FROM ruby:alpine
RUN apk --no-cache --update add bash  \
  ca-certificates openssl openssh && update-ca-certificates  


ENV PROJ_DIR=/usr/local/src/kitchen-terraform
WORKDIR $PROJ_DIR
ADD Gemfile .
ADD kitchen-terraform.gemspec .
ADD lib ./lib
RUN apk add --virtual .build-deps gcc libc-dev make 
RUN bundle install && apk del .build-deps



COPY docker-entry.sh /usr/local/bin
COPY --from=baseworkstation /usr/local/bin/terraform /usr/local/bin/ 
COPY --from=baseworkstation /usr/local/bin/docker /usr/local/bin/ 
RUN chmod 755 /usr/local/bin/docker-entry.sh

WORKDIR /workspace
ENTRYPOINT ["/usr/local/bin/docker-entry.sh", "kitchen"]
CMD = ["info"]