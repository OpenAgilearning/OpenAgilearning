
FROM node:latest

#####

# docker build -t liangcc/aglweb2 .

# docker run -it -p 3000:3000 liangcc/aglweb2 bash -c "cd /web/ && meteor --port 0.0.0.0:3000 --settings local_settings.json"


#####


ADD web/ /web


WORKDIR /web

EXPOSE 3000

RUN curl https://install.meteor.com | /bin/sh \
    && npm install -g fibers \
#    && meteor --port 0.0.0.0:3000 --settings deploy_settings.json
