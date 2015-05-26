# @Fixture.DockerUsageQuota =
#   set: ->

#     adminMeetupIds = Meteor.settings.adminMeetupIds

#     console.log "adminMeetupIds = ", adminMeetupIds

#     if adminMeetupIds.length > 0
#       defaultAdminUidArray = Meteor.users.find({"services.meetup.id" : {$in:adminMeetupIds}}).fetch().map (xx)-> xx._id

#       console.log "defaultAdminUidArray = ",defaultAdminUidArray

#       for uid in defaultAdminUidArray
#         userQuotaData =
#           userId: uid
#           type: "personal" # bindingServer or freeTrial
#           expiredAt: -1
#           NCPU: -1
#           Memory: -1


#         if db.dockerUsageQuota.find(userQuotaData) is 0
#           db.dockerUsageQuota.insert userQuotaData




#         # if db.userIsRole.find(userIsRole).count() is 0
#         #   db.userIsRole.insert userIsRole


#   clear: ->
#     db.dockerUsageQuota.remove {}

#   reset: ->
#     @clear()
#     @set()



# Meteor.startup ->
#   Fixture.DockerUsageQuota.set()