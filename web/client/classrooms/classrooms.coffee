Template.classroom.rendered = ->
  $("video.video-js").map ->
    videojs @, JSON.parse($(@).attr("data-setup"))

Template.classroom.events
  "click .connectEnvBtn": (e, t)->
    e.stopPropagation()
    $("#docker").attr 'src', ""
    
    rootURL = $("#docker").attr "rootURL"
    servicePort = $("#docker").attr "servicePort"
    url = "http://"+rootURL+":"+servicePort

    $("#docker").attr 'src', url
