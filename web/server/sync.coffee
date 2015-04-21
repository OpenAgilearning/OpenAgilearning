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




Meteor.setInterval syncDockerServerInfo, 10000
Meteor.setInterval syncDockerServerImageTags, 10000
Meteor.setInterval syncDockerServerContainer, 10000
Meteor.setInterval syncDockerEnsureImages, 600000

