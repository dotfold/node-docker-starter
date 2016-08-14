FROM mhart/alpine-node:6
MAINTAINER "James McNamee <james@dotfold.io>"

COPY app/ /app/
WORKDIR /app

RUN npm install
RUN chmod +x /app/run.sh

EXPOSE 8800
CMD ["/app/run.sh"]
