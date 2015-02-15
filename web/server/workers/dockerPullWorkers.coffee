@dockerPull = {}


@dockerPull.DoingJobHandler = ()->
  dockerServerNames = db.dockerServers.find().fetch().map (xx) -> xx.name
  dockerPullDoingJobs = db.dockerPullImageJob.find({serverName:{$in:dockerServerNames},status:"Doing"}).fetch()
  
  dockerPullDoingJobs.map (job) ->
    if db.dockerPullImageStream.find({jobId:job._id,error:{"$exists":true}}).count() > 0
      updateData = 
        errorAt: new Date
        status: "Error"

      db.dockerPullImageJob.update {_id:job._id}, {$set:updateData}





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

      
        if not err
          addJobData = (data) ->
            data["serverName"] = serverName
            data["jobId"] = jobId
            data
          stream.pipe(parser).on("data",addJobData).pipe(streamToMongo)
        else
          console.log err
