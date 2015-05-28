@Fixture.DockerUsageQuota =
  set: ->

    adminMeetupIds = Meteor.settings.adminMeetupIds

    console.log "adminMeetupIds = ", adminMeetupIds

    if adminMeetupIds.length > 0
      defaultAdminUidArray = Meteor.users.find({"services.meetup.id" : {$in:adminMeetupIds}}).fetch().map (xx)-> xx._id

      console.log "defaultAdminUidArray = ",defaultAdminUidArray

      for uid in defaultAdminUidArray
        defaultQuotas = []

        adminQuotaData =
          name: "adminQuota"
          userId: uid
          expiredAt: -1
          NCPU: -1
          Memory: -1
          expired: false

        defaultQuotas.push adminQuotaData

        dailyQuotaData =
          name: "oneDayQuota"
          userId: uid
          # expiredAt: new Date().getTime() + 1*24*60*60*1000
          NCPU: 1
          Memory: 512*1024*1024
          expired: false

        defaultQuotas.push dailyQuotaData

        trialQuotaData =
          name: "freeTrialQuota"
          userId: uid
          # expiredAt: new Date().getTime() + 15*60*1000
          NCPU: 1
          Memory: 512*1024*1024
          expired: false

        defaultQuotas.push trialQuotaData

        aLotOfQuotaData =
          name: "aLotOfQuota"
          userId: uid
          NCPU: 8
          Memory: 8 * 1024 * 1024 * 1024
          expired: false

        defaultQuotas.push aLotOfQuotaData


        for quota in defaultQuotas
          if db.dockerPersonalUsageQuota.find(quota).count() is 0

            if quota.name is "oneDayQuota"
              quota.expiredAt = new Date().getTime() + 1*24*60*60*1000
              db.dockerPersonalUsageQuota.insert quota

            if quota.name is "freeTrialQuota"
              quota.expiredAt = new Date().getTime() + 15*60*1000
              db.dockerPersonalUsageQuota.insert quota


            if quota.name is "adminQuota"
              db.dockerPersonalUsageQuota.insert quota

            if quota.name is "aLotOfQuota"
              quota.expiredAt = new Date().getTime() + 30 * 24 * 60 * 60 * 1000
              db.dockerPersonalUsageQuota.insert quota



        # if db.userIsRole.find(userIsRole).count() is 0
        #   db.userIsRole.insert userIsRole


  clear: ->
    db.dockerPersonalUsageQuota.remove {}

  reset: ->
    @clear()
    @set()



Meteor.startup ->
  Fixture.DockerUsageQuota.set()
