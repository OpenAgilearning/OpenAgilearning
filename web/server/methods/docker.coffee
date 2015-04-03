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
      docker.rmForcely containerId


      db.dockerContainersMonitor.remove Id:containerId

      containerDoc.removeAt = new Date
      containerDoc.removeBy = "dockerAdmin"
      containerDoc.removeByUid = user._id
      db.dockerContainersLog.insert containerDoc
      # DockerServerContainersLog.insert containerDoc

      #TODO: modift DockerInstances data
      instanceQuery =
        serverName: containerDoc.serverId
        containerId: containerId

      dockerInstanceDoc = db.dockerInstances.findOne instanceQuery
      if dockerInstanceDoc
        db.dockerInstances.remove _id: dockerInstanceDoc._id

        dockerInstanceDoc.removeAt = new Date
        dockerInstanceDoc.removeBy = "dockerAdmin"
        dockerInstanceDoc.removeByUid = user._id
        db.dockerInstancesLog.insert dockerInstanceDoc

  "runDocker": (imageTag)->

    # FIXME refactor dockerImage collection, image with full tag
    if imageTag.split(":").length is 1
      fullImageTag = imageTag + ":latest"
    else
      fullImageTag = imageTag

    #[TODOLIST: checking before running]
    #TODO: assert user logged in
    user = Meteor.user()
    if not user
      throw new Meteor.Error(401, "You need to login")

    if ENV.isDev or ENV.isStaging
      queryServer = "testing"
    else
      queryServer = "production"

    @unblock()


    if DockerInstances.find({userId:user._id,imageTag:fullImageTag, $or:[{frozen:$exists:false},{frozen:false}]}).count() is 0

      # Before we start a new instance, say bye bye to all
      # old mess(frozen instances) you've created.
      frozenInstances = DockerInstances.find {userId:user._id, frozen:true}

      if frozenInstances
        frozenInstances.map (instanceDoc)->
          # No, don't call method here. Since rmf takes time, the user can still see
          # the old instance when the classroom rerender.
          # Meteor.call "removeDockerInstance", instanceDoc._id

          dockerInstanceDoc = instanceDoc
          DockerInstances.remove _id: dockerInstanceDoc._id

          dockerInstanceDoc.removeAt = new Date
          dockerInstanceDoc.removeBy = "system"
          dockerInstanceDoc.removeByUid = user._id
          DockerInstancesLog.insert dockerInstanceDoc

          docker = new Class.DockerServer instanceDoc.serverId
          docker.rmf instanceDoc.containerId

      dm = new Class.DockersManager queryServer

      resData = dm.getFreeServerForcely().run(imageTag, "basic", user._id)

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
          createAt: new Date

        DockerInstances.insert dockerData



    # TODO: different roles can access different images ...
