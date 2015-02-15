@db.Votes = new Mongo.Collection "votes"

#######
#Sample Usage:

#    data =
#      userId: Meteor.userId()
#      objectId: @_id
#      degree: 1
#      type: "upvote"
#      collection: "Feedback"
#    Meteor.call "vote", data

#    Note: The voted collection should be place under global variable @db
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
  type:
    type: String
    # Like, love, upvote, archive, add to favorite, rate, bookmark ...
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
    type: ["upvote"]
    
@is_valid_vote = (degree, type, collection)->
  #implement later
  (collection in Object.keys vote_policy) and
    vote_policy[collection].degreeSpec(degree) and
    type in vote_policy[collection].type
      
Meteor.methods
  "vote": (data) ->
    loggedInUserId = Meteor.userId()
    
    if loggedInUserId
      
      data.userId = loggedInUserId
      data.createdAt = new Date()

# These crash terribly
#      check data, VoteSchema
#    
#      @unblock()
      
      if is_valid_vote data.degree, data.type, data.collection
        
        
        historicVote =
          db.Votes.findOne
            userId:loggedInUserId
            objectId:data.objectId

        
        # correct:   console.log historicVote?.degree isnt data.degree
        # incorrect: console.log historicVote?.degree is not data.degree
  
        if (not historicVote) or (historicVote?.degree isnt data.degree)
        
          targetObject = db[data.collection].findOne data.objectId
          
          
          if targetObject
            accumulatedVote = targetObject?.vote?[data.type] ? 0
            oldDegree = historicVote?.degree ? 0
            
            updateObject = {}
            updateObject[ "vote." + data.type] = accumulatedVote + data.degree - oldDegree
            
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
          throw new Meteor.Error(401, "ExceptionInvalidVote")
      else
        throw new Meteor.Error(401, "ExceptionInvalidVote")
    else
      throw new Meteor.Error(401, "You need to login")