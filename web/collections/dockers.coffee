new Mongo.Collection "dockerServersMonitor"
new Mongo.Collection "dockerImageTagsMonitor"
new Mongo.Collection "dockerContainersMonitor"

new Mongo.Collection "dockerHubs"
new Mongo.Collection "dockerRepos"

new Mongo.Collection "dockerUsageLimits"

new Mongo.Collection "dockerPersonalUsageQuota"
new Mongo.Collection "dockerServerUsageQuota"

new Mongo.Collection "dockerImageTags"
new Mongo.Collection "dockerContainersLog"

new Mongo.Collection "dockerEnsureImages"





@DockerServers = new Mongo.Collection "dockerServers"
@DockerServersException = new Mongo.Collection "dockerServersException"
@DockerServerImages = new Mongo.Collection "dockerServerImages"
@DockerServerContainers = new Mongo.Collection "dockerServerContainers"
@DockerServerContainersLog = new Mongo.Collection "dockerServerContainersLog"
@DockerServerPullImageLog = new Mongo.Collection "dockerServerPullImageLog"
@DockerServerPullImageScratch = new Mongo.Collection "dockerServerPullImageSratch"

@DockerConfigTypes = new Mongo.Collection "dockerConfigTypes"
@DockerImageIsConfigTypes = new Mongo.Collection "dockerImageIsConfigTypes"


@DockersUsedInEnvs = new Mongo.Collection "dockersUsedInEnvs"


@DockerImages = new Mongo.Collection "dockerImages"
@DockerTypes = new Mongo.Collection "dockerTypes"
@DockerLimits = new Mongo.Collection "dockerLimits"
@DockerTypeConfig = new Mongo.Collection "dockerTypeConfig"
@DockerInstances = new Mongo.Collection "dockerInstances"
@DockerInstancesLog = new Mongo.Collection "dockerInstancesLog"


@Collections.DockerServers = @DockerServers
@Collections.DockerServerImages = @DockerServerImages
@Collections.DockerServerExceptionTypes = new Mongo.Collection "dockerServerExceptionTypes"
@Collections.DockerServerExceptions = new Mongo.Collection "dockerServerExceptions"

@Collections.DockerPullImageJob = new Mongo.Collection "dockerPullImageJob"
@Collections.DockerPullImageStream = new Mongo.Collection "dockerPullImageStream"
@Collections.DockerRunJob = new Mongo.Collection "dockerRunJob"

@Collections.DockerPushImageJob = new Mongo.Collection "dockerPushImageJob"
@Collections.DockerPushImageJobStream = new Mongo.Collection "dockerPushImageJobStream"


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

  "getClassroomDocker": (classroomId, customTag=undefined) ->
    user = Meteor.user()
    if not user
      throw new Meteor.Error(401, "You need to login")

    if Classrooms.find({_id:classroomId}).count() is 0
      throw new Meteor.Error(1201, "Classroom doesn't exist")

    classroomDoc = Classrooms.findOne _id:classroomId
    if classroomDoc

      if customTag and db.courseJoinDockerImageTags.findOne({tag:customTag, courseId:classroomDoc.courseId})
        imageTag = customTag
      else

        courseData = Courses.findOne _id:classroomDoc.courseId

        if courseData.dockerImage
          imageTag = courseData.dockerImage
        else
          imageTag = courseData.dockerImageTag

      # if courseData.bundleServer
      #   queryServer = courseData.bundleServer
      # else
      #   queryServer = {"user.group.id":"TaishinDataMining"}




      console.log "imageTag = ",imageTag

        # imageType = DockerImages.findOne({_id:imageId}).type
        # if DockerTypeConfig.find({userId:user._id,typeId:imageType}).count() is 0
        #   #FIXME: write a checking function for env vars
        #   throw new Meteor.Error(1002, "MUST Setting Type Configurations before running!")

      if db.dockerInstances.find({userId:user._id, imageTag:imageTag, $or:[{frozen:$exists:false},{frozen:false}]}).count() is 0
        @unblock()
        Meteor.call "runDocker", imageTag

  "selectPersonalQuota": (doc)->
    user = Meteor.user()
    if not user
      throw new Meteor.Error(401, "You need to login")

    schema = new SimpleSchema
      quota:
        type: String
      NCPU:
        type: Number
      Memory:
        type: Number
      tag:
        type: String

    check doc, schema

    Memory = doc.Memory * 1024 * 1024

    @unblock()

    Meteor.call "runDockerLimit",doc.tag, {type:"forPersonal",id:doc.quota}, {NCPU:doc.NCPU, Memory:Memory}

  "selectGroupQuota":(doc)->

    user = Meteor.user()
    if not user
      throw new Meteor.Error(401, "You need to login")

    schema = new SimpleSchema
      quota:
        type: String
      usageLimit:
        type: String
      tag:
        type: String

    check doc, schema

    console.log doc

    @unblock()

    Meteor.call "runDockerLimit",doc.tag, {type:"forGroup",id:doc.quota}, {name:doc.usageLimit}


