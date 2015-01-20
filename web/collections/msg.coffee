@DevMileStone = new Meteor.Collection "devMileStone"

@WantedFeature = new Meteor.Collection "wantedFeature"

@devMileStoneSchema = new SimpleSchema
  version:
    type: String

  description:
    type: String
    label: "Feature description"
    autoform:
      rows:6

# DevMileStone.attachSchema devMileStoneSchema

@wantedFeatureSchema = new SimpleSchema
  hot:
    optional: true
    type: Number

  description:
    type: String
    label: "Feature description"
    autoform:
      rows:4
  upvoter:
    optional: true
    type: [String]
  downvoter:
    optional: true
    type: [String]



# WantedFeature.attachSchema wantedFeatureSchema

Meteor.methods
  "postDevMilestone": (autoFormData)->
    if not user
      throw new Meteor.Error(401, "You need to login !")
    user = Meteor.user()
    autoFormData["creator"] = user._id
    autoFormData["creatorName"] = user.profile.name
    autoFormData["atCreate"] = new Date
    DevMileStone.insert autoFormData

  "postWantedFeature": (featureData)->
    user = Meteor.user()
    if not user
      throw new Meteor.Error(401, "You need to login !")
    featureData["hot"] = 1
    featureData["creator"] = user._id
    featureData["creatorName"] = user.profile.name
    featureData["atCreate"] = new Date
    featureData["upvoterName"] = [user.profile.name]
    featureData["upvoter"] = [user._id]
    WantedFeature.insert featureData

  "upvoteFeatureMethod": (res, btnId)->
    WantedFeature.update {_id:btnId}, {$set:res}

  "cancelUpvoteFeatureMethod": (res, btnId)->
    WantedFeature.update {_id:btnId}, {$set:res}