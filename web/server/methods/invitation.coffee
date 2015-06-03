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
          expired: false
          acceptedUserIds: []

        db.invitation.insert doc

      else
        throw new Meteor.Error(401, "You ain't admin")
    else
      throw new Meteor.Error(401, "No such group")


  "acceptInvitation": (invitationId) ->
    user = Meteor.user()
    if not user
      throw new Meteor.Error(401, "You need to login")

    invitationData = db.invitation.findOne {_id: invitationId, expired:false}

    if invitationData
      if invitationData.purpose is  "bundleServerGroup"
        db.bundleServerUserGroup.update {_id:invitationData.groupId}, {$push:{members:user._id}}
        db.invitation.update {_id:invitationId}, {$push:{acceptedUserIds:user._id}}
      else if invitationData.purpose is  "personalQuota"
        console.log invitationData,"dealing with personalQuota"

        nowTime = new Date().getTime()

        expiredAt = nowTime + (invitationData?.quotaLife or 1*24*60*60*1000)

        if invitationData?.quotaType  is "aLotOfQuota"
          QuotaData =
            name: "aLotOfQuota"
            userId: user._id
            NCPU: 8
            Memory: 8 * 1024 * 1024 * 1024
            expired: false
            expiredAt: expiredAt

        else if invitationData?.quotaType  is "freeTrialQuota"
          QuotaData =
            name: "freeTrialQuota"
            userId: user._id
            NCPU: 1
            Memory: 512*1024*1024
            expired: false
            expiredAt: expiredAt
        else
          throw new Meteor.Error(401, "invalid quota type")


        db.dockerPersonalUsageQuota.insert QuotaData
        db.invitation.update {_id:invitationId}, {$push:{acceptedUserIds:user._id},$set:{expired: yes}}

      else
        throw new Meteor.Error(401, "Something wrong with the invitation purpose")
    else
      throw new Meteor.Error(401, "There is no invitation data!")


  "generatePersonalQuotaInvitationUrl": (quotaType, quotaLife)->

    #TODO: Validate quotaType, maybe. since this method only accessible by system admins, no need to implement now.

    user = Meteor.user()
    if not user
      throw new Meteor.Error(401, "You need to login")

    if Is.systemAdmin
      nowTime = new Date().getTime()

      unless quotaLife
        quotaLife = 1*24*60*60*1000

      doc =
        _id: Random.id 80
        purpose:"personalQuota"
        creator:user._id
        createdAt:nowTime
        expireAt: nowTime + 1*24*60*60*1000
        expired: false
        acceptedUserIds: []
        quotaType: quotaType
        quotaLife: quotaLife

      db.invitation.insert doc
    else
      throw new Meteor.Error(401, "You are not a System admin, you have no power here! HaHa")
