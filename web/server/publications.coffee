
PUB_NODES_LIMIT = 50

Meteor.publish "course", (courseId)->
  Courses.find _id:courseId
  
Meteor.publish "allPublicClassrooms", (courseId)->
  courseDoc = Courses.findOne _id:courseId
  if courseDoc.publicStatus is "public"
    if Classrooms.find({courseId:courseId,publicStatus:"public"}).count() is 0
      publicClassroomDoc = 
        creatorId: courseDoc.creatorId
        courseId: courseDoc._id
        publicStatus:"public"
        createAt: new Date
        managerIds: [courseDoc.creatorId]
      classroomId = Classrooms.insert publicClassroomDoc

      ClassroomManagers.insert {classroomId:classroomId, managerId: courseDoc.creatorId}

    Classrooms.find {courseId:courseId,publicStatus:"public"}    

Meteor.publish "allPublicClassroomManagers", (courseId)->
  publicClassroomIds = Classrooms.find({courseId:courseId,publicStatus:"public"}).map (classroomDoc) -> classroomDoc._id
  ClassroomManagers.find classroomId:{$in:publicClassroomIds}


Meteor.publish "allPublicCoursesDockerImages", ->
  allPublicCoursesDockerIds = Courses.find({"publicStatus" : "public"}).fetch().map (courseDoc) -> courseDoc.dockerImage
  DockerImages.find _id:{$in:allPublicCoursesDockerIds}


Meteor.publish "allPublicCourses", ->
  Courses.find {"publicStatus" : "public"}


Meteor.publish "allDockerImages", ->
  if Roles.userIsInRole @userId, "admin", "dockers"
    DockerImages.find()
  else
    DockerImages.find _id: "permisionDeny"


Meteor.publish "allDockerInstances", ->
  if Roles.userIsInRole @userId, "admin", "dockers"
    DockerInstances.find()
  else
    DockerInstances.find _id: "permisionDeny"



Meteor.publish "allLearningResources", ->
  if Roles.userIsInRole @userId, "admin", "system"
    LearningResources.find()
  else
    LearningResources.find _id:"permisionDeny"


Meteor.publish "queryLearningResources", (query) ->
  if not query
    query = {}
  if Roles.userIsInRole @userId, "admin", "system"
    LearningResources.find query, {limit:PUB_NODES_LIMIT}
  else
    LearningResources.find _id:"permisionDeny"


Meteor.publish "allUsers", ->
  if Roles.userIsInRole @userId, "admin", "system"
    Meteor.users.find()
  else
    Meteor.users.find _id:"permisionDeny"


# Meteor.publish "myRoles", ->
#   Roles.find userId:@userId

Meteor.publish "dockers", ->
  if not @userId
    throw new Meteor.Error(401, "You need to login")

  Dockers.findOnd userId:@userId



Meteor.publish "allDockerImagesOld", ->
  # TODO: different roles can access different images ...
  DockerImages.find()

Meteor.publish "allDockerTypes", ->
  DockerTypes.find()

Meteor.publish "oneDockerTypes", (typeId) ->
  DockerTypes.find _id:typeId

Meteor.publish "userDockers", ->
  userId = @userId

  if not userId
    throw new Meteor.Error(401, "You need to login")

  Dockers.find userId:userId


Meteor.publish "userDockerInstances", ->
  userId = @userId

  if userId
    DockerInstances.find {userId:userId}

Meteor.publish "userDockerTypeConfig", ->
  userId = @userId

  if userId
    DockerTypeConfig.find {userId:userId}


Meteor.publish "allCourses", ->
  Courses.find()

Meteor.publish "Chat", (courseId) ->
  Chat.find({courseId:courseId}, {sort: {createAt:-1}, limit:20})

Meteor.publish "WantedFeature", ->
  WantedFeature.find()

Meteor.publish "DevMileStone", ->
  DevMileStone.find()
