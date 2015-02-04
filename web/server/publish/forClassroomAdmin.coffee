Meteor.publish "usersOfClassroom", (classroomId)->
  if Roles.userIsInRole @userId, "admin", ("classroom_" + classroomId)
    Meteor.users.find()