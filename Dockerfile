##### Instructions:

#### please put all .pem files in `web/` directory. 

# docker build -t agilearning .

# ## Run a mongodb container
# docker run --name mongo -v YOUR_MONGO_DB_DIRECTORY:/data -d mongo
# examlpe: docker run --name mongo -v $PWD/mongo_space:/data -d mongo

# ## Run your nodejs container
# #### MUST use the name "mongodb"!
# docker run --link mongo:mongodb -it -p 3000:3000 agilearning bash -c "cd /var/www/app/ && MONGO_URL=mongodb://\${MONGODB_PORT_27017_TCP_ADDR}:27017/agilearning node bundle/main.js "

# ## The sucessful run prints no message on terminal, check the browser at localhost:3000 directly.

#####

FROM node

ADD web/ /web
ADD dockerServerCAs/ /CAs

RUN rm -r web/.meteor/local

WORKDIR /web

RUN curl https://install.meteor.com | /bin/sh \
    && meteor build --directory /var/www/app

WORKDIR /var/www/app

RUN cd bundle/programs/server && npm install

ENV ROOT_URL http://0.0.0.0
ENV PORT 3000 
ENV NODE_TLS_REJECT_UNAUTHORIZED 0 
ENV METEOR_SETTINGS {"public":{"redirectTo": "0.0.0.0:3000","DOCKER_CERT_PATH":"/CAs/","environment": "production"}}

EXPOSE 3000

CMD node ./bundle/main.js
