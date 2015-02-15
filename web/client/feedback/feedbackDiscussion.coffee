Template.feedbackDiscussion.helpers
  settings: ->
    idField =
      key: "_id"
      label: "id"
      hidden: true
    typeField =
      key: "type"
      label: "Type"
      tmpl: Template.feedbackType
      # TODO: type should be filterable
    titleField =
      key: "title"
      label: "Title"
    descriptionField =
      key: "description"
      label: "Description"
    createdAtField =
      key: "createdAt"
      label: "Created"
      fn: (value) -> moment(value).fromNow()
      sort: 'ascending'
    voteField =
      key:"vote.upvote"
      label:"Like"
      tmpl: Template.feedbackVote
      
    res =
      collection: Feedback.find()
      rowsPerPage: 30
      showFilter: true
      fields:[
        idField
        typeField
        titleField
        descriptionField
        createdAtField
        voteField
      ]

Template.feedbackType.helpers
  isWish:(type)-> type is "w"
  
Template.feedbackVote.helpers
  upvoted:->
    db.Votes.findOne(objectId:@_id)?.degree is 1

Template.feedbackVote.events
  "click .upvote":(e,t)->
    #console.log "upvoting!!" + @_id + @title
    e.stopPropagation()
    data =
      objectId: @_id
      degree: 1
      type: "upvote"
      collection: "Feedback"
    Meteor.call "vote", data
  "click .deupvote":(e,t)->
    e.stopPropagation()
    console.log "deupvote"
    data =
      objectId: @_id
      degree: 0
      type: "upvote"
      collection: "Feedback"
    Meteor.call "vote", data
    