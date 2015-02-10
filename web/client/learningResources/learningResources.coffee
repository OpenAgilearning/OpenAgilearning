

Template.resourcesList.rendered = -> 
  $(".resourcesList").masonry
    columnWidth: ".col-md-3"
    itemSelector: '.nodeInfo'


Template.learningResourcesPage.rendered = ->
  # $container = $(".nodeList")
  # $container.imagesLoaded ->
  #   $container.masonry
  #     itemSelector: ".nodeInfo"

  $(".resourcesList").masonry
    columnWidth: ".col-md-3"
    itemSelector: '.nodeInfo'


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

  $(".resourcesList").masonry
    columnWidth: ".col-md-3"
    itemSelector: '.resourceNode'


# Template.resourcesList.rendered = ->
#   $('.resourcesList').masonry
#     columnWidth: 300
#     itemSelector: '.resourceNode'

# Template.resourceNode.rendered = ->
#   # elem = this.find ".resourceNode"
#   # $('.resourcesList').masonry 'appended', elem 

#   $('.resourcesList').masonry 'reloadItems' 
#   $('.resourcesList').masonry 'layout' 


# Template.learningResourcesPage.helpers
#   settings: ->
#     youtubeVideoPlayerField =
#       key: "youtubeVideoId"
#       label: "Youtube Video"
#       tmpl: Template.youtubeVideoPlayer
    

#     res = 
#       collection: LearningResources
#       rowsPerPage: 10
#       showFilter: true
#       fields: [youtubeVideoPlayerField, "type", "title", "description"]

Template.learningResourcesPage.rendered = ->
  $("video").map -> 
    videojs @, JSON.parse($(@).attr("data-setup"))

  $(".resourcesList").masonry
    columnWidth: ".col-md-3"
    itemSelector: '.resourceNode'

# Template.youtubeVideoPlayer.rendered = ->
#   youtubeId = @data.youtubeVideoId
#   $el = $("#"+youtubeId)
#   videojs $el[0], JSON.parse($el.attr("data-setup"))
  