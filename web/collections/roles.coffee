

@Collections.Roles = new Meteor.Collection "agileaningRoles"
@Collections.RoleGroups = new Meteor.Collection "agileaningRoleGroups"


@RoleTools = {}

@RoleTools.getGroupId = (type, id) ->
  if Collections.RoleGroups.find().count() is 0
    console.log "[Dev] forget to publish Collections.RoleGroups"   
  groupQuery = 
    type: type
    id: id

  groupData = Collections.RoleGroups.findOne groupQuery
  if groupData
    groupData._id


@RoleTools.getGroupData = (type, id) ->
  if Collections.RoleGroups.find().count() is 0
    console.log "[Dev] forget to publish Collections.RoleGroups"   
  groupQuery = 
    type: type
    id: id

  Collections.RoleGroups.findOne groupQuery
  
@RoleTools.getRoles = (roles, groupType, groupId) ->
  
  if Collections.RoleGroups.find().count() is 0
    console.log "[Dev] forget to publish Collections.RoleGroups"   

  groupData = RoleTools.getGroupData(groupType, groupId)
  
  if groupData

    {collection, query} = groupData
    if Collections[collection].find(query).count() is 0
      console.log "[Dev] cannot get the data with _id = " + query._id + " in " + collection

    groupId = groupData._id

    if typeof(roles) is "string"
      Collections.Roles.find({role:roles,groupId:groupId})
    else
      Collections.Roles.find({role:{$in:roles},groupId:groupId})




if Meteor.isServer
  @RoleTools.isRole = (userId, roles, groupType, groupId) ->

    if userId
      
      # groupQuery = 
      #   type: groupType
      #   id: groupId


      # groupData = Collections.RoleGroups.findOne groupQuery

      groupData = RoleTools.getGroupData(groupType, groupId)

      if groupData
        groupId = groupData._id
        if typeof(roles) is "string"
          Collections.Roles.find({role:roles,groupId:groupId,userId:userId}).count() > 0
        else
          Collections.Roles.find({role:{$in:roles},groupId:groupId,userId:userId}).count() > 0


if Meteor.isClient

  @RoleTools.isRole = (roles, groupType, groupId) ->
  
    if Collections.RoleGroups.find().count() is 0
      console.log "[Dev] forget to publish Collections.RoleGroups"   

    userId = Meteor.userId()
      
    if userId
      # groupQuery = 
      #   type: groupType
      #   id: groupId


      # groupData = Collections.RoleGroups.findOne groupQuery

      groupData = RoleTools.getGroupData(groupType, groupId)
      
      if groupData

        {collection, query} = groupData
        if Collections[collection].find(query).count() is 0
          console.log "[Dev] cannot get the data with _id = " + query._id + " in " + collection

        groupId = groupData._id
        if typeof(roles) is "string"
          Collections.Roles.find({role:roles,groupId:groupId,userId:userId}).count() > 0
        else
          Collections.Roles.find({role:{$in:roles},groupId:groupId,userId:userId}).count() > 0

  @RoleTools.isNotRole = (roles, groupType, groupId) ->
  
    if Collections.RoleGroups.find().count() is 0
      console.log "[Dev] forget to publish Collections.RoleGroups"   

    userId = Meteor.userId()
      
    if userId
      # groupQuery = 
      #   type: groupType
      #   id: groupId


      # groupData = Collections.RoleGroups.findOne groupQuery

      groupData = RoleTools.getGroupData(groupType, groupId)
      
      if groupData

        {collection, query} = groupData
        if Collections[collection].find(query).count() is 0
          console.log "[Dev] cannot get the data with _id = " + query._id + " in " + collection

        groupId = groupData._id
        if typeof(roles) is "string"
          Collections.Roles.find({role:{$ne:roles},groupId:groupId,userId:userId}).count() > 0
        else
          Collections.Roles.find({role:{$nin:roles},groupId:groupId,userId:userId}).count() > 0






# Meteor.methods
#   "checkIsAdmin": ->
#     user = Meteor.user()
#     if not user
#       throw new Meteor.Error(401, "You need to login")
  
#     Roles.find({userId:user._id, role:"admin"}).count() > 0
