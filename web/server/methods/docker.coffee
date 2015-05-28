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

@getDockerServerConnectionSettings = (dockerServerName) ->

  dockerServerData = DockerServers.findOne name:dockerServerName

  fs = Meteor.npmRequire 'fs'

  dockerServerSettings = {}
  _.extend dockerServerSettings, dockerServerData.connect
  if not dockerServerSettings.socketPath
    if dockerServerData.connect.protocol is "https"
      ["ca","cert","key"].map (xx) ->
        dockerServerSettings[xx] = fs.readFileSync(dockerServerData.security[xx+"Path"])

  dockerServerSettings

getFreeDockerServerName = (imageTag) ->

  serverArr = DockerServerImages.find({"tag":imageTag}).fetch()
  if serverArr.length is 0
    throw new Meteor.Error 666, "No such docker image"

  #TODO list avaliable server object
  arrOfServerObj = serverArr.map (xx) ->
    res =
      "serverName": xx.serverName
      "numOfContainers":DockerServerContainers.find({"serverName":xx.serverName}).count()
    res

  #TODO return minimun item of array
  numOfContainersArr = arrOfServerObj.map (xx)->
    xx.numOfContainers
  # If you don't understand return what, check following answer
  # https://stackoverflow.com/questions/11301438/return-index-of-greatest-value-in-an-array
  console.log "getFreeDockerServerName ===== ???"
  console.log arrOfServerObj[ numOfContainersArr.indexOf  Math.min.apply Math ,numOfContainersArr]["serverName"]

  arrOfServerObj[ numOfContainersArr.indexOf  Math.min.apply Math ,numOfContainersArr]["serverName"]

Meteor.methods
  "submitPullImageJob": (pullImageData) ->
    loggedInUserId = Meteor.userId()

    if not loggedInUserId
      throw new Meteor.Error(401, "You need to login")

    if db.dockerServers.find({name:pullImageData.serverName}).count() is 0
      throw new Meteor.Error(1302, "[Admin Error] there is no serverName = " + serverName)

    if Roles.userIsInRole(loggedInUserId,"admin","dockers")
      pullJob =
        status: "ToDo"  # ToDo / Doing / Done
        imageTag: pullImageData.repoTag #"postgres:9.3"
        serverName: pullImageData.serverName
        createdAt: new Date

      db.dockerPullImageJob.insert pullJob



  "removeDockerInstance": (instanceId)->
    #[TODOLIST: checking before running]
    #TODO: assert user logged in
    user = Meteor.user()
    if not user
      throw new Meteor.Error(401, "You need to login")

    #TODO: assert container exists
    instanceDoc = DockerInstances.findOne _id: instanceId

    # console.log "instanceId = "
    # console.log instanceId
    # console.log instanceDoc

    if not instanceDoc
      throw new Meteor.Error(1001, "Docker Server Instance ID Error!")


    hasRemovePermission = instanceDoc.userId is user._id
    hasRemovePermission = hasRemovePermission or Roles.userIsInRole(user._id, "admin", "dockers")

    if hasRemovePermission
      docker = new Class.DockerServer instanceDoc.serverId
      # docker.stop instanceDoc.containerId
      # docker.rm instanceDoc.containerId
      docker.rmf instanceDoc.containerId

      dockerInstanceDoc = instanceDoc
      DockerInstances.remove _id: dockerInstanceDoc._id

      dockerInstanceDoc.removeAt = new Date
      dockerInstanceDoc.removeBy = "user"
      dockerInstanceDoc.removeByUid = user._id
      DockerInstancesLog.insert dockerInstanceDoc



  "removeDockerServerContainer": (dockerServerContainerId)->
    #[TODOLIST: checking before running]
    #TODO: assert user logged in
    user = Meteor.user()
    if not user
      throw new Meteor.Error(401, "You need to login")

    #TODO: assert container exists
    containerDoc = db.dockerContainersMonitor.findOne Id: dockerServerContainerId

    if not containerDoc
      throw new Meteor.Error(1001, "Docker Server Container ID Error!")


    if Roles.userIsInRole user._id, "admin", "dockers"
      containerId = dockerServerContainerId

      docker = new Class.DockerServer(containerDoc.serverId)
      # docker.stop containerId
      # docker.rm containerId
      docker.rmf containerId


      db.dockerContainersMonitor.remove Id:containerId

      containerDoc.removeAt = new Date
      containerDoc.removeBy = "dockerAdmin"
      containerDoc.removeByUid = user._id
      db.dockerContainersLog.insert containerDoc
      # DockerServerContainersLog.insert containerDoc

      #TODO: modift DockerInstances data
      instanceQuery =
        serverId: containerDoc.serverId
        containerId: containerId

      dockerInstanceDoc = db.dockerInstances.findOne instanceQuery
      if dockerInstanceDoc
        db.dockerInstances.remove _id: dockerInstanceDoc._id

        dockerInstanceDoc.removeAt = new Date
        dockerInstanceDoc.removeBy = "dockerAdmin"
        dockerInstanceDoc.removeByUid = user._id
        db.dockerInstancesLog.insert dockerInstanceDoc

  # "checkDockerInstance": (imageTag)->
  #   user = Meteor.user()
  #   if not user
  #     throw new Meteor.Error(401, "You need to login")


  #   console.log "TODO"
  #   console.log "return instanceId or ... "

  "getFreeTrialQuota": ->
    user = Meteor.user()
    if not user
      throw new Meteor.Error(401, "You need to login")


    nowTime = new Date().getTime()
    quotaQuery =
      expired: false
      expiredAt:
        $gt: nowTime
      userId: user._id

    if db.dockerPersonalUsageQuota.find(quotaQuery).count() > 0
      throw new Meteor.Error(11001, "You already have personal quota!")

    else
      trialQuotaData =
        name: "freeTrialQuota"
        userId: uid
        expiredAt: new Date().getTime() + 20*60*1000
        NCPU: 1
        Memory: 512*1024*1024
        expired: false

      db.dockerPersonalUsageQuota.insert trialQuotaData



  "checkTOS": ->
    user = Meteor.user()
    if not user
      throw new Meteor.Error(401, "You need to login")

    return _.contains user.agreedTOC, "toc_main"


  "runDockerLimit": (imageTag, quotaData, limitData)->
    # console.log "TEST"

    _quotaData = quotaData

    # FIXME refactor dockerImage collection, image with full tag
    if imageTag.split(":").length is 1
      fullImageTag = imageTag + ":latest"
    else
      fullImageTag = imageTag

    user = Meteor.user()
    if not user
      throw new Meteor.Error(401, "You need to login")


    if quotaData.type is "forGroup"

      bgData = db.bundleServerUserGroup.findOne {_id:quotaData.id, members: user._id}

      if not bgData
        throw new Meteor.Error(10001, "There is no server OR you are not member!")

      usageLimit = _.find bgData.usageLimits, (limitData) -> limitData.name is limitData.name

      if not usageLimit
        throw new Meteor.Error(10002, "Invalid usage limit data!")



      console.log "usageLimit = ",usageLimit

      queryServer =
        _id:
          $in: bgData.servers

      console.log "bgData = ",bgData
      console.log "queryServer = ", queryServer

    else
      # quotaData.type is "forPersonal"
      queryServer =
        user:
          type: "toC"

      if ENV.isDev or ENV.isStaging
        queryServer.useIn = "testing"
      else
        queryServer.useIn = "production"


      quotaData = db.dockerPersonalUsageQuota.findOne _id:quotaData.id, userId: user._id
      console.log "quotaData = ", quotaData
      if not quotaData
        throw new Meteor.Error(10001, "you are not the owner of quotaData.id")

      # [finished] FIXME: check quotaData is expired or not ?

      nowTime = new Date().getTime()
      if quotaData.expiredAt > 0 and quotaData.expiredAt < nowTime
        Meteor.defer expiringUserQuota
        throw new Meteor.Error(10001, "your quota is expired!")

      if limitData?.NCPU? or limitData?.Memory?
        # [finished] TODO: compute using.NCPU and using.Memory
        usingAggregate = db.dockerInstances.aggregate([{$match:{"quota.id":quotaData._id}},{$group:{_id:"$quota.id",NCPU:{$sum:"$limit.NCPU"},Memory:{$sum:"$limit.Memory"}}}])
        if usingAggregate.length > 0
          using = usingAggregate[0]
        else
          using =
            NCPU: 0
            Memory: 0


      # # [finished] FIXME: (limitData.NCPU > quotaData.NCPU - using.NCPU) or (limitData.Memory > quotaData.Memory - using.Memory)
      # if (limitData.NCPU > quotaData.NCPU - using.NCPU) or (limitData.Memory > quotaData.Memory - using.Memory)
      # # if (limitData.NCPU > quotaData.NCPU) or (limitData.Memory > quotaData.Memory)
      #     throw new Meteor.Error(10003, "(limitData.NCPU > quotaData.NCPU - using.NCPU) or (limitData.Memory > quotaData.Memory - using.Memory)")

      # usageLimit =
      #   NCPU: limitData.NCPU
      #   Memory: limitData.Memory


      usageLimit = {}

      if limitData?.NCPU? and quotaData.NCPU > 0
        if (limitData.NCPU > quotaData.NCPU - using.NCPU)
          throw new Meteor.Error(10003, "(limitData.NCPU > quotaData.NCPU - using.NCPU)")

        else
          usageLimit.NCPU = limitData.NCPU

      else
        unless quotaData.NCPU < 0
          throw new Meteor.Error(10003, "Missing limitData.NCPU")


      if limitData?.Memory? and quotaData.Memory > 0
        if (limitData.Memory > quotaData.Memory - using.Memory)
          throw new Meteor.Error(10003, "(limitData.Memory > quotaData.Memory - using.Memory)")
        else
          usageLimit.Memory = limitData.Memory

      else
        unless quotaData.Memory < 0
          throw new Meteor.Error(10003, "Missing limitData.Memory")


    console.log "usageLimit = ", usageLimit

    dm = new Class.DockersManager queryServer

    if dm.ls_servers.length is 0
      throw new Meteor.Error(10005, "There is no server you can use!")

    console.log "dm.ls_servers = ", dm.ls_servers
    # docker = dm.getFreeServerForcely()
    # docker.runLimit(imageTag, usageLimit, user._id)

    resData = dm.getFreeServerForcely().runLimit(imageTag, usageLimit, user._id)

    console.log "resData = ",resData

    if not resData.error
      dockerData =
        userId: user._id
        imageTag: fullImageTag
        containerConfigs: resData.data.configs
        envs: resData.data.envs
        portDataArray: resData.data.portDataArray
        serverId: resData.data.container._serverId
        containerId: resData.data.container._instance.id
        ip: resData.data.container._docker._configs.host
        quota:
          type: _quotaData.type
          id: _quotaData.id
        limit:
          NCPU: usageLimit.NCPU
          Memory: usageLimit.Memory
        createAt: new Date

      DockerInstances.insert dockerData




  # "runDocker": (imageTag)->

  #   # FIXME refactor dockerImage collection, image with full tag
  #   if imageTag.split(":").length is 1
  #     fullImageTag = imageTag + ":latest"
  #   else
  #     fullImageTag = imageTag

  #   #[TODOLIST: checking before running]
  #   #TODO: assert user logged in
  #   user = Meteor.user()
  #   if not user
  #     throw new Meteor.Error(401, "You need to login")

  #   if ENV.isDev or ENV.isStaging
  #     queryServer = "testing"
  #   else
  #     queryServer = "production"

  #   @unblock()


  #   personalQuotaQuery =
  #     userId: user._id
  #     expiredAt:
  #       "$gt": new Date().getTime()

  #   checkpersonalQuota = db.dockerPersonalUsageQuota.find(personalQuotaQuery).count()

  #   if checkpersonalQuota is 0
  #     db.dockerPersonalUsageQuota.insert
  #       userId: user._id
  #       expiredAt: new Date().getTime() + 15*60*1000
  #       NCPU:1
  #       Memory: 512*1024*1024



  #   if DockerInstances.find({userId:user._id,imageTag:fullImageTag, $or:[{frozen:$exists:false},{frozen:false}]}).count() is 0

  #     # Before we start a new instance, say bye bye to all
  #     # old mess(frozen instances) you've created.
  #     frozenInstances = DockerInstances.find {userId:user._id, frozen:true}

  #     if frozenInstances
  #       frozenInstances.map (instanceDoc)->
  #         # No, don't call method here. Since rmf takes time, the user can still see
  #         # the old instance when the classroom rerender.
  #         # Meteor.call "removeDockerInstance", instanceDoc._id

  #         dockerInstanceDoc = instanceDoc
  #         DockerInstances.remove _id: dockerInstanceDoc._id

  #         dockerInstanceDoc.removeAt = new Date
  #         dockerInstanceDoc.removeBy = "system"
  #         dockerInstanceDoc.removeByUid = user._id
  #         DockerInstancesLog.insert dockerInstanceDoc

  #         docker = new Class.DockerServer instanceDoc.serverId
  #         docker.rmf instanceDoc.containerId

  #     dm = new Class.DockersManager queryServer

  #     resData = dm.getFreeServerForcely().run(imageTag, "basic", user._id)

  #     console.log "resData = ",resData

  #     if not resData.error
  #       dockerData =
  #         userId: user._id
  #         imageTag: fullImageTag
  #         containerConfigs: resData.data.configs
  #         envs: resData.data.envs
  #         portDataArray: resData.data.portDataArray
  #         serverId: resData.data.container._serverId
  #         containerId: resData.data.container._instance.id
  #         ip: resData.data.container._docker._configs.host
  #         createAt: new Date

  #       DockerInstances.insert dockerData



  #   # TODO: different roles can access different images ...


  "refreshDockerServerMonitors": ->
    #[TODOLIST: checking before running]
    #TODO: assert user logged in
    user = Meteor.user()
    if not user
      throw new Meteor.Error(401, "You need to login")

    if Roles.userIsInRole user._id, "admin", "dockers"
      db.dockerServersMonitor.remove {}
    else
      throw new Meteor.Error(401, "You are not authorized")


  "addNewServer":(doc)->

     ## REMOVED

       ## REMOVED
       ## REMOVED
       ## REMOVED
       ## REMOVED
       ## REMOVED
       ## REMOVED
       ## REMOVED
       ## REMOVED
       ## REMOVED
       ## REMOVED
       ## REMOVED
       ## REMOVED

    schema = new SimpleSchema
      serverName:
        type: String

      host:
        type: String
        regEx: SimpleSchema.RegEx.IP

      # port:
      #   type: Number

      useIn:
        type: String
        allowedValues: ["production","testing"]

      user:
        type: String
        allowedValues: ["toC","toB"]



    user = Meteor.user()
    if not user
      throw new Meteor.Error(401, "You need to login")

    if Roles.userIsInRole user._id, "admin", "dockers"


      check doc, schema

      if doc.serverName.length < 3
        throw new Meteor.Error(401, "servername too short")

      path = Meteor.npmRequire "path"

      if Meteor.settings.DOCKER_CERT_PATH isnt ""
        DOCKER_CERT_PATH = Meteor.settings.DOCKER_CERT_PATH
      else
        if process.env["DOCKER_CERT_PATH"]
          DOCKER_CERT_PATH = process.env["DOCKER_CERT_PATH"]
        else
          DOCKER_CERT_PATH = ""

      if db.dockerServers.find(name:doc.serverName).count() is 0
        db.dockerServers.insert
          _id: "[DockerServer]"+doc.serverName
          name:doc.serverName
          connect:
            protocol: 'https'
            host: doc.host
            port: 2376
          security:
            caPath: path.join(DOCKER_CERT_PATH, 'ca.pem')
            certPath: path.join(DOCKER_CERT_PATH, 'cert.pem')
            keyPath: path.join(DOCKER_CERT_PATH, 'key.pem')
          useIn: doc.useIn
          user:
            type: doc.user

      else
        throw new Meteor.Error(401, doc.serverName + "exists.")
    else
      throw new Meteor.Error(401, "You are not authorized")

  "RemoveDockerServer":(doc)->
    schema = new SimpleSchema
      serverId:
        type: String


    user = Meteor.user()
    if not user
      throw new Meteor.Error(401, "You need to login")

    if Roles.userIsInRole user._id, "admin", "dockers"


      check doc, schema

      if db.dockerInstances.find(serverId:doc.serverId).count() is 0

        db.dockerServers.remove _id:doc.serverId

      else
        throw new Meteor.Error(401, "This server still has running containers, freeze it first.")