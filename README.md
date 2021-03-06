Learning Data With Dockers
===========================

### [live demo website](http://dockerhack2014.opennote.info/)

###Contribute

type in following command to start develope

```
NODE_TLS_REJECT_UNAUTHORIZED=0 MONGO_URL=mongodb://localhost:27017/dockerdata meteor --port 0.0.0.0:3000 --settings local_settings.json
```

###Import testing data

```{shell}

mongoimport --db MONGO_DB_NAME --host MONGODB_PORT --collection MONGODB_COLLECTION --port MONGODB_PORT --file /data/*.json

```

optional attribute:

* --upsert


### Dockerize Meteor

Before you started, please put all .pem files in `dockerServerCAs/` directory. 

```
    docker build -t agilearning .

    ## Run a mongodb container
    docker run --name mongo -v YOUR_MONGO_DB_DIRECTORY:/data -d mongo
    examlpe: docker run --name mongo -v $PWD/mongo_space:/data -d mongo

    ## Run your nodejs container
    #### MUST use the name "mongodb"!
    docker run --link mongo:mongodb -it -p 3000:3000 agilearning

    #### MAC users should specify HOST:
    docker run --env HOST=dockerhost --link mongo:mongodb -it -p 3000:3000 agilearning
```
The sucessful run prints no message on terminal, check the browser directly.

####Reference
http://docs.mongodb.org/manual/reference/program/mongoimport/
