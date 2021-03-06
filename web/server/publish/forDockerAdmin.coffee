# Meteor.publish "allEnvs", ->
#   if Roles.userIsInRole @userId, "admin", "dockers"
#     Envs.find()
#   else
#     Envs.find _id: "permisionDeny"



# Meteor.publish "allEnvTypes", ->
#   if Roles.userIsInRole @userId, "admin", "dockers"
#     EnvTypes.find()
#   else
#     EnvTypes.find _id: "permisionDeny"


Meteor.publish "allDockerImages", ->
  if Roles.userIsInRole @userId, "admin", "dockers"
    DockerImages.find()
  else
    DockerImages.find _id: "permisionDeny"


Meteor.publish "allDockerInstances", ->
  if Roles.userIsInRole @userId, "admin", "dockers"
    DockerInstances.find()
  else
    DockerInstances.find _id: "permisionDeny"

Meteor.publish "allDockerServerContainers", ->
  if Roles.userIsInRole @userId, "admin", "dockers"
    db.dockerContainersMonitor.find()
  else
    db.dockerContainersMonitor.find _id: "permisionDeny"

Meteor.publish "allDockerServerImages", ->
  if Roles.userIsInRole @userId, "admin", "dockers"
    db.dockerImageTagsMonitor.find()
  else
    db.dockerImageTagsMonitor.find _id: "permisionDeny"

Meteor.publish "allDockerServers", ->
  if Roles.userIsInRole @userId, "admin", "dockers"
    db.dockerServersMonitor.find({})
  else
    db.dockerServersMonitor.find _id: "permisionDeny"

Meteor.publish "dockerServerImages", (dockerServerId)->
  if Roles.userIsInRole @userId, "admin", "dockers"
    DockerServerImages.find("dockerServerId":dockerServerId)
  else
    DockerServerImages.find _id: "permisionDeny"
