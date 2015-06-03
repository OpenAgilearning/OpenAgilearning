PUB_NODES_LIMIT = 50

Meteor.publish "allLearningResources", ->
  if Roles.userIsInRole @userId, "admin", "system"
    LearningResources.find()
  else
    LearningResources.find _id:"permisionDeny"


Meteor.publish "queryLearningResources", (query) ->
  if not query
    query = {}
  if Roles.userIsInRole @userId, "admin", "system"
    LearningResources.find query, {limit:PUB_NODES_LIMIT}
  else
    LearningResources.find _id:"permisionDeny"


Meteor.publish "allUsers", ->
  if Roles.userIsInRole @userId, "admin", "system"
    Meteor.users.find()
  else
    Meteor.users.find _id:"permisionDeny"

Meteor.publish "personalQuotaInvitation",->
  if Roles.userIsInRole @userId, "admin", "system"
    nowTime = new Date().getTime()
    db.invitation.find {purpose: "personalQuota", expireAt:$gt:nowTime}

  else
    Exceptions.find _id:"ExceptionPermissionDeny"