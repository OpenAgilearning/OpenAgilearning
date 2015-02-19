@DockerServers = new Meteor.Collection "dockerServers"
@DockerServersException = new Meteor.Collection "dockerServersException"
@DockerServerImages = new Meteor.Collection "dockerServerImages"
@DockerServerContainers = new Meteor.Collection "dockerServerContainers"
@DockerServerContainersLog = new Meteor.Collection "dockerServerContainersLog"
@DockerServerPullImageLog = new Meteor.Collection "dockerServerPullImageLog"
@DockerServerPullImageScratch = new Meteor.Collection "dockerServerPullImageSratch"

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


@Collections.DockerServers = @DockerServers
@Collections.DockerServerImages = @DockerServerImages

@Collections.DockerPullImageJob = new Mongo.Collection "dockerPullImageJob"
@Collections.DockerPullImageStream = new Mongo.Collection "dockerPullImageStream"
@Collections.DockerRunJob = new Mongo.Collection "dockerRunJob"


@db.dockerServers = @Collections.DockerServers 
@db.dockerServerImages = @Collections.DockerServerImages 

@db.dockerPullImageJob = @Collections.DockerPullImageJob
@db.dockerPullImageStream = @Collections.DockerPullImageStream
@db.dockerRunJob = @Collections.DockerRunJob


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

