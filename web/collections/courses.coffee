
@LearningResources = new Mongo.Collection "learningResources"

@Collections.LearningResources = @LearningResources
@db.learningResources = @Collections.LearningResources

@db.slides = new Mongo.Collection "slides"
@db.videos = new Mongo.Collection "videos"
@db.websites = new Mongo.Collection "websites"

@db.courseJoinSlides = new Mongo.Collection "courseJoinSlides"
@db.courseJoinVideos = new Mongo.Collection "courseJoinVideos"
@db.courseJoinWebsites = new Mongo.Collection "courseJoinWebsites"
@db.courseJoinDockerImageTags = new Mongo.Collection "courseJoinDockerImageTags"

# @learningResourceSchema = new SimpleSchema
#   title:
#     type: String
#   description:
#     type: String
#   image:
#     type: String
#     optional: true
#   type:
#     type: String
#     allowedValues: ["video","website","slide","youtube"]
#     optional: true
#   url:
#     type: String
#     optional: true
#     regEx: SimpleSchema.RegEx.Url
#   youtubeVideoId:
#     type: String
#     optional: true
#   youtubePlaylistId:
#     type: String
#     optional: true




Meteor.methods
  "createLearningResource": (data) ->
    user = Meteor.user()

    if not user
      throw new Meteor.Error(401, "You need to login")

    data["creator"] = user._id
    data["creatorAt"] = new Date
    LearningResources.insert data



@Courses = new Mongo.Collection "courses"
# @CourseRoles = new Mongo.Collection "courseRoles"

@Collections.Courses = @Courses





