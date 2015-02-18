
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
  # $container = $(".nodeList")
  # $container.imagesLoaded ->
  #   $container.masonry
  #     itemSelector: ".nodeInfo"
          
  $('.nodesList').masonry
    columnWidth: ".col-md-3"
    itemSelector: '.nodeInfo'

  $conotianer = $(".nodeList").masonry()

  $conotianer.imagesLoaded ->
    $conotianer.masonry()


Template.nodeIcons.rendered = -> 
  $conotianer = $(".nodeList").masonry()

  $conotianer.imagesLoaded ->
    $conotianer.masonry()

    # columnWidth: ".col-md-3"
    # itemSelector: '.nodeInfo'


Template.index.rendered = ->
  
  # $container = $(".nodeList")
  # $container.imagesLoaded ->
  #   $container.masonry
  #     itemSelector: ".nodeInfo"

  # $(".nodeList").masonry()
    # columnWidth: ".col-md-3"
    # itemSelector: '.nodeInfo'

  $conotianer = $(".nodeList").masonry()

  $conotianer.imagesLoaded ->
    $conotianer.masonry()


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
  
  $conotianer.masonry "appended", elem
 
  
  $conotianer.imagesLoaded ->
    $conotianer.masonry()


  # briefView = ->
  #   console.log "briefView"
  #   console.log @

  # detailView = ->
  #   console.log "detailView"
  #   console.log @

  # $(elem).toggle briefView, detailView


#   elem = this.find ".nodeInfo"
  
#   $('.nodesList').masonry 'appended', elem 

  # $('.nodesList').masonry 'reloadItems' 

  # $container = $(".nodeList")
  # $container.imagesLoaded ->
  #   $container.masonry
  #     itemSelector: ".nodeInfo"

  # $(".nodeList").masonry
  #   itemSelector: '.nodeInfo'

# Template.courseImage.rendered = ->
#   $('.nodesList').masonry('layout')
