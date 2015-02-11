

Template.resourcesList.rendered = -> 
  $(".resourcesList").masonry
    columnWidth: ".col-md-3"
    itemSelector: '.resourceNode'


Template.learningResourcesPage.rendered = ->
  # $container = $(".nodeList")
  # $container.imagesLoaded ->
  #   $container.masonry
  #     itemSelector: ".nodeInfo"

  $(".resourcesList").masonry
    columnWidth: ".col-md-3"
    itemSelector: '.resourceNode'


Template.resourceNode.events
  "click img.play": (e,t) ->
    e.stopPropagation()
    youtubeVideoId = $(e.target).attr "youtubeVideoId"
    playUrl = "http://www.youtube.com/embed/" + youtubeVideoId #+"?autoplay=1"
    $("iframe#ytplayer").attr "src", playUrl
    
    # $("video").attr "data-setup", '{ "techOrder": ["youtube"], "src": "http://www.youtube.com/embed/' + youtubeVideoId + '" }'
    # $("video").map -> 
    #   videojs @, JSON.parse($(@).attr("data-setup"))


Template.resourceNode.rendered = ->
  # elem = @find ".resourceNode"
    
  # $(elem).click ->
  #   $(@).toggleClass "col-md-3"
  #   $(@).toggleClass "col-md-6"
  #   $(".resourceNode").masonry()

  # $conotianer = $(".resourcesList")
  
  # if $conotianer
  #   $conotianer.masonry "appended", elem
  # else
  #   $conotianer.masonry
  #     columnWidth: ".col-md-3"
  #     itemSelector: '.resourceNode'

  $(".resourcesList").masonry
    columnWidth: ".col-md-3"
    itemSelector: '.resourceNode'


Template.learningResourcesPage.rendered = ->
  # $("video").map -> 
  #   videojs @, JSON.parse($(@).attr("data-setup"))

  $(".resourcesList").masonry
    columnWidth: ".col-md-3"
    itemSelector: '.resourceNode'
