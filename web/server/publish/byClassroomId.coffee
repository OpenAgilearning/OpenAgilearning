
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

Meteor.publish "classExercises", (classroomId) ->

  Exercises.find {classroomId: classroomId}


Meteor.publish "usersOfClassroom", (classroomId)->
  classroomAndId = "classroom_" + classroomId
  if Roles.userIsInRole @userId, ["student","teacher","admin"], classroomAndId
    # FIXME: expensive query
    Roles.getUsersInRole ["student","teacher","admin"],classroomAndId
  else
    Meteor.users.find _id: "permisionDeny"


Meteor.publish "classroomVideos", (classroomId)->

  classroomDoc = Classrooms.findOne _id:classroomId
  if classroomDoc

    course_video_pairs = db.courseJoinVideos.find courseId:classroomDoc.courseId
    videoIds = course_video_pairs.map (doc)->doc.videoId
    db.videos.find _id:$in:videoIds
  else
    db.videos.find _id:"permisionDeny"

Meteor.publish "classroomSlides", (classroomId)->

  classroomDoc = Classrooms.findOne _id:classroomId
  if classroomDoc

    course_slide_pairs = db.courseJoinSlides.find courseId:classroomDoc.courseId
    slideIds = course_slide_pairs.map (doc)->doc.slideId
    db.slides.find _id:$in:slideIds
  else
    db.slides.find _id:"permisionDeny"


Meteor.publish "classroomCourseJoinDockerImageTags", (classroomId)->

  classroomDoc = Classrooms.findOne _id:classroomId
  if classroomDoc

    db.courseJoinDockerImageTags.find courseId:classroomDoc.courseId

  else
    db.courseJoinDockerImageTags.find _id:"permisionDeny"