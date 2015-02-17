@dockerPull = {}




@dockerPull.DoingJobHandler = ()->
  dockerServerNames = db.dockerServers.find().fetch().map (xx) -> xx.name
  dockerPullDoingJobs = db.dockerPullImageJob.find({serverName:{$in:dockerServerNames},status:"Doing"}).fetch()
  
  dockerPullDoingJobs.map (job) ->
      
    if db.dockerPullImageStream.find({jobId:job._id,error:{"$exists":true}}).count() > 0
      updateData = 
        errorAt: new Date
        updatedAt: new Date
        status: "Error"

      db.dockerPullImageJob.update {_id:job._id}, {$set:updateData}

    else
      updateData = 
        updatedAt: new Date
        streamCount: db.dockerPullImageStream.find({jobId:job._id}).count()
      
      if job.streamCount < updateData.streamCount
        db.dockerPullImageJob.update {_id:job._id}, {$set:updateData}
      
      else
        if db.dockerServerImages.find({serverName:job.serverName,tag:job.imageTag}).count() > 0
          updateData = 
            doneAt: new Date
            updatedAt: new Date
            status: "Done"
          
          db.dockerPullImageJob.update {_id:job._id}, {$set:updateData}

        # else
        #   updateData = 
        #     errorAt: new Date
        #     updatedAt: new Date
        #     status: "Error:MaybeCallbackDisconnect"

        #   db.dockerPullImageJob.update {_id:job._id}, {$set:updateData}



@dockerPull.ToDoJobHandler = () ->
  dockerServerNames = db.dockerServers.find().fetch().map (xx) -> xx.name
  dockerPullToDoJobs = db.dockerPullImageJob.find({serverName:{$in:dockerServerNames},status:"ToDo"}).fetch()
  
  MONGO_URL = process.env.MONGO_URL
  
  dockerServerSettings = getDockerServerConnectionSettings "localhost"

  Docker = Meteor.npmRequire "dockerode"
  docker = new Docker dockerServerSettings

  if MONGO_URL
    dockerPullToDoJobs.map (job) ->
      serverName = job.serverName
      jobId = job._id

      updateData = 
        DoingAt: new Date
        updatedAt: new Date
        streamCount: 0
        status: "Doing"
      db.dockerPullImageJob.update {_id:jobId}, {$set:updateData}

      docker.pull job.imageTag, (err, stream) ->
        Meteor.npmRequire "dockerode"

        JSONStream = Meteor.npmRequire('JSONStream')
        parser = JSONStream.parse()
        
        options = 
          db: MONGO_URL
          collection: 'dockerPullImageStream'

        streamToMongo = Meteor.npmRequire('stream-to-mongo')(options)

        
        # MongoWritableStream = Meteor.npmRequire('mongo-writable-stream')

        # streamToMongo = new MongoWritableStream
        #   url: MONGO_URL
        #   collection: 'dockerPullImageStream'
        #   upsert: true
        #   upsertFields: ['id',"jobId","status","error"] 


        if not err
          addJobInfo = (data) ->
            data["jobId"] = jobId
            data["logAt"] = new Date
            # console.log data
            # db.dockerPullImageStream.upsert {id:data.id,jobId:jobId}, data
            data
          stream.pipe(parser).on("data",addJobInfo).pipe(streamToMongo)
        else
          console.log err


@dockerPull.progressMonitor = ->
  agg1 = 
    $group:
      _id:
        id:"$id",
        jobId:"$jobId",
      status:
        $addToSet:"$status"

      progress:
        $max:
          $divide:["$progressDetail.current","$progressDetail.total"]

  agg2 = 
    $sort:
      progress:1

  pipeline = [agg1, agg2]

  console.log db.dockerPullImageStream.aggregate(pipeline)

