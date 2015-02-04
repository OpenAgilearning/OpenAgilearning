@DockerServers = new Meteor.Collection "dockerServers"
@DockerServerImages = new Meteor.Collection "dockerServerImages"
@DockerServerContainers = new Meteor.Collection "dockerServerContainers"
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
  "syncDockerServer": ->
    servers = DockerServers.find().fetch()
    for server in servers
      DockerServers.remove(_id:server._id)
      filterPorts = DockerServerContainers.find("dockerServerId":server._id).fetch().map (x)-> x.Ports[0].PublicPort
      console.log filterPorts
      server.PublicPort = filterPorts
      DockerServers.insert server
    servers

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
      docker = new Docker Meteor.settings.public.dockerodeConfig
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
