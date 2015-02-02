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


Meteor.publish "classChatroom", (classroomId) ->

  ChatMessages.find {classroomId: classroomId}