
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

# Meteor.publish "Chat", (courseId) ->
#   Chat.find({courseId:courseId}, {sort: {createAt:-1}, limit:20})
