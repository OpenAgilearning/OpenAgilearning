@Classrooms = new Mongo.Collection "classrooms"
@ClassroomRoles = new Mongo.Collection "classroomRoles"

Meteor.methods
  "joinClassroom": (classroomId) ->
    loginedUserId = Meteor.userId()

    if not loginedUserId
      throw new Meteor.Error(401, "You need to login")

    courseId = Classrooms.findOne({_id: classroomId}).courseId
    classChatroom = Chatrooms.findOne(classroomId: classroomId)
    if courseId
      classroomAndId = "classroom_" + classroomId
      courseDoc = Courses.findOne _id:courseId
      if courseDoc
        if courseDoc.publicStatus is "public"
          Roles.addUsersToRoles loginedUserId, "student", classroomAndId
          UserJoinsChatroom.insert
            userId: loginedUserId
            userName: Meteor.users.findOne(_id: loginedUserId).profile.name
            chatroomName: classChatroom.name
            chatroomId: classChatroom._id

      else
        console.log "TODO:raise error"    
    else
      console.log "TODO:raise error"


