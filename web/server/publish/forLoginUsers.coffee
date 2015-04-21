
Meteor.publish null, ->
  userId = @userId
  if userId
    dockerInstancesPUB = db.dockerInstances.find userId:userId

    userIsRolePUB = db.userIsRole.find userId:userId

    roleIds = userIsRolePUB.map (data)->data.roleId

    # console.log "roleIds = ", roleIds

    roleTypesPUB = db.roleTypes.find {_id:{$in:roleIds}}

    [dockerInstancesPUB,userIsRolePUB, roleTypesPUB]

  else
    []

Meteor.publish "userRoles", ->
  userId = @userId
  if userId
    userIsRolePUB = db.userIsRole.find userId:userId

    roleIds = userIsRolePUB.map (data)->data.roleId

    # console.log "roleIds = ", roleIds

    roleTypesPUB = db.roleTypes.find {_id:{$in:roleIds}}

    [userIsRolePUB, roleTypesPUB]


  else
    []



Meteor.publish "courseAdmin", (courseId)->
  userId = @userId

  if new Role({type:"course",id:courseId},"admin").check_f(userId)
    rolesPUB = db.roleTypes.find({group:{type:"course", id:courseId}})
    roleIds = rolesPUB.map (data)-> data._id
    userIsRolesPUB = db.userIsRole.find({roleId:{$in:roleIds}})
    userIds = userIsRolesPUB.map (data)-> data.userId
    console.log "userIds = ",userIds
    usersPUB = Meteor.users.find(_id:{$in:userIds},{fields:{profile:1}})
    [rolesPUB, userIsRolesPUB,usersPUB]

  else
    []



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
    if typeof collections is "string"
      db.Votes.find
        userId:userId
        collection: collections
    else
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
