

# Meteor.publish "myRoles", ->
#   Roles.find userId:@userId


Meteor.publish "allDockerImagesOld", ->
  # TODO: different roles can access different images ...
  DockerImages.find()

Meteor.publish "allDockerTypes", ->
  DockerTypes.find()

Meteor.publish "oneDockerTypes", (typeId) ->
  DockerTypes.find _id:typeId




