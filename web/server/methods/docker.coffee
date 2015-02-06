basePort = 8000
topPort = 9000

getFreePorts = (n, serverName) ->
  if not serverName
    serverName = "localhost"
  ports = [basePort..topPort].map String
  filterPorts = []
  DockerInstances.find({serverName:serverName}).fetch().map (x)-> 
    x.portDataArray.map (xx) ->
      filterPorts.push xx.hostPort

  DockerServerContainers.find({serverName:serverName}).fetch().map (x)-> 
    x.Ports.map (xx) ->
      filterPorts.push String xx.PublicPort

  filteredPorts = ports.filter (x) -> x not in filterPorts
  if filteredPorts.length >= n
    filteredPorts.slice(0,n)

getDockerServerConnectionSettings = (dockerServerName) ->

  dockerServerData = DockerServers.findOne name:dockerServerName
  
  fs = Meteor.npmRequire 'fs'

  dockerServerSettings = {}
  _.extend dockerServerSettings, dockerServerData.connect
  if not dockerServerSettings.socketPath
    if dockerServerData.connect.protocol is "https"
      ["ca","cert","key"].map (xx) ->
        dockerServerSettings[xx] = fs.readFileSync(dockerServerData.security[xx+"Path"])
  
  dockerServerSettings


getFreeDockerServerName = (imageTag) -> "d3-agilearning"  
# getFreeDockerServerName = (imageTag) -> "localhost"  

Meteor.methods
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
        
        # imageType = DockerImages.findOne({_id:imageId}).type
        # if DockerTypeConfig.find({userId:user._id,typeId:imageType}).count() is 0
        #   #FIXME: write a checking function for env vars
        #   throw new Meteor.Error(1002, "MUST Setting Type Configurations before running!")

        Meteor.call "runDocker", imageId

  "runDocker": (imageTag)->
    
    if imageTag.split(":").length is 1
      fullImageTag = imageTag + ":latest"
    else
      fullImageTag = imageTag

    console.log "fullImageTag = "
    console.log fullImageTag

    #[TODOLIST: checking before running]    
    #TODO: assert user logged in
    user = Meteor.user()
    if not user
      throw new Meteor.Error(401, "You need to login")

    #TODO: assert imageTag exists
    if DockerImages.find({_id:imageTag}).count() is 0
      throw new Meteor.Error(1001, "Docker Image ID Error!")

    #[TODOLIST: building running containerData]
    #TODO: check user's config
    configTypeId = DockerImages.findOne({_id:imageTag}).type
    if EnvUserConfigs.find({userId:user._id,configTypeId:configTypeId}).count() is 0
      #FIXME: write a checking function for env vars
      throw new Meteor.Error(1002, "MUST Setting Type Configurations before running!")

    else
      configData = EnvUserConfigs.findOne({userId:user._id,configTypeId:configTypeId}).configData
      EnvsArray = configData.map (envData) -> envData["key"] + "=" + envData["value"]
      
  
    #TODO: (if has config) getEnvUserConfigs 
    #TODO: checkingRunningCondition
    #TODO: (if can run) choosing Running Limit
      dockerLimit = DockerLimits.findOne _id:"defaultLimit"
      
    #TODO: use limit, EnvTypes' config => build containerData
      containerData = dockerLimit.limit
      containerData.Image = imageTag
      containerData.Env = EnvsArray

    #[TODOLIST: get free server & ports]
    #TODO: get free server has the image
      Docker = Meteor.npmRequire "dockerode"
      freeDockerServerName = getFreeDockerServerName(imageTag)
      dockerServerSettings = getDockerServerConnectionSettings(freeDockerServerName)
      docker = new Docker dockerServerSettings

    #TODO: (if has server) get free ports in that server (include multiports)
      
      servicePorts = EnvConfigTypes.findOne({_id:configTypeId}).configs.servicePorts
      fports = getFreePorts servicePorts.length, freeDockerServerName

      portDataArray = [0..fports.length-1].map (i)-> 
        portData = 
          guestPort: servicePorts[i].port
          hostPort: fports[i]
          type: servicePorts[i].type 

      containerData.HostConfig = {}
      containerData.HostConfig.PortBindings = {}

      for portData in portDataArray
        servicePort = portData.guestPort + "/tcp"
        containerData.HostConfig.PortBindings[servicePort] = [{"HostPort": portData.hostPort}]

    #FIXME: two server might acquire the same port

    #[TODOLIST: runServer and write data to db]
    #TODO: createContainer
    #TODO: getContainer
    #TODO: write status and logging data to dbs

    if DockerInstances.find({userId:user._id,imageTag:fullImageTag}).count() is 0

      console.log "fullImageTag = "
      console.log fullImageTag

      Future = Npm.require 'fibers/future'
      createFuture = new Future

      docker.createContainer containerData, (err, container) ->
        createFuture.return container

      container = createFuture.wait()

      startFuture = new Future

      startOpt = {}
      # startOpt.PortBindings = containerData.HostConfig.PortBindings

      cont = docker.getContainer container.id
      cont.start startOpt, (err, data) ->
        startFuture.return data

      data = startFuture.wait()

      serverIP = dockerServerSettings.host
      if not serverIP
        serverIP = "localhost"

      dockerData =
        userId: user._id
        imageTag: fullImageTag
        dockerLimitId: "defaultLimit"
        containerConfig: containerData
        containerId: container.id
        configTypeId:configTypeId
        portDataArray:portDataArray
        configTypeId:configTypeId
        ip:serverIP
        serverName: freeDockerServerName
        createAt: new Date

      DockerInstances.insert dockerData

    

    # TODO: different roles can access different images ...
