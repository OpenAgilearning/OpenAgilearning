
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
  waitForCheck: ->
    userId = Meteor.userId()
    if userId
      RoleTools.isRole "waitForCheck", "course", @_id


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
