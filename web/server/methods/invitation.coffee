Meteor.methods
  "generateBundleServerGroupInvitationUrl": (groupId)->
    user = Meteor.user()
    if not user
      throw new Meteor.Error(401, "You need to login")

    group = db.bundleServerUserGroup.findOne _id:groupId

    if group
      if user._id in group.admins
        nowTime = new Date().getTime()
        doc =
          _id: Random.id 80
          purpose:"bundleServerGroup"
          groupId:groupId
          creator:user._id
          createdAt:nowTime
          expireAt: nowTime + 1*24*60*60*1000
          acceptUserIds: []

        db.invitation.insert doc

      else
        throw new Meteor.Error(401, "You ain't admin")
    else
      throw new Meteor.Error(401, "No such group")


  "acceptInvitation": (invitationId) ->
    console.log "TODO"