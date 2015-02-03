Meteor.publish "allPublicCoursesDockerImages", ->
  allPublicCoursesDockerIds = Courses.find({"publicStatus" : "public"}).fetch().map (courseDoc) -> courseDoc.dockerImage
  DockerImages.find _id:{$in:allPublicCoursesDockerIds}


Meteor.publish "allPublicCourses", ->
  Courses.find {"publicStatus" : "public"}


Meteor.publish "WantedFeature", ->
  WantedFeature.find()


Meteor.publish "DevMileStone", ->
  DevMileStone.find()