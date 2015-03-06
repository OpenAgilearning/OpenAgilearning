# Meteor.methods
#   # This method is temporairy exit.
#   # FIXME: Need to refactor. Maybe can use simple schma to check the classroomId
#   validAdvitedCode: (doc)->
#     loggedInUserId = Meteor.userId()
#     if not loggedInUserId
#       throw new Meteor.Error(401, "You need to login")
#
#     classroomId = doc.code
#     classroom = db.classrooms.findOne _id:classroomId
#     if classroom?
#       index = "classroom_" + classroomId
#       userData = Meteor.user()
#       if not( index in Object.keys(userData.roles) )
#         Roles.addUsersToRoles(loggedInUserId, "student", index)
#     else
#       throw new Meteor.Error 2000, "Invalid invited code. Please check it again"
