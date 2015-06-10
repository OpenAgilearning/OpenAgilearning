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
        db.bundleServerUserGroup.update {_id:invitationData.groupId}, {$addToSet:{members:user._id}}
        db.invitation.update {_id:invitationId}, {$push:{acceptedUserIds:user._id}}
      else if invitationData.purpose is  "personalQuota"
        console.log invitationData,"dealing with personalQuota"

        quota_life = invitationData.quota_life or 1*24*60*60*1000
        quota_name = invitationData.quota_name or "Free Trial Quota"
        quota_NCPU = invitationData.quota_NCPU or 1
        quota_memory = invitationData.quota_memory or 512*1024*1024

        nowTime = new Date().getTime()

        expiredAt = nowTime + quota_life

        QuotaData =
          name: quota_name
          userId: user._id
          NCPU: quota_NCPU
          Memory: quota_memory
          expired: false
          expiredAt: expiredAt
          invitationId:invitationData._id


        db.dockerPersonalUsageQuota.insert QuotaData
        db.invitation.update {_id:invitationId}, {$push:{acceptedUserIds:user._id},$set:{expired: yes}}

      else
        throw new Meteor.Error(401, "Something wrong with the invitation purpose")
    else
      throw new Meteor.Error(401, "There is no invitation data!")



  "generatePersonalQuotaInvitationUrl": (inputDoc)->

    #TODO: Validate quotaType, maybe. since this method only accessible by system admins, no need to implement now.

    user = Meteor.user()
    if not user
      throw new Meteor.Error(401, "You need to login")

    if Is.systemAdmin
      nowTime = new Date().getTime()

      unless inputDoc.quota_life
        inputDoc.quota_life = 1*24*60*60*1000

      unless inputDoc.quota_name
        inputDoc.quota_name = "Free Trial Quota"

      unless inputDoc.quota_NCPU
        inputDoc.quota_NCPU = 1

      unless inputDoc.quota_memory
        inputDoc.quota_memory = 512*1024*1024

      doc =
        _id: Random.id 80
        purpose:"personalQuota"
        creator:user._id
        createdAt:nowTime
        expireAt: nowTime + 1*24*60*60*1000
        expired: false
        acceptedUserIds: []
        quota_life: inputDoc.quota_life
        quota_name: inputDoc.quota_name
        quota_NCPU: inputDoc.quota_NCPU
        quota_memory: inputDoc.quota_memory


      db.invitation.insert doc
    else
      throw new Meteor.Error(401, "You are not a System admin, you have no power here! HaHa")
