

Template.resourcesList.rendered = ->
  $(".resourcesList").masonry
    columnWidth: ".col-md-3"
    itemSelector: '.resourceNode'

  Session.set "resourcesListRendered", true

Template.learningResourcesPage.rendered = ->
  $("iframe#ytplayer").hide()


Template.resourceNode.events
  "click img.play": (e,t) ->

    e.stopPropagation()
    $(e.target).closest(".resourceNode").removeClass "col-md-3"
    $(e.target).closest(".resourceNode").addClass "col-md-6"

    $("iframe#ytplayer").show()

    imgw = $(e.target).css("width")
    imgh = $(e.target).css("height")

    youtubeVideoId = $(e.target).attr "youtubeVideoId"
    playUrl = "http://www.youtube.com/embed/" + youtubeVideoId #+"?autoplay=1"

    $("iframe#ytplayer").attr "src", playUrl
    $("iframe#ytplayer").attr "width", imgw
    $("iframe#ytplayer").attr "height", imgh
    $("iframe#ytplayer").prependTo($(e.target).closest(".triggerBlock"))
    $("iframe#ytplayer").css("margin-bottom", "-"+imgh)
    $("iframe#ytplayer").css("position", "relative")
    # $("iframe#ytplayer").css("z-index", 100)
    # $(e.target).hide()
    # $(e.target).css("display","none")
    $(".resourcesList").masonry()
    # $("video").attr "data-setup", '{ "techOrder": ["youtube"], "src": "http://www.youtube.com/embed/' + youtubeVideoId + '" }'
    # $("video").map ->
    #   videojs @, JSON.parse($(@).attr("data-setup"))


Template.resourceNode.rendered = ->
  elem = @find ".resourceNode"

  $conotianer = $(".resourcesList")
  $conotianer.imagesLoaded ->
    $conotianer.masonry()

  if Session.get "resourcesListRendered"
    do (elem, $conotianer)->
      $conotianer.masonry "appended", elem


Template.resourceNode.destroyed = ->
  elem = @find ".resourceNode"
  $('.resourcesList').masonry( 'remove', elem )
  $('.resourcesList').masonry()