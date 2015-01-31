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
    DockerServerContainers.find()
  else
    DockerServerContainers.find _id: "permisionDeny"

Meteor.publish "allDockerServerImages", ->
  if Roles.userIsInRole @userId, "admin", "dockers"
    DockerServerImages.find()
  else
    DockerServerImages.find _id: "permisionDeny"

Meteor.publish "allDockerServers", ->
  if Roles.userIsInRole @userId, "admin", "dockers"
    DockerServers.find()
  else
    DockerServers.find _id: "permisionDeny"

Meteor.publish "dockerServerImages", (dockerServerId)->
  if Roles.userIsInRole @userId, "admin", "dockers"
    DockerServerImages.find("dockerServerId":dockerServerId)
  else
    DockerServerImages.find _id: "permisionDeny"