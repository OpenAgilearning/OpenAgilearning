@db.Votes = new Mongo.Collection "votes"

#######
#Sample Usage:

#    data =
#      objectId: @_id
#      degree: 1
#      subcategory: "slides"
#      collection: "Feedback"
#    Meteor.call "vote", data

#######

@VoteSchema= new SimpleSchema
  userId:
    type: String
  objectId:
    type: String
    min: 1
    # This could be a course, a video, an environment, a comment, or a feedback.
  degree:
    type: Number
    # This is how much you like an object.
  subcategory:
    type: String
    optional: true
    # for a video object, want slides, want environments
  collection:
    type: String
    # This specify which collection the object belongs to
  createdAt:
    type: Date
    defaultValue: new Date

@votes_policy_type=
  only_like: (d)-> d in [0,1]

@vote_policy =
  Feedback:
    degreeSpec: votes_policy_type.only_like
    subcategory: ["upvote"]
  learningResources:
    degreeSpec: votes_policy_type.only_like
    subcategory: ["slide","video","environment"]

@is_valid_vote = (degree, subcategory, collection)->

  if collection in Object.keys vote_policy

    policy =  vote_policy[collection]


    policy.degreeSpec(degree) and
    ((policy.subcategory is undefined and subcategory is undefined) or
    (policy.subcategory isnt undefined and subcategory in policy.subcategory))

  else
    throw new Meteor.Error(401, "Please define vote_policy for the collection")

Meteor.methods
  "vote": (data) ->
    loggedInUserId = Meteor.userId()

    if loggedInUserId

      data.userId = loggedInUserId
      data.createdAt = new Date()


      check data, VoteSchema

      @unblock()

      if is_valid_vote data.degree, data.subcategory, data.collection

        if data.subcategory
          historicVote =
            db.Votes.findOne
              userId:loggedInUserId
              objectId:data.objectId
              subcategory: data.subcategory
        else
          historicVote =
            db.Votes.findOne
              userId:loggedInUserId
              objectId:data.objectId


        # correct:   console.log historicVote?.degree isnt data.degree
        # incorrect: console.log historicVote?.degree is not data.degree

        if (not historicVote) or (historicVote?.degree isnt data.degree)

          targetObject = db[data.collection].findOne data.objectId


          if targetObject
            if data.subcategory
              accumulatedVote = targetObject?.vote?[data.subcategory] ? 0
            else
              accumulatedVote = targetObject?.vote ? 0
            oldDegree = historicVote?.degree ? 0

            updateObject = {}
            updateObject[ "vote." + data.subcategory] = accumulatedVote + data.degree - oldDegree

#            console.log "userId: " + loggedInUserId
#            console.log "accumulatedVote: " + accumulatedVote
#            console.log "oldDegree: " + oldDegree
#            console.log "data.degree: " + data.degree
#            console.log "should: " + data.degree - oldDegree

            if historicVote
              db.Votes.update {_id: historicVote?._id}, data
            else
              db.Votes.insert data

            db[data.collection].update {_id:data.objectId}, {$set: updateObject}


          else
            throw new Meteor.Error(401, "ExceptionInvalidVote")
        else
          throw new Meteor.Error(402, "ExceptionInvalidVote")
      else
        throw new Meteor.Error(403, "ExceptionInvalidVote")
    else
      throw new Meteor.Error(401, "You need to login")