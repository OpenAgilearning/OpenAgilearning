
Meteor.publish null, ->
  db.dockerImageTags.find()
  db.dockerServers.find({},{fields:{"connect.host":1}})


Meteor.publish "allLearningResources", ->
  LearningResources.find({},{limit : 50})

Meteor.publish "allPublicEnvConfigTypes", ->
  EnvConfigTypes.find publicStatus:"public"


Meteor.publish "allPublicEnvs", ->
  Envs.find publicStatus:"public"


Meteor.publish "allPublicCoursesDockerImages", ->
  allPublicCoursesDockerIds = Courses.find({"publicStatus" : "public"}).fetch().map (courseDoc) -> courseDoc.dockerImage
  DockerImages.find _id:{$in:allPublicCoursesDockerIds}


Meteor.publish "allPublicCourses", ->
  Courses.find {"publicStatus" : "public"}

Meteor.publish "allPublicAndSemipublicCourses", ->
  Courses.find {"publicStatus" : {$in:["public","semipublic"]}}


Meteor.publish "WantedFeature", ->
  WantedFeature.find()


Meteor.publish "DevMileStone", ->
  DevMileStone.find()


