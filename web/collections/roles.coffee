
new Meteor.Collection "roleTypes"
new Meteor.Collection "userIsRole"


@Role = class Role
  constructor: (@group={},@role="admin")->

    handsOnApis =
      query:
        desc:
          get: ->
            group: @group
            role: @role

      id:
        desc:
          get: ->
            db.roleTypes.findOne(@query)?._id


      check:
        desc:
          get: ->
            userId = Meteor.userId()

            if @id
              userInRoleQuery =
                roleId: @id
                userId: userId

              db.userIsRole.find(userInRoleQuery).count() > 0


    for api in Object.keys(handsOnApis)
      Object.defineProperty @, api, handsOnApis[api].desc


  setGroupType: (type)->
    @group.type = type
    @

  setGroupId: (id)->
    @group.id = id
    @

  setRole: (role)->
    @role = role
    @


if Meteor.isClient
  Role::add = (userId)->
    add.Role userId, @group, @role

else
  Role::add = (userId)->
    groupAdminCheck = new @constructor(@group,"admin").check
    systemAdminCheck = new @constructor({type:"agilearning"},"admin").check

    if groupAdminCheck or systemAdminCheck
      data =
        roleId: @id
        userId: userId

      if db.userIsRole.find(data).count() is 0
        db.userIsRole.insert data
      else
        db.userIsRole.findOne(data)._id

    else
      throw new Meteor.Error(1301, "[Admin Error] permision deny")


  Meteor.methods
    addRole: (userId, group, role)->
      loggedInUserId = Meteor.userId()

      if not loggedInUserId
        throw new Meteor.Error(401, "You need to login")

      new Role(group,role).add userId



@Is =
  course: (courseId, role) ->
    new Role({type:"course",id:courseId}, role).check

  classrooom: (classroomId, role) ->
    new Role({type:"classroom",id:classroomId}, role).check


Object.defineProperty Is, "systemAdmin",
  get: ->
    new Role({type:"agilearning.io"},"admin").check

Object.defineProperty Is, "dockerAdmin",
  get: ->
    new Role({type:"docker"},"admin").check









@Collections.Roles = new Meteor.Collection "agileaningRoles", {maskName:"roles"}
@Collections.RoleGroups = new Meteor.Collection "agileaningRoleGroups", {maskName:"roleGroups"}

@db.roles = @Collections.Roles
@db.roleGroups = @Collections.RoleGroups


@RoleTools = {}

@RoleTools.getGroupId = (type, id) ->
  # if Collections.RoleGroups.find().count() is 0
  #   console.log "[Dev] forget to publish Collections.RoleGroups"

  groupQuery =
    type: type

  if id
    groupQuery.id = id

  groupData = Collections.RoleGroups.findOne groupQuery
  if groupData
    groupData._id


@RoleTools.getGroupData = (type, id) ->
  # if Collections.RoleGroups.find().count() is 0
  #   console.log "[Dev] forget to publish Collections.RoleGroups"
  groupQuery =
    type: type

  if id
    groupQuery.id = id

  Collections.RoleGroups.findOne groupQuery

@RoleTools.getRoles = (roles, groupType, groupId) ->

  # if Collections.RoleGroups.find().count() is 0
  #   console.log "[Dev] forget to publish Collections.RoleGroups"

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

    # console.log "roles = "
    # console.log roles

    # if Collections.RoleGroups.find().count() is 0
    #   console.log "[Dev] forget to publish Collections.RoleGroups"

    userId = Meteor.userId()

    if userId
      # groupQuery =
      #   type: groupType
      #   id: groupId


      # groupData = Collections.RoleGroups.findOne groupQuery

      groupData = RoleTools.getGroupData(groupType, groupId)

      if groupData

        if groupData.collection and groupData.query
          {collection, query} = groupData
          if Collections[collection].find(query).count() is 0
            console.log "[Dev] cannot get the data with _id = " + query._id + " in " + collection

        groupId = groupData._id
        # console.log groupData

        if typeof(roles) is "string"
          Collections.Roles.find({role:roles,groupId:groupId,userId:userId}).count() > 0
        else
          Collections.Roles.find({role:{$in:roles},groupId:groupId,userId:userId}).count() > 0

  @RoleTools.isNotRole = (roles, groupType, groupId) ->

    # if Collections.RoleGroups.find().count() is 0
    #   console.log "[Dev] forget to publish Collections.RoleGroups"

    userId = Meteor.userId()

    if userId
      # groupQuery =
      #   type: groupType
      #   id: groupId


      # groupData = Collections.RoleGroups.findOne groupQuery

      groupData = RoleTools.getGroupData(groupType, groupId)

      if groupData

        if groupData.collection and groupData.query
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
