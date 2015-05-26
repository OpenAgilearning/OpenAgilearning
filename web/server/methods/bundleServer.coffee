
Meteor.methods

  "bundleServer.createGroup": (groupId, groupName, groupDescription) ->
    #TODO: middlewares
    if not @userId
      throw new Meteor.Error 401, "Login Required"
    if not groupId and not groupName
      throw new Meteor.Error "not-enough-arguments", "Group Name Required"
    if db.bundleServerUserGroup.find(groupId).count()
      throw new Meteor.Error "already-exists", "Group With ID Of #{groupId} Already Exists"
    db.bundleServerUserGroup.insert
      _id: groupId
      name: groupName
      desc: groupDescription
      members: [@userId]
      servers: []
      admins: [@userId]

  "bundleServer.addGroupMember": (groupId, userId) ->
    if not @userId
      throw new Meteor.Error 401, "Login Required"
    group = db.bundleServerUserGroup.findOne groupId
    if not group
      throw new Meteor.Error "group-not-found", "The Group You're Looking For Doesn't Exists"
    if @userId not in group.admins
      throw new Meteor.Error "permission-denied", "You're Not The Admin Of #{group.name}"
    db.bundleServerUserGroup.update groupId,
      $addToSet:
        members: userId

  "bundleServer.setMemberAsAdmin": (groupId, userId) ->
    if not @userId
      throw new Meteor.Error 401, "Login Required"
    group = db.bundleServerUserGroup.findOne groupId
    if not group
      throw new Meteor.Error "group-not-found", "The Group You're Looking For Doesn't Exists"
    if @userId not in group.admins
      throw new Meteor.Error "permission-denied", "You're Not The Admin Of #{group.name}"
    if userId not in group.members
      throw new Meteor.Error "user-not-in-group", "User Not In Group"
    db.bundleServerUserGroup.update groupId,
      $addToSet:
        admins: userId

  "bundleServer.removeAdminPermission": (groupId, userId) ->
    if not @userId
      throw new Meteor.Error 401, "Login Required"
    group = db.bundleServerUserGroup.findOne groupId
    if not group
      throw new Meteor.Error "group-not-found", "The Group You're Looking For Doesn't Exists"
    if @userId not in group.admins
      throw new Meteor.Error "permission-denied", "You're Not The Admin Of #{group.name}"
    if userId not in group.admins
      throw new Meteor.Error "user-not-admin", "User Is Not Admin Of The Group"
    db.bundleServerUserGroup.update groupId,
      $pull:
        admins: userId

  "bundleServer.removeMember": (groupId, userId) ->
    if not @userId
      throw new Meteor.Error 401, "Login Required"
    group = db.bundleServerUserGroup.findOne groupId
    if not group
      throw new Meteor.Error "group-not-found", "The Group You're Looking For Doesn't Exists"
    if @userId not in group.admins
      throw new Meteor.Error "permission-denied", "You're Not The Admin Of #{group.name}"
    if userId not in group.members
      throw new Meteor.Error "user-not-in-group", "User Not In Group"
    db.bundleServerUserGroup.update groupId,
      $pull:
        admins: userId
        members: userId

  "bundleServer.addServer": (groupId, serverId) ->
    if not @userId
      throw new Meteor.Error 401, "Login Required"
    unless Is.systemAdmin
      throw new Meteor.Error "permission-denied", "Permission Denied"
    group = db.bundleServerUserGroup.findOne groupId
    if not group
      throw new Meteor.Error "group-not-found", "The Group You're Looking For Doesn't Exists"
    if serverId in group.servers
      return
    server = db.dockerServers.findOne serverId
    if not server
      throw new Meteor.Error "docker-server-not-found", "Docker Server #{serverId} Not Found"
    db.bundleServerUserGroup.update groupId,
      $addToSet: servers: serverId


