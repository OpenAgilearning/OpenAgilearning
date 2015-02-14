Template.registerHelper "isNotRole", (roles, groupType, groupId) ->
  RoleTools.isNotRole(roles, groupType, groupId)

Template.registerHelper "isRole", (roles, groupType, groupId) ->
  RoleTools.isRole(roles, groupType, groupId)
  
  # console.log "[Dev] forget to publish Collections.RoleGroups"   

  # userId = Meteor.userId()
    
  # if userId
  #   groupQuery = 
  #     type: groupType
  #     id: groupId


  #   groupData = Collections.RoleGroups.findOne groupQuery

  #   {collection, query} = groupData
  #   # console.log "[Dev] data with _id = " + query._id + " in " + collection
  #   if Collections[collection].find(query).count() is 0
  #     console.log "[Dev] cannot get the data with _id = " + query._id + " in " + collection

  #   if groupData
  #     groupId = groupData._id
  #     Collections.Roles.find({role:role,groupId:groupId,userId:userId}).count() > 0

