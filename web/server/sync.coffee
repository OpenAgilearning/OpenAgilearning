@syncDockerEnsureImages = ->
  ensureImages = db.dockerEnsureImages.find().fetch()

  for data in ensureImages
    imageTagData = db.dockerImageTags.findOne data.ensureImageTagId

    if imageTagData?.dockerHubId is "[DockerHub]OfficialDockerHub"
      dm = new Class.DockersManager data.serversQuery
      dm.ensureImage imageTagData.tag




syncDockerServerInfo = ->
  dockerServers = DockerServers.find().fetch()

  # console.log DockerServers.find({},{fields:{_id:1}}).fetch()

  for dockerServerData in dockerServers

    # console.log dockerServerData._id

    try
      docker = new Class.DockerServer(dockerServerData, UsefulCallbacks)
      resData = docker.info()

    catch e
      console.log "error = ", e

    # console.log "~~~~~~~~~~~~~~~~~~~~"
    # console.log "dockerServerData", dockerServerData
    # console.log "syncDockerServerInfo", resData


    # try
    #   resData = docker.info()
    # catch e
    #   console.log "error = ", e

syncDockerServerImageTags = ->
  dockerServers = DockerServers.find().fetch()

  for dockerServerData in dockerServers
    try
      docker = new Class.DockerServer(dockerServerData, UsefulCallbacks)
      resData = docker.listImageTags()
    catch e
      console.log "error = ", e


    # try
    #   resData = docker.listImageTags()
    # catch e
    #   console.log "error = ", e


syncDockerServerContainer = ->
  dockerServers = DockerServers.find().fetch()

  for dockerServerData in dockerServers
    docker = new Class.DockerServer(dockerServerData, UsefulCallbacks)
    resData = docker.listContainers()

# migrationJobWorker = ->
#   mJobs = db.migrationJobs.find().fetch()
#   for mJobData in mJobs
#     mJob = new Migration.Job "migrate chatMessages", chatmessageHandler
#     job_migrate_chatmessage.handle


@expiringUserQuota = ->
  nowTime = new Date().getTime()

  nonAdminQuery =
    expiredAt:
      $gt: 0

  expiringQuery =
    expired: false
    expiredAt:
      $lt: nowTime

  expiringQuotaIds = db.dockerPersonalUsageQuota.find({$and:[nonAdminQuery, expiringQuery]}).map (doc)-> doc._id

  console.log "expiringQuotaIds = ",expiringQuotaIds

  expiringDockerInstances = db.dockerInstances.find({"quota.id":{$in:expiringQuotaIds}}).map (instanceDoc) ->
    docker = new Class.DockerServer instanceDoc.serverId
    # docker.stop instanceDoc.containerId
    # docker.rm instanceDoc.containerId
    docker.rmf instanceDoc.containerId

    console.log "delete instanceDoc = ", instanceDoc

    dockerInstanceDoc = instanceDoc
    db.dockerInstances.remove _id: dockerInstanceDoc._id

    dockerInstanceDoc.removeAt = new Date
    dockerInstanceDoc.removeBy = "expiringQuota"
    delete dockerInstanceDoc._id
    db.dockerInstancesLog.insert dockerInstanceDoc


  db.dockerPersonalUsageQuota.update {_id:{$in:expiringQuotaIds}}, {$set:{expired: true}}, {multi:true}


Meteor.setInterval syncDockerServerInfo, 10000
Meteor.setInterval syncDockerServerImageTags, 10000
Meteor.setInterval syncDockerServerContainer, 10000
Meteor.setInterval syncDockerEnsureImages, 600000

Meteor.setInterval expiringUserQuota, 60000