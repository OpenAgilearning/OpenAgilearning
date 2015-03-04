
Meteor.publish null, ->
  userId = @userId
  if userId
    db.dockerInstances.find userId:userId


Meteor.publish "userRoles", (roleTypes=[])->
  userId = @userId
  if typeof(roleTypes) is "string"
    roleTypes = [roleTypes]

  if userId
    roleGroups = Collections.RoleGroups.find({type:{$in:roleTypes}})
    roleGroupsIds = roleGroups.fetch().map (xx) -> xx._id

    queryConditions = []

    # console.log roleGroupsIds

    for groupId in roleGroupsIds
      if Collections.Roles.find({role:"admin",groupId:groupId,userId:userId}).count() > 0
        queryCond =
          groupId: groupId
        queryConditions.push queryCond
      else
        queryCond =
          groupId: groupId
          userId:userId
        queryConditions.push queryCond

    # console.log queryConditions

    roles = Collections.Roles.find({$or:queryConditions})
    [roleGroups, roles]
  else
    Exceptions.find {_id:"ExceptionPermissionDeny"}



Meteor.publish "userDockerServerContainers", ->
  userId = @userId

  if userId
    dockerInstances = DockerInstances.find({userId:userId}).fetch()
    containerIds = dockerInstances.map (xx)-> xx.containerId
    DockerServerContainers.find Id:{"$in":containerIds}

  else
    Exceptions.find {_id:"ExceptionPermissionDeny"}


Meteor.publish "userEnvUserConfigs", ->
  userId = @userId

  if userId
    EnvUserConfigs.find {userId:userId}

  else
    Exceptions.find {_id:"ExceptionPermissionDeny"}


Meteor.publish "userDockerInstances", ->
  userId = @userId

  if userId
    DockerInstances.find {userId:userId}

  else
    Exceptions.find {_id:"ExceptionPermissionDeny"}


Meteor.publish "userDockerTypeConfig", ->
  userId = @userId

  if userId
    DockerTypeConfig.find {userId:userId}

  else
    Exceptions.find {_id:"ExceptionPermissionDeny"}


Meteor.publish "userDockers", ->
  userId = @userId

  if userId
    Dockers.find userId:userId

  else
    Exceptions.find {_id:"ExceptionPermissionDeny"}


Meteor.publish "dockers", ->
  userId = @userId

  if userId
    Dockers.findOnd userId:userId

  else
    Exceptions.find {_id:"ExceptionPermissionDeny"}

Meteor.publish "feedback", ->
  userId = @userId

  if userId
    Feedback.find()
  else
    Exceptions.find {_id:"ExceptionPermissionDeny"}

Meteor.publish "votes", (collections)->
  userId = @userId

  if userId
    db.Votes.find
      userId:userId
      collection:
        $in: collections
  else
    Exceptions.find {_id:"ExceptionPermissionDeny"}


Meteor.publish "userResume", ->
  userId = @userId

  if userId
    db.publicResume.find userId:userId
  else
    Exceptions.find {_id:"ExceptionPermissionDeny"}

Meteor.publish "registeredCourse", ->
  # console.log "[publish func] userId = #{@userId}"
  # console.log "[publish func] this = #{@}"
  userData = Meteor.users.findOne _id:@userId
  if userData?.roles?
    # console.log "[publish func] userData key = #{Object.keys userData }"
    # Get registered classrooms data
    keyArr = Object.keys userData.roles
    classIdArr = []
    keyArr.map (xx)->
      if xx isnt "system"
        classIdArr.push xx.split("_")[1]
    # Use classrooms' id to find course
    courseIdArr = []
    db.classrooms.find({_id: {$in : classIdArr } }).fetch().map (xxx)->
      courseIdArr.push xxx.courseId
    Courses.find { _id: {$in:courseIdArr} }
  else
    Courses.find {"publicStatus" : {$in:["public","semipublic"]}}
