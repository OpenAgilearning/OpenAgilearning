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
          purpose:"bundleServerGroup"
          groupId:groupId
          admin:user._id
          createdAt:nowTime
          url: Random.id 20
          expireAt: nowTime + 1*24*60*60*1000

        db.invitation.update({groupId:groupId, purpose:"bundleServerGroup"}, doc, multi:no, upsert:yes)

      else
        throw new Meteor.Error(401, "You ain't admin")
    else
      throw new Meteor.Error(401, "No such group")


