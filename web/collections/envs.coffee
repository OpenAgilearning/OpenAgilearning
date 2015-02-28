
@EnvConfigTypes = new Mongo.Collection "envConfigTypes"
# @EnvTypePorts = new Mongo.Collection "envTypePorts"
# @EnvTypeVars = new Mongo.Collection "envTypeVars"

@EnvUserConfigs = new Mongo.Collection "envUserConfigs"



@getEnvConfigTypeIdFromClassroomId = (classroomId) ->
  classroomDoc = Classrooms.findOne _id:classroomId
  courseData = Courses.findOne _id:classroomDoc.courseId
  imageTag = courseData.dockerImage

  #TODO: Need to change DockerImages to EnvUserConfigs
  configTypeId = DockerImages.findOne({_id:imageTag})?.type



Meteor.methods
  "setEnvConfigsById": (data) ->
    loggedInUserId = Meteor.userId()

    if not loggedInUserId
      throw new Meteor.Error(401, "You need to login")

    if EnvConfigTypes.find({_id:data.configTypeId}).count() is 0
      throw new Meteor.Error(1001, "configTypeId Error!")

    configTypeId = data.configTypeId

    delete data.configTypeId
    configData =
      configData: Object.keys(data).map (key) -> {key:key,value:data[key]}

    console.log "configData = "
    console.log configData

    query =
      userId: loggedInUserId
      configTypeId: configTypeId

    EnvUserConfigs.upsert query, {$set:configData}


  "setEnvConfigs": (data) ->
    loggedInUserId = Meteor.userId()

    if not loggedInUserId
      throw new Meteor.Error(401, "You need to login")

    classroomId = data.classroomId
    courseId = Classrooms.findOne({_id: classroomId}).courseId
    if courseId and classroomId
      classroomAndId = "classroom_" + classroomId
      notAssessDenied = loggedInUserId and Roles.userIsInRole(loggedInUserId,["admin","teacher","student"],classroomAndId)

      if notAssessDenied
        console.log "data = "
        console.log data
        configTypeId = getEnvConfigTypeIdFromClassroomId(classroomId)
        #FIXME: need to gen schema and check data before insert
        delete data.classroomId

        configData = Object.keys(data).map (key) -> {key:key,value:data[key]}

        EnvUserConfigs.insert userId:loggedInUserId, configTypeId:configTypeId, configData:configData
      else
        throw new Meteor.Error(403, "Access denied")

    else
      console.log "TODO:raise error"


