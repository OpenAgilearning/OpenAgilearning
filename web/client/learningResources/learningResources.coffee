

# Template.resourcesList.rendered = ->
#   $(".resourcesList").masonry
#     columnWidth: ".col-md-3"
#     itemSelector: '.resourceNode'

#   $conotianer = $(".resourcesList").masonry()

#   $conotianer.imagesLoaded ->
#     $conotianer.masonry()


Template.learningResourcesPage.rendered = ->
  # $container = $(".nodeList")
  # $container.imagesLoaded ->
  #   $container.masonry
  #     itemSelector: ".nodeInfo"
  $("iframe#ytplayer").hide()

  $(".resourcesList").masonry
    columnWidth: ".col-md-3"
    itemSelector: '.resourceNode'


  $conotianer = $(".resourcesList").masonry()

  $conotianer.imagesLoaded ->
    $conotianer.masonry()


Template.resourceNode.events
  "click img.play": (e,t) ->


    e.stopPropagation()
    $(e.target).closest(".resourceNode").toggleClass "col-md-3"
    $(e.target).closest(".resourceNode").toggleClass "col-md-6"

    $("iframe#ytplayer").show()

    imgw = $(e.target).css("width")
    imgh = $(e.target).css("height")

    console.log "here",imgw,imgh

    youtubeVideoId = $(e.target).attr "youtubeVideoId"
    playUrl = "http://www.youtube.com/embed/" + youtubeVideoId #+"?autoplay=1"

    console.log "here",playUrl

    $("iframe#ytplayer").attr "src", playUrl
    $("iframe#ytplayer").attr "width", imgw
    $("iframe#ytplayer").attr "height", imgh
    $("iframe#ytplayer").prependTo($(e.target).closest(".triggerBlock"))
    $("iframe#ytplayer").css("margin-bottom", "-"+imgh)
    # $("iframe#ytplayer").css("z-index", 100)
    # $(e.target).hide()
    # $(e.target).css("display","none")
    $(".resourcesList").masonry()
    # $("video").attr "data-setup", '{ "techOrder": ["youtube"], "src": "http://www.youtube.com/embed/' + youtubeVideoId + '" }'
    # $("video").map ->
    #   videojs @, JSON.parse($(@).attr("data-setup"))







Template.resourceNode.rendered = ->
  # elem = @find ".resourceNode"
  # triggerElem = $(elem).find(".triggerBlock")

  # $(triggerElem).click ->
  #   $(elem).toggleClass "col-md-3"
  #   $(elem).toggleClass "col-md-6"

  #   $(".resourcesList").masonry()


    # $iframe.attr("src", "http://www.youtube.com/embed/" + @youtubeVideoId)

    # if $('img[youtubeVideoId='+@youtubeVideoId+']').closest(".resourceNode").find("iframe").length is 0
    #   console.log "here"
    #   $node = $('img[youtubeVideoId='+@youtubeVideoId+']').closest(".resourceNode")
    #   $iframe = $("#ytplayer")
    #   $iframe.appendTo $node
    #   $iframe.attr("width", imgw)
    #   $iframe.attr("height", imgh)
      # $iframe.attr("frameborder", "0")
      # $iframe.css("margin-bottom", "-4px")
      # $iframe.attr("allowfullscreen", "")



  $conotianer = $(".resourcesList").masonry()

  # $conotianer.masonry "appended", elem

  $conotianer.imagesLoaded ->
    $conotianer.masonry()


