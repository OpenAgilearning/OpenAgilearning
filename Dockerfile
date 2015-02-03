##### Instructions:

#### Before you started, please put all .pem files in `dockerServerCAs/` directory. 

# docker build -t agilearning .

# ## Run a mongodb container
# docker run --name mongo -v YOUR_MONGO_DB_DIRECTORY:/data -d mongo
# examlpe: docker run --name mongo -v $PWD/mongo_space:/data -d mongo

# ## Run your nodejs container
# #### MUST use the name "mongodb"!
# docker run --link mongo:mongodb -it -p 3000:3000 agilearning

# #### MAC users should specify HOST:
# docker run --env HOST=dockerhost --link mongo:mongodb -it -p 3000:3000 agilearning

# ## The sucessful run prints no message on terminal, check the browser directly.

#####

FROM node

ADD web/ /web
ADD dockerServerCAs/ /CAs

RUN rm -rf web/.meteor/local

WORKDIR /web

RUN curl https://install.meteor.com | /bin/sh \
    && meteor build --directory /var/www/app

WORKDIR /var/www/app

RUN cd bundle/programs/server && npm install

ENV PORT 3000

EXPOSE 3000

ADD docker_run.sh /var/www/app/docker_run.sh

CMD sh docker_run.sh
