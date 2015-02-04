Meteor.publish "userEnvUserConfigs", ->
  userId = @userId

  if userId
    EnvUserConfigs.find {userId:userId}


Meteor.publish "userDockerInstances", ->
  userId = @userId

  if userId
    DockerInstances.find {userId:userId}


Meteor.publish "userDockerTypeConfig", ->
  userId = @userId

  if userId
    DockerTypeConfig.find {userId:userId}


Meteor.publish "userDockers", ->
  userId = @userId

  if userId
    Dockers.find userId:userId


Meteor.publish "dockers", ->
  userId = @userId

  if userId
    Dockers.findOnd userId:userId

