
Template.nodesList.helpers
  nodes: ->
    Courses.find()

Template.nodeInfo.helpers
  isPrivate: ->
    @publicStatus is "private"
  isPublic: ->
    @publicStatus is "public"
  isSemiPublic: ->
    @publicStatus is "semipublic"


Template.applyCourseBtn.helpers
  allowRoles: ->
    ["admin", "student", "teacher"]

  waitForCheck: ->
    Is.course(@courseId, "waitForCheck")


Template.applyCourseBtn.events
  "click button.applyCourseBtn": (e,t)->
    # console.log e
    e.stopPropagation()

    userId = Meteor.userId()
    if not userId
      Router.go "pleaseLogin"
    else
      courseId = $(e.target).attr "courseId"

      Meteor.call "applyCourse", courseId
      # , (err,data) ->
      #   if err.error is 401
      #     Router.go "pleaseLogin"


# Template.nodeIcons.helpers
#   isPrivate: ->
#     @publicStatus is "private"
#   isPublic: ->
#     @publicStatus is "public"
#   isSemiPublic: ->
#     @publicStatus is "semipublic"


Template.nodesList.rendered = ->

  $(".nodesList").masonry
    columnWidth: ".col-md-3"
    itemSelector: '.nodeInfo'

  Session.set "nodesListRendered", true


Template.nodeInfo.rendered = ->
  elem = @find ".nodeInfo"
  triggerElem = $(elem).find(".triggerBlock")
  # console.log "elem = "
  # console.log elem

  # $(".nodesList").masonry('appended', elem).fadeIn(2000)

  $(triggerElem).click ->
    $(elem).toggleClass "col-md-3"
    $(elem).toggleClass "col-md-6"
    $(".nodesList").masonry()


  $conotianer = $(".nodesList")
  $conotianer.imagesLoaded ->
    $conotianer.masonry()

  if Session.get "nodesListRendered"
    do (elem, $conotianer)->
      $conotianer.masonry "appended", elem


  # console.clear()


Template.nodeInfo.destroyed = ->
  elem = @find ".nodeInfo"
  $('.nodesList').masonry( 'remove', elem )
  $('.nodesList').masonry()


Template.advitedToJoin.helpers
  settings:->
    resSchema = new SimpleSchema
      code:
        type: String

Template.nodeIcons.helpers
  upvoted: (item)->
    db.Votes.findOne(
      objectId:@_id
      subcategory: item
      )?.degree is 1


vote = (id,item,upvote)->
  if upvote
    data =
      objectId: id
      degree: 1
      subcategory: item
      collection: "learningResources"
  else
    data =
      objectId: id
      degree: 0
      subcategory: item
      collection: "learningResources"
  Meteor.call "vote", data



Template.nodeIcons.events
  "click .upvoteSlides":(e,t)->
    e.stopPropagation()
    if Meteor.userId()
      vote @_id, "slide", true

  "click .deupvoteSlides":(e,t)->
    e.stopPropagation()
    if Meteor.userId()
      vote @_id, "slide", false

  "click .upvoteVideo":(e,t)->
    e.stopPropagation()
    if Meteor.userId()
      vote @_id, "video", true

  "click .deupvoteVideo":(e,t)->
    e.stopPropagation()
    if Meteor.userId()
      vote @_id, "video", false

  "click .upvoteDockerImage":(e,t)->
    e.stopPropagation()
    if Meteor.userId()
      vote @_id, "environment", true

  "click .deupvoteDockerImage":(e,t)->
    e.stopPropagation()
    if Meteor.userId()
      vote @_id, "environment", false


