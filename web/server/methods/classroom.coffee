Meteor.methods
  "joinClassroom": (classroomId) ->
    loginedUserId = Meteor.userId()

    if not loginedUserId
      throw new Meteor.Error(401, "You need to login")

    courseId = db.classrooms.findOne({_id: classroomId}).courseId

    # console.log "courseId = ",courseId
    # console.log Is.course(courseId, "admin")

    if Is.course(courseId, "admin")
      new Role({type:"classroom",id:classroomId},"admin").add_f(loginedUserId)

    # console.log Is.course(courseId, "member")
    if Is.course(courseId, "member")
      new Role({type:"classroom",id:classroomId},"student").add_f(loginedUserId)




