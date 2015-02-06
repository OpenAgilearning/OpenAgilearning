
# FIXME: no courseId bug
# Meteor.publish "userDockerInstances", (classroomId)->
#   userId = @userId

#   if userId
#     classroomDoc = Classrooms.findOne _id:classroomId
    
#     console.log "classroomDoc = "
#     console.log classroomDoc

#     courseData = Courses.findOne _id:classroomDoc.courseId
#     imageTag = courseData.dockerImage
#     if imageTag.split(":").length is 1
#       fullImageTag = imageTag + ":latest"
#     else
#       fullImageTag = imageTag


#     DockerInstances.find {userId:userId,imageTag:fullImageTag}


Meteor.publish "classroomCourse", (classroomId)->
  #FIXME: if someone know th id
  classroomDoc = Classrooms.findOne _id:classroomId
  if classroomDoc
    Courses.find _id:classroomDoc.courseId


Meteor.publish "classroom", (classroomId)->
  #FIXME: if someone know th id
  Classrooms.find _id:classroomId
  

Meteor.publish "classroomDockerImages", (classroomId)->
  #FIXME: if someone know th id
  classroomDoc = Classrooms.findOne _id:classroomId
  if classroomDoc
    courseData = Courses.findOne _id:classroomDoc.courseId
    if courseData
      DockerImages.find _id:courseData.dockerImage


Meteor.publish "classChatroomMessages", (classroomId) ->
  ChatMessages.find {classroomId: classroomId}


Meteor.publish "classChatroom", (classroomId) ->
  Chatrooms.find {classroomId: classroomId}