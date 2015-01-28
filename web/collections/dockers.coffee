@DockerServers = new Meteor.Collection "dockerServers"
@DockerServerImages = new Meteor.Collection "dockerServerImages"


@DockerImages = new Meteor.Collection "dockerImages"
@DockerTypes = new Meteor.Collection "dockerTypes"
@DockerLimits = new Meteor.Collection "dockerLimits"
@DockerTypeConfig = new Meteor.Collection "dockerTypeConfig"
@DockerInstances = new Meteor.Collection "dockerInstances"
@DockerInstancesLog = new Meteor.Collection "dockerInstancesLog"


basePort = 8000
topPort = 9000

getFreePort = ->
  ports = [basePort..topPort].map String
  filterPorts = DockerInstances.find().fetch().map (x)-> x.servicePort
  filteredPorts = ports.filter (x) -> x not in filterPorts
  filteredPorts[0]


Meteor.methods
  "listImages": (dockerServerIp) -> 
    # NODE_TLS_REJECT_UNAUTHORIZED=0 MONGO_URL=mongodb://localhost:27017/dockerdata meteor --port 0.0.0.0:3000

    user = Meteor.user()
    if not user
      throw new Meteor.Error(401, "You need to login")
    
    getListPermission = Roles.userIsInRole(user._id, "admin", "dockers")
    getListPermission = getListPermission or Roles.userIsInRole(user._id, "admin", "system")

    if not getListPermission
      throw new Meteor.Error(1101, "Permission Deny!")
    else
      Docker = Meteor.npmRequire "dockerode"
      fs = Meteor.npmRequire 'fs'
      
      dockerServerData = DockerServers.findOne {"connect.host":dockerServerIp}
      
      dockerServerSettings = 
        protocol: dockerServerData.connect.protocol
        host: dockerServerData.connect.host
        port: dockerServerData.connect.port
        ca: fs.readFileSync(dockerServerData.security.caPath)
        cert: fs.readFileSync(dockerServerData.security.certPath)
        key: fs.readFileSync(dockerServerData.security.keyPath)

      docker = new Docker dockerServerSettings
      #docker.ping (err, data) -> console.log data
      
      Future = Npm.require 'fibers/future'
      imagesFuture = new Future

      docker.listImages {}, (err, data) -> 
        imagesFuture.return data
        
      images = imagesFuture.wait()
      
      DockerServerImages.remove({dockerServerId:dockerServerData._id})

      for imageData in images
        imageData.dockerServerId = dockerServerData._id
        DockerServerImages.insert imageData

      images
  
  "pullImage": (imageTag, dockerServerIp, dockerHubData) -> 
    console.log "TODO"

  "nweDockerRun": (imageId)-> 
    console.log "TODO"


  "getCourseDocker": (courseId) -> 
    user = Meteor.user()
    if not user
      throw new Meteor.Error(401, "You need to login")
    
    if Courses.find({_id:courseId}).count() is 0
      throw new Meteor.Error(1201, "Course doesn't exist")
    
    course = Courses.findOne _id:courseId
    
    imageId = course.dockerImage
    console.log "imageId = "
    console.log imageId
    console.log DockerImages.findOne({_id:imageId})

    imageType = DockerImages.findOne({_id:imageId}).type 
    # console.log "imageType = "
    # console.log imageType
    
    if DockerTypeConfig.find({userId:user._id,typeId:imageType}).count() is 0
      #FIXME: write a checking function for env vars
      throw new Meteor.Error(1002, "MUST Setting Type Configurations before running!")

    Meteor.call "runDocker", imageId

  "getClassroomDocker": (classroomId) -> 
    user = Meteor.user()
    if not user
      throw new Meteor.Error(401, "You need to login")
    
    if Classrooms.find({_id:classroomId}).count() is 0
      throw new Meteor.Error(1201, "Classroom doesn't exist")
    
    classroomDoc = Classrooms.findOne _id:classroomId
    if classroomDoc
      courseData = Courses.findOne _id:classroomDoc.courseId
      
      if courseData
        imageId = courseData.dockerImage
        # console.log "imageId = "
        # console.log imageId
        # console.log DockerImages.findOne({_id:imageId})

        imageType = DockerImages.findOne({_id:imageId}).type 
        # console.log "imageType = "
        # console.log imageType
        
        if DockerTypeConfig.find({userId:user._id,typeId:imageType}).count() is 0
          #FIXME: write a checking function for env vars
          throw new Meteor.Error(1002, "MUST Setting Type Configurations before running!")

        Meteor.call "runDocker", imageId


  "removeDocker": (containerId)-> 
    user = Meteor.user()
    if not user
      throw new Meteor.Error(401, "You need to login")

    console.log "DockerInstances.find({userId:user._id,containerId:containerId}).count() = "
    console.log DockerInstances.find({userId:user._id,containerId:containerId}).count()
    
    hasRemovePermission = DockerInstances.find({userId:user._id,containerId:containerId}).count() > 0
    
    console.log "hasRemovePermission = " 
    console.log hasRemovePermission
    
    hasRemovePermission = hasRemovePermission or Roles.userIsInRole(user._id, "admin", "dockers")

    console.log "hasRemovePermission = " 
    console.log hasRemovePermission
    
    if hasRemovePermission
      
      Docker = Meteor.npmRequire "dockerode"
      docker = new Docker {socketPath: '/var/run/docker.sock'}
      
      Future = Npm.require 'fibers/future'
      
      stopFuture = new Future
      container = docker.getContainer containerId

      container.stop {}, (err,data)->
        console.log "[inside container.stop] data = "
        console.log data
        stopFuture.return data

      data = stopFuture.wait()
      console.log "[outside container.stop] data = "
      console.log data

      removeFuture = new Future
      container = docker.getContainer containerId

      container.remove {}, (err,data)->
        console.log "[inside container.stop] data = "
        console.log data
        removeFuture.return data

      data = removeFuture.wait()
      console.log "[outside container.stop] data = "
      console.log data


      Alldata = DockerInstances.find({containerId:containerId}).fetch()
      DockerInstances.remove {containerId:containerId}

      for x in Alldata
        x.remoteAt = new Date
        DockerInstancesLog.insert x

    else
      throw new Meteor.Error(1101, "Permission Deny!")
    


  "runDocker": (imageId)-> 

    user = Meteor.user()
    if not user
      throw new Meteor.Error(401, "You need to login")

    if DockerImages.find({_id:imageId}).count() is 0
      throw new Meteor.Error(1001, "Docker Image ID Error!")

    # TODO: different roles can access different images ...

    imageType = DockerImages.findOne({_id:imageId}).type 
    if DockerTypeConfig.find({userId:user._id,typeId:imageType}).count() is 0
      #FIXME: write a checking function for env vars
      throw new Meteor.Error(1002, "MUST Setting Type Configurations before running!")


    if DockerInstances.find({userId:user._id,imageId:imageId}).count() is 0
      
      dockerLimit = DockerLimits.findOne _id:"defaultLimit"
      
      console.log "[in createContainer] dockerLimit = "
      console.log dockerLimit

      Docker = Meteor.npmRequire "dockerode"
      docker = new Docker {socketPath: '/var/run/docker.sock'}
      fport = getFreePort()

      imageType = DockerImages.findOne({_id:imageId}).type 

      containerData = dockerLimit.limit
      containerData.Image = imageId

      if DockerTypeConfig.find({userId:user._id,typeId:imageType}).count() > 0
        config = DockerTypeConfig.findOne({userId:user._id,typeId:imageType})
        containerData.Env = config.env
        
      servicePort = DockerTypes.findOne({_id:imageType}).servicePort

      # console.log "[before1] containerData = "
      # console.log containerData
      # console.log typeof containerData
      
      # outPort = [{"HostPort": fport}]        

      # console.log "[before1] outPort = "
      # console.log outPort
      
      # console.log "[before1] servicePort = "
      # console.log servicePort
      # console.log typeof servicePort
      
      containerData.HostConfig = {}
      containerData.HostConfig.PortBindings = {}
      containerData.HostConfig.PortBindings[servicePort] = [{"HostPort": fport}] 


      console.log "[before2] containerData = "
      console.log containerData
        
      Future = Npm.require 'fibers/future'
      createFuture = new Future

      docker.createContainer containerData, (err, container) -> 
        console.log "[inside] container = "
        console.log container
        createFuture.return container

      container = createFuture.wait()
      console.log "[outside] contaner = "
      console.log container

      startFuture = new Future

      startOpt = {}
      # startOpt.PortBindings = containerData.HostConfig.PortBindings
      
      cont = docker.getContainer container.id
      cont.start startOpt, (err, data) -> 
        console.log "data = ",
        console.log data
        startFuture.return data

      data = startFuture.wait()

      dockerData = 
        userId: user._id
        imageId: containerData.Image
        containerInfo: containerData
        containerId: container.id
        servicePort: fport
        imageType:imageType
        createAt: new Date

      console.log "[outside] dockerData = "
      console.log dockerData

      DockerInstances.insert dockerData




  "setENV": (typeId, envData) ->
    user = Meteor.user()
    if not user
      throw new Meteor.Error(401, "You need to login")
    
    dockerType = DockerTypes.findOne _id:typeId
    typeFilter = dockerType.env.map (xx) -> xx.name
    filteredEnvData = Object.keys(envData).filter((x) -> x in typeFilter).filter((x) -> envData[x] isnt "").map((x)-> x+"="+envData[x])

    DockerTypeConfig.upsert {userId:user._id,typeId:typeId}, {$set:{env:filteredEnvData}}

  # "createContainer": -> 
  #   user = Meteor.user()
  #   if not user
  #     throw new Meteor.Error(401, "You need to login")

  #   dockerLimit = DockerLimits.findOne _id:"defaultLimit"
  #   console.log "[in createContainer] dockerLimit = "
  #   console.log dockerLimit

  #   Docker = Meteor.npmRequire "dockerode"
  #   docker = new Docker {socketPath: '/var/run/docker.sock'}
  #   fport = "8080"

  #   containerData = 
  #     Cpuset: "0,1"
  #     CpuShares: 512
  #     Memory:512000000
  #     Image: "c3h3/ml-for-hackers"
  #     name: "tryml"
  #     Env:["USER=c3h3","PASSWORD=c3h33211"]
  #     HostConfig:
  #       PortBindings:
  #         "8787/tcp":[{"HostPort": fport}] 

    
  #   Future = Npm.require 'fibers/future'
  #   createFuture = new Future

  #   docker.createContainer containerData, (err, container) -> 
  #     console.log "[inside] container = "
  #     console.log container
  #     createFuture.return container

  #   container = createFuture.wait()
  #   console.log "[outside] contaner = "
  #   console.log container

  #   dockerData = 
  #     userId: user._id
  #     baseImage: containerData.Image
  #     containerInfo: containerData
  #     containerId: container.id

  #   console.log "[outside] dockerData = "
  #   console.log dockerData

  #   TryDockers.insert dockerData

  #   cont = docker.getContainer container.id
  #   cont.start {}, (err, data) -> 
  #     console.log "data = ",
  #     console.log data
    
