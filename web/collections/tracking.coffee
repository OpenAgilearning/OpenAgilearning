@UserBehaviorTracking = new Meteor.Collection "userBehaviorTracking"

Meteor.methods
  "track":(url, target, description) ->
    # Example:
    # Meteor.call "track" ,window.location.pathname, "#slides", "mouseenter #slides"
    
    userId = Meteor.userId() ? "Anonymous"
    UserBehaviorTracking.insert
      userId:userId
      url: url
      target: target # assign target, so it is easier for DataSci to group by
      des: description
      time: new Date()