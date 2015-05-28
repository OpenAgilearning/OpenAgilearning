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
          acceptedUserIds: []

        db.invitation.insert doc

      else
        throw new Meteor.Error(401, "You ain't admin")
    else
      throw new Meteor.Error(401, "No such group")


  "acceptBundleServerGroupInvitation": (invitationId) ->
    user = Meteor.user()
    if not user
      throw new Meteor.Error(401, "You need to login")

    invitationData = db.invitation.findOne _id: invitationId

    if not invitationData
      throw new Meteor.Error(401, "There is no invitation data!")

    else
      db.bundleServerUserGroup.update {_id:invitationData.groupId}, {$push:{members:user._id}}
      db.invitation.update {_id:invitationId}, {$push:{acceptedUserIds:user._id}}


