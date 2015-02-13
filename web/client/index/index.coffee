
Template.nodesList.helpers
  nodes: ->
    Courses.find()

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
  # console.log "elem = "
  # console.log elem

  # $(".nodesList").masonry('appended', elem).fadeIn(2000)
    
  $(elem).click ->
    $(@).toggleClass "col-md-3"
    $(@).toggleClass "col-md-6"
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