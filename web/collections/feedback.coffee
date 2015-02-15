@Feedback = new Meteor.Collection "feedback"

@db.Feedback = @Feedback

@FeedbackSchema= new SimpleSchema
  type:
    type: String
    max:1
    defaultValue: "w"
    autoform:
      type: "select-radio-inline-custom"
#      options: ->
#        [
#          {label: "make a wish", value: "w"}
#          {label: "report a bug", value:  "b"}
#        ]
  title:
    type: String
    label: "Which is ..."
    max: 100
    autoform:
      placeholder:"I wish the plateform serves cakes!"
  description:
    type: String
    label: "Tell me more"
    max: 200
    optional: true
    autoform:
      rows: 3
  createdAt:
    type: Date
    defaultValue: new Date
    autoform:
      type: "hidden"
      label:false
  createdBy:
    type: String
    defaultValue: "not logged in"
    autoform:
      type: "hidden"
      label:false
      
      
Meteor.methods
  "sendFeedback": (data) ->
    loggedInUserId = Meteor.userId()
    
    data.createdBy = loggedInUserId ? "not logged in"
    data.createdAt = new Date()
      
    check data, FeedbackSchema
    
    @unblock()
    Feedback.insert data
    