Meteor.publish "usersOfClassroom", (classroomId)->
  classroomAndId = "classroom_" + classroomId
  if Roles.userIsInRole @userId, "admin", classroomAndId
    # FIXME: expensive query
    Roles.getUsersInRole ["student","teacher","admin"],classroomAndId
  else
    Meteor.users.find _id: "permisionDeny"
