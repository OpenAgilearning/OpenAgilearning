


Meteor.publish "userCourseRoles", ->
  userId = @userId

  if userId
    CourseRoles.find userId:userId
  else
    Exceptions.find {_id:"ExpectionPermissionDeny"}



Meteor.publish "userDockerServerContainers", ->
  userId = @userId

  if userId
    dockerInstances = DockerInstances.find({userId:userId}).fetch()
    containerIds = dockerInstances.map (xx)-> xx.containerId
    DockerServerContainers.find Id:{"$in":containerIds}

  else
    Exceptions.find {_id:"ExpectionPermissionDeny"}


Meteor.publish "userEnvUserConfigs", ->
  userId = @userId

  if userId
    EnvUserConfigs.find {userId:userId}

  else
    Exceptions.find {_id:"ExpectionPermissionDeny"}


Meteor.publish "userDockerInstances", ->
  userId = @userId

  if userId
    DockerInstances.find {userId:userId}

  else
    Exceptions.find {_id:"ExpectionPermissionDeny"}


Meteor.publish "userDockerTypeConfig", ->
  userId = @userId

  if userId
    DockerTypeConfig.find {userId:userId}

  else
    Exceptions.find {_id:"ExpectionPermissionDeny"}


Meteor.publish "userDockers", ->
  userId = @userId

  if userId
    Dockers.find userId:userId

  else
    Exceptions.find {_id:"ExpectionPermissionDeny"}


Meteor.publish "dockers", ->
  userId = @userId

  if userId
    Dockers.findOnd userId:userId

  else
    Exceptions.find {_id:"ExpectionPermissionDeny"}

