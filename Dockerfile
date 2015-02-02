
FROM node

#####

# docker build -t agilearning .

# docker run -it -p 3000:3000 agilearning bash -c "cd /var/www/app/ && node bundle/main.js "


#####


ADD web/ /web

WORKDIR /web

RUN curl https://install.meteor.com | /bin/sh \
    && meteor build --directory /var/www/app

WORKDIR /var/www/app

RUN cd bundle/programs/server && npm install

ENV MONGO_URL=mongodb://agilemongo:27017/agilearning \
    ROOT_URL=http://0.0.0.0 \
    PORT=3000

EXPOSE 3000

#CMD node ./bundle/main.js