Meteor.methods
  "setClassroomRole": (classroomAndId,action,role,userId) ->
    
    loggedInUserId = Meteor.userId()

    if not loggedInUserId
      throw new Meteor.Error(401, "You need to login")
    
    if role not in ["teacher", "admin"]
      throw new Meteor.Error(401, "[Classroom Admin Error] " + role + "is not a valid role to "+ action)
    
    if Roles.userIsInRole loggedInUserId, "admin", classroomAndId
      if Meteor.users.find({_id:userId}).count() > 0
        
        if action is "add"
          Roles.addUsersToRoles userId, role, classroomAndId
        else
          targetUser = Meteor.users.findOne _id:userId 
          removedRoles = targetUser.roles[classroomAndId].filter (xx)-> xx isnt role
          Roles.setUserRoles userId, removedRoles , classroomAndId
      else
        throw new Meteor.Error(1302, "[Classroom Admin Error] there is no user with id" + userId)
    
    else
      throw new Meteor.Error(1301, "[Classroom Admin Error] permision deny, " + loggedInUserId + " is not an admin of " + classroomAndId)
    