
# Meteor.publish "myRoles", ->
#   Roles.find userId:@userId

Meteor.publish "dockers", ->
  if not @userId
    throw new Meteor.Error(401, "You need to login")
  
  Dockers.findOnd userId:@userId



Meteor.publish "allDockerImages", ->
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

