
Meteor.methods
  "setSystemAdmin": (userId) ->
    loggedInUserId = Meteor.userId()

    if not loggedInUserId
      throw new Meteor.Error(401, "You need to login")
    
    if Roles.userIsInRole loggedInUserId, "admin", "system"
      if Meteor.users.find({_id:userId}).count() > 0
        Roles.addUsersToRoles userId, "admin", "system" 
      else
        throw new Meteor.Error(1302, "[Admin Error] there is no user with id" + userId)
    
    else
      throw new Meteor.Error(1301, "[Admin Error] permision deny")
    
  "removeSystemAdmin": (userId) ->
    loggedInUserId = Meteor.userId()

    if not loggedInUserId
      throw new Meteor.Error(401, "You need to login")
    
    if Roles.userIsInRole loggedInUserId, "admin", "system"
      if Meteor.users.find({_id:userId}).count() > 0
        Roles.setUserRoles userId, [] , "system" 
      else
        throw new Meteor.Error(1302, "[Admin Error] there is no user with id" + userId)
    
    else
      throw new Meteor.Error(1301, "[Admin Error] permision deny")

      
  "setCourseManager": (userId) ->
    loggedInUserId = Meteor.userId()

    if not loggedInUserId
      throw new Meteor.Error(401, "You need to login")
    
    if Roles.userIsInRole loggedInUserId, "admin", "system"
      if Meteor.users.find({_id:userId}).count() > 0
        Roles.addUsersToRoles userId, "manager", "courses" 
      else
        throw new Meteor.Error(1302, "[Admin Error] there is no user with id" + userId)
    
    else
      throw new Meteor.Error(1301, "[Admin Error] permision deny")
    
  "removeCourseManager": (userId) ->
    loggedInUserId = Meteor.userId()

    if not loggedInUserId
      throw new Meteor.Error(401, "You need to login")
    
    if Roles.userIsInRole loggedInUserId, "admin", "system"
      if Meteor.users.find({_id:userId}).count() > 0
        targetUser = Meteor.users.findOne _id:userId 
        removedRoles = targetUser.roles.courses.filter (xx)-> xx isnt "manager"
        Roles.setUserRoles userId, removedRoles , "courses" 
      else
        throw new Meteor.Error(1302, "[Admin Error] there is no user with id" + userId)
    
    else
      throw new Meteor.Error(1301, "[Admin Error] permision deny")
      
  "setTeacher": (userId) ->
    loggedInUserId = Meteor.userId()

    if not loggedInUserId
      throw new Meteor.Error(401, "You need to login")
    
    if Roles.userIsInRole loggedInUserId, "admin", "system"
      if Meteor.users.find({_id:userId}).count() > 0
        Roles.addUsersToRoles userId, "teacher", "courses" 
      else
        throw new Meteor.Error(1302, "[Admin Error] there is no user with id" + userId)
    
    else
      throw new Meteor.Error(1301, "[Admin Error] permision deny")
    
  "removeTeacher": (userId) ->
    loggedInUserId = Meteor.userId()

    if not loggedInUserId
      throw new Meteor.Error(401, "You need to login")
    
    if Roles.userIsInRole loggedInUserId, "admin", "system"
      if Meteor.users.find({_id:userId}).count() > 0
        targetUser = Meteor.users.findOne _id:userId 
        removedRoles = targetUser.roles.courses.filter (xx)-> xx isnt "teacher"
        Roles.setUserRoles userId, removedRoles , "courses" 
      else
        throw new Meteor.Error(1302, "[Admin Error] there is no user with id" + userId)
    
    else
      throw new Meteor.Error(1301, "[Admin Error] permision deny")
      


  "setStudent": (userId) ->
    loggedInUserId = Meteor.userId()

    if not loggedInUserId
      throw new Meteor.Error(401, "You need to login")
    
    if Roles.userIsInRole loggedInUserId, "admin", "system"
      if Meteor.users.find({_id:userId}).count() > 0
        Roles.addUsersToRoles userId, "student", "courses" 
      else
        throw new Meteor.Error(1302, "[Admin Error] there is no user with id" + userId)
    
    else
      throw new Meteor.Error(1301, "[Admin Error] permision deny")
    
  "removeStudent": (userId) ->
    loggedInUserId = Meteor.userId()

    if not loggedInUserId
      throw new Meteor.Error(401, "You need to login")
    
    if Roles.userIsInRole loggedInUserId, "admin", "system"
      if Meteor.users.find({_id:userId}).count() > 0
        targetUser = Meteor.users.findOne _id:userId 
        removedRoles = targetUser.roles.courses.filter (xx)-> xx isnt "student"
        Roles.setUserRoles userId, removedRoles , "courses" 
      else
        throw new Meteor.Error(1302, "[Admin Error] there is no user with id" + userId)
    
    else
      throw new Meteor.Error(1301, "[Admin Error] permision deny")
      

  "setDockerAdmin": (userId) ->
    loggedInUserId = Meteor.userId()

    if not loggedInUserId
      throw new Meteor.Error(401, "You need to login")
    
    if Roles.userIsInRole loggedInUserId, "admin", "system"
      if Meteor.users.find({_id:userId}).count() > 0
        Roles.addUsersToRoles userId, "admin", "dockers" 
      else
        throw new Meteor.Error(1302, "[Admin Error] there is no user with id" + userId)
    
    else
      throw new Meteor.Error(1301, "[Admin Error] permision deny")
    
  "removeDockerAdmin": (userId) ->
    loggedInUserId = Meteor.userId()

    if not loggedInUserId
      throw new Meteor.Error(401, "You need to login")
    
    if Roles.userIsInRole loggedInUserId, "admin", "system"
      if Meteor.users.find({_id:userId}).count() > 0
        targetUser = Meteor.users.findOne _id:userId 
        removedRoles = targetUser.roles.dockers.filter (xx)-> xx isnt "admin"
        Roles.setUserRoles userId, removedRoles , "dockers" 
      else
        throw new Meteor.Error(1302, "[Admin Error] there is no user with id" + userId)
    
    else
      throw new Meteor.Error(1301, "[Admin Error] permision deny")
  



