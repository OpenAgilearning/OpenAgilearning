
Meteor.publish "courseDockerImages", (courseId)->
  #FIXME: if someone know th id
  courseData = Courses.findOne _id:courseId
  DockerImages.find _id:courseData.dockerImage


Meteor.publish "course", (courseId)->
  #FIXME: if someone know th id
  Courses.find _id:courseId

Meteor.publish "allPublicClassrooms", (courseId)->
  courseDoc = Courses.findOne _id:courseId
  if courseDoc.publicStatus is "public"
    Classrooms.find {courseId:courseId,publicStatus:"public"}

Meteor.publish "allPublicClassroomRoles", (courseId)->
  publicClassroomIds = Classrooms.find({courseId:courseId,publicStatus:"public"}).map (classroomDoc) -> classroomDoc._id
  ClassroomRoles.find classroomId:{$in:publicClassroomIds}

Meteor.publish "relateClassrooms", (courseId) ->
  courseDoc = Courses.findOne _id:courseId
  Classrooms.find {courseId:courseId,publicStatus:courseDoc.publicStatus}

Meteor.publish "relateClassroomRoles", (courseId) ->
  courseDoc = Courses.findOne _id:courseId
  relateClassroomIds = Classrooms.find({courseId:courseId,publicStatus:courseDoc.publicStatus}).map (classroomDoc) -> classroomDoc._id
  ClassroomRoles.find classroomId:{$in:relateClassroomIds}

# Meteor.publish "Chat", (courseId) ->
#   Chat.find({courseId:courseId}, {sort: {createAt:-1}, limit:20})
