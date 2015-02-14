@DockerServers = new Meteor.Collection "dockerServers"
@DockerServerImages = new Meteor.Collection "dockerServerImages"
@DockerServerContainers = new Meteor.Collection "dockerServerContainers"
@DockerServerContainersLog = new Meteor.Collection "dockerServerContainersLog"
@DockerServerPullImageLog = new Meteor.Collection "dockerServerPullImageLog"

@DockerConfigTypes = new Meteor.Collection "dockerConfigTypes"
@DockerImageIsConfigTypes = new Meteor.Collection "dockerImageIsConfigTypes"

@DockerUsageLimits = new Meteor.Collection "dockerUsageLimits"

@DockersUsedInEnvs = new Meteor.Collection "dockersUsedInEnvs"


@DockerImages = new Meteor.Collection "dockerImages"
@DockerTypes = new Meteor.Collection "dockerTypes"
@DockerLimits = new Meteor.Collection "dockerLimits"
@DockerTypeConfig = new Meteor.Collection "dockerTypeConfig"
@DockerInstances = new Meteor.Collection "dockerInstances"
@DockerInstancesLog = new Meteor.Collection "dockerInstancesLog"

@DockerServerImagesSchema = new SimpleSchema
  _id:
    type: String
  Created:
    type: Number
  Id:
    type: String
  ParentId:
    type: String
  Size:
    type: Number
  VirtualSize:
    type: Number
  dockerServerId:
    type: String
  lastUpdateAt:
    type: Date
  tag:
    type: String
  serverName:
    type: String

@DockerServerContainersSchema = new SimpleSchema
  _id:
    type: String
  userId:
    type: String
  Command:
    type: String
  Created:
    type: Number
  Id:
    type: String
  Image:
    type: String
  containerInfo:
    type: Object
  imageType:
    type: String
  Names:
    type: [String]
  Ports:
    type: [Object]
  Status:
    type: String
  dockerServerId:
    type: String
  dockerServerName:
    type: String

@DockerServerPullImageLogSchema = new SimpleSchema
  imageName:
    type: String
    label: "Image"
  imageVersion:
    type: String
    label: "Image Version"
  dockerHubIp:
    type: String
    label: "Dockerhub IP"
  dockerServerId:
    type: String
    label: "DockerServerId"

basePort = 8000
topPort = 9000

getFreePort = ->
  ports = [basePort..topPort].map String
  filterPorts = DockerInstances.find().fetch().map (x)-> x.servicePort
  filteredPorts = ports.filter (x) -> x not in filterPorts
  filteredPorts[0]

# getFreePorts = (n, serverName) ->
#   if not serverName
#     serverName = "localhost"
#   ports = [basePort..topPort].map String
#   filterPorts = []
#   DockerInstances.find({serverName:serverName}).fetch().map (x)->
#     x.portDataArray.map (xx) ->
#       filterPorts.push xx.hostPort

#   DockerServerContainers.find({serverName:serverName}).fetch().map (x)->
#     x.Ports.map (xx) ->
#       filterPorts.push String xx.PublicPort

#   filteredPorts = ports.filter (x) -> x not in filterPorts
#   if filteredPorts.length >= n
#     filteredPorts.slice(0,n)


# getDockerServerConnectionSettings = (dockerServerName) ->

#   dockerServerData = DockerServers.findOne name:dockerServerName

#   fs = Meteor.npmRequire 'fs'

#   dockerServerSettings = {}
#   _.extend dockerServerSettings, dockerServerData.connect
#   if not dockerServerSettings.socketPath
#     if dockerServerData.connect.protocol is "https"
#       ["ca","cert","key"].map (xx) ->
#         dockerServerSettings[xx] = fs.readFileSync(dockerServerData.security[xx+"Path"])

#   dockerServerSettings


# getFreeDockerServerName = (imageTag) -> "d3-agilearning"
# # getFreeDockerServerName = (imageTag) -> "localhost"

getDockerFreePort = (dockerServerId)->
  ports = [basePort..topPort]
  filterPorts = DockerServerContainers.find("dockerServerId":dockerServerId).fetch().map (x)-> x.Ports[0].PublicPort
  console.log "filterPorts ="
  console.log filterPorts
  filteredPorts = ports.filter (x) -> x not in filterPorts
  console.log "filteredPorts = "
  console.log filteredPorts[0]
  String filteredPorts[0]

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



  "pullImage": (pullImageData) ->
    if pullImageData["dockerHubIp"] is "dockerhub"
      # console.log "pullImageData ="
      # console.log pullImageData
      # console.log "pull from docker.com"
      Docker = Meteor.npmRequire "dockerode"
      fs = Meteor.npmRequire 'fs'
      dockerServerData = DockerServers.findOne {"_id":pullImageData["dockerServerId"]}
      dockerServerSettings = {}
      _.extend dockerServerSettings, dockerServerData.connect
      ["ca","cert","key"].map (xx) ->
        dockerServerSettings[xx] = fs.readFileSync(dockerServerData.security[xx+"Path"])
      # dockerServerSettings["dockerServerId"] = dockerServerData._id
      # dockerServerSettings["dockerServerName"] = dockerServerData.name

      docker = new Docker dockerServerSettings
      Future = Npm.require 'fibers/future'
      pullImageFuture = new Future

      repository = pullImageData["imageName"] + ":" + pullImageData["imageVersion"]
      console.log "repository ="
      console.log repository

      docker.pull repository, (err, stream) ->
        if err
          console.log "err ="
          console.log err
        console.log "pulling image"
        pullImageFuture.return stream

      pullImage = pullImageFuture.wait()
      DockerServerPullImageLog.insert pullImage
      # console.log "pullImage ="
      # console.log pullImage
    else
      console.log "pull from private registry"

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

  # "getClassroomDocker": (classroomId) ->
  #   user = Meteor.user()
  #   if not user
  #     throw new Meteor.Error(401, "You need to login")

  #   if Classrooms.find({_id:classroomId}).count() is 0
  #     throw new Meteor.Error(1201, "Classroom doesn't exist")

  #   classroomDoc = Classrooms.findOne _id:classroomId
  #   if classroomDoc
  #     courseData = Courses.findOne _id:classroomDoc.courseId

  #     if courseData
  #       imageId = courseData.dockerImage

  #       # imageType = DockerImages.findOne({_id:imageId}).type
  #       # if DockerTypeConfig.find({userId:user._id,typeId:imageType}).count() is 0
  #       #   #FIXME: write a checking function for env vars
  #       #   throw new Meteor.Error(1002, "MUST Setting Type Configurations before running!")

  #       Meteor.call "runDocker", imageId


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
      docker = new Docker Meteor.settings.public.dockerodeConfig

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



  # "runDocker": (imageTag)->

  #   if imageTag.split(":").length is 1
  #     fullImageTag = imageTag + ":latest"
  #   else
  #     fullImageTag = imageTag

  #   console.log "fullImageTag = "
  #   console.log fullImageTag

  #   #[TODOLIST: checking before running]
  #   #TODO: assert user logged in
  #   user = Meteor.user()
  #   if not user
  #     throw new Meteor.Error(401, "You need to login")

  #   #TODO: assert imageTag exists
  #   if DockerImages.find({_id:imageTag}).count() is 0
  #     throw new Meteor.Error(1001, "Docker Image ID Error!")

  #   #[TODOLIST: building running containerData]
  #   #TODO: check user's config
  #   configTypeId = DockerImages.findOne({_id:imageTag}).type
  #   if EnvUserConfigs.find({userId:user._id,configTypeId:configTypeId}).count() is 0
  #     #FIXME: write a checking function for env vars
  #     throw new Meteor.Error(1002, "MUST Setting Type Configurations before running!")

  #   else
  #     configData = EnvUserConfigs.findOne({userId:user._id,configTypeId:configTypeId}).configData
  #     EnvsArray = configData.map (envData) -> envData["key"] + "=" + envData["value"]


  #   #TODO: (if has config) getEnvUserConfigs
  #   #TODO: checkingRunningCondition
  #   #TODO: (if can run) choosing Running Limit
  #     dockerLimit = DockerLimits.findOne _id:"defaultLimit"

  #   #TODO: use limit, EnvTypes' config => build containerData
  #     containerData = dockerLimit.limit
  #     containerData.Image = imageTag
  #     containerData.Env = EnvsArray

  #   #[TODOLIST: get free server & ports]
  #   #TODO: get free server has the image
  #     Docker = Meteor.npmRequire "dockerode"
  #     freeDockerServerName = getFreeDockerServerName(imageTag)
  #     dockerServerSettings = getDockerServerConnectionSettings(freeDockerServerName)
  #     docker = new Docker dockerServerSettings

  #   #TODO: (if has server) get free ports in that server (include multiports)

  #     servicePorts = EnvConfigTypes.findOne({_id:configTypeId}).configs.servicePorts
  #     fports = getFreePorts servicePorts.length, freeDockerServerName

  #     portDataArray = [0..fports.length-1].map (i)->
  #       portData =
  #         guestPort: servicePorts[i].port
  #         hostPort: fports[i]
  #         type: servicePorts[i].type

  #     containerData.HostConfig = {}
  #     containerData.HostConfig.PortBindings = {}

  #     for portData in portDataArray
  #       servicePort = portData.guestPort + "/tcp"
  #       containerData.HostConfig.PortBindings[servicePort] = [{"HostPort": portData.hostPort}]

  #   #FIXME: two server might acquire the same port

  #   #[TODOLIST: runServer and write data to db]
  #   #TODO: createContainer
  #   #TODO: getContainer
  #   #TODO: write status and logging data to dbs

  #   if DockerInstances.find({userId:user._id,imageTag:fullImageTag}).count() is 0

  #     console.log "fullImageTag = "
  #     console.log fullImageTag

  #     Future = Npm.require 'fibers/future'
  #     createFuture = new Future

  #     docker.createContainer containerData, (err, container) ->
  #       createFuture.return container

  #     container = createFuture.wait()

  #     startFuture = new Future

  #     startOpt = {}
  #     # startOpt.PortBindings = containerData.HostConfig.PortBindings

  #     cont = docker.getContainer container.id
  #     cont.start startOpt, (err, data) ->
  #       startFuture.return data

  #     data = startFuture.wait()

  #     serverIP = dockerServerSettings.host
  #     if not serverIP
  #       serverIP = "localhost"

  #     dockerData =
  #       userId: user._id
  #       imageTag: fullImageTag
  #       dockerLimitId: "defaultLimit"
  #       containerConfig: containerData
  #       containerId: container.id
  #       configTypeId:configTypeId
  #       portDataArray:portDataArray
  #       configTypeId:configTypeId
  #       ip:serverIP
  #       serverName: freeDockerServerName
  #       createAt: new Date

  #     DockerInstances.insert dockerData



  #   # TODO: different roles can access different images ...


  "setENV": (typeId, envData) ->
    user = Meteor.user()
    if not user
      throw new Meteor.Error(401, "You need to login")

    dockerType = DockerTypes.findOne _id:typeId
    typeFilter = dockerType.env.map (xx) -> xx.name
    filteredEnvData = Object.keys(envData).filter((x) -> x in typeFilter).filter((x) -> envData[x] isnt "").map((x)-> x+"="+envData[x])

    DockerTypeConfig.upsert {userId:user._id,typeId:typeId}, {$set:{env:filteredEnvData}}

  "runNewDocker": (imageTag)->

    user = Meteor.user()
    if not user
      throw new Meteor.Error(401, "You need to login")

    if DockerImages.find({"_id":imageTag}).count() is 0
      throw new Meteor.Error(1001, "Docker Image ID Error!")

    # TODO: different roles can access different images ...

    imageType = DockerImages.findOne({_id:imageTag}).type
    if DockerTypeConfig.find({userId:user._id,typeId:imageType}).count() is 0
      #FIXME: write a checking function for env vars
      throw new Meteor.Error(1002, "MUST Setting Type Configurations before running!")

    if DockerInstances.find({userId:user._id,imageId:imageTag}).count() is 0

      dockerLimit = DockerLimits.findOne _id:"defaultLimit"

      console.log "[in createContainer] dockerLimit = "
      console.log dockerLimit

      Docker = Meteor.npmRequire "dockerode"
      fs = Meteor.npmRequire 'fs'
      # Need change `dockerServerIp = "130.211.244.66"`
      dockerServerIp = "130.211.244.66"
      dockerServerData = DockerServers.findOne {"connect.host":dockerServerIp}

      dockerServerSettings = {}
      _.extend dockerServerSettings, dockerServerData.connect
      ["ca","cert","key"].map (xx) ->
        dockerServerSettings[xx] = fs.readFileSync(dockerServerData.security[xx+"Path"])
      dockerServerSettings["dockerServerId"] = dockerServerData._id
      dockerServerSettings["dockerServerName"] = dockerServerData.name

      docker = new Docker dockerServerSettings
      fport = getDockerFreePort(dockerServerData._id)

      console.log "fport = "
      console.log fport

      imageType = DockerImages.findOne({_id:imageTag}).type
      containerData = dockerLimit.limit
      containerData.Image = imageTag

      if DockerTypeConfig.find({userId:user._id,typeId:imageType}).count() > 0
        config = DockerTypeConfig.findOne({userId:user._id,typeId:imageType})
        containerData.Env = config.env

      servicePort = DockerTypes.findOne({_id:imageType}).servicePort

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
        if err
          console.log "err"
          console.log err
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
        dockerServerId: dockerServerData._id

      console.log "[outside] dockerData = "
      console.log dockerData
      Meteor.call "listContainers", dockerServerData._id
      Meteor.call "syncDockerServer"
      DockerInstances.insert dockerData

  "removeNewDocker": (containerId)->
    user = Meteor.user()
    if not user
      throw new Meteor.Error(401, "You need to login")

    containerData = DockerServerContainers.findOne("Id":containerId)
    console.log "DockerInstances.find({userId:user._id,containerId:containerId}).count() = "
    console.log DockerServerContainers.find({userId:user._id,containerId:containerId}).count()

    hasRemovePermission = DockerInstances.find({userId:user._id,containerId:containerId}).count() > 0

    console.log "hasRemovePermission = "
    console.log hasRemovePermission

    hasRemovePermission = hasRemovePermission or Roles.userIsInRole(user._id, "admin", "dockers")

    console.log "hasRemovePermission = "
    console.log hasRemovePermission

    if hasRemovePermission
      dockerServerData = DockerServers.findOne("_id":containerData.dockerServerId)

      Docker = Meteor.npmRequire "dockerode"
      fs = Meteor.npmRequire 'fs'

      dockerServerSettings = {}
      _.extend dockerServerSettings, dockerServerData.connect
      ["ca","cert","key"].map (xx) ->
        dockerServerSettings[xx] = fs.readFileSync(dockerServerData.security[xx+"Path"])

      docker = new Docker dockerServerSettings
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
      Meteor.call "listContainers", dockerServerData.connect.host
      Meteor.call "syncDockerServer"
      Alldata = DockerInstances.find({containerId:containerId}).fetch()
      DockerInstances.remove {containerId:containerId}
      for x in Alldata
        x.remoteAt = new Date
        DockerInstancesLog.insert x

    else
      throw new Meteor.Error(1101, "Permission Deny!")

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
