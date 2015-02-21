new Mongo.Collection "dockerServersMonitor"
new Mongo.Collection "dockerImageTagsMonitor"
new Mongo.Collection "dockerContainersMonitor"

@DockerServers = new Mongo.Collection "dockerServers"
@DockerServersException = new Mongo.Collection "dockerServersException"
@DockerServerImages = new Mongo.Collection "dockerServerImages"
@DockerServerContainers = new Mongo.Collection "dockerServerContainers"
@DockerServerContainersLog = new Mongo.Collection "dockerServerContainersLog"
@DockerServerPullImageLog = new Mongo.Collection "dockerServerPullImageLog"
@DockerServerPullImageScratch = new Mongo.Collection "dockerServerPullImageSratch"

@DockerConfigTypes = new Mongo.Collection "dockerConfigTypes"
@DockerImageIsConfigTypes = new Mongo.Collection "dockerImageIsConfigTypes"

@DockerUsageLimits = new Mongo.Collection "dockerUsageLimits"

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
