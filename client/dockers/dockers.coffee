Template.dockerSetConfig.events
  "click .submitENV": (e, t)->
    envData = {}

    $(".envVar").map ->
      envData[$(@).attr("var")]=$(@).val()

    console.log envData
    dockerType = Session.get "dockerType"
    Meteor.call "setENV", dockerType, envData, (err, data)->
      if not err
        console.log "data = "
        console.log data

        Router.go "dockers"

Template.dockerInstancesList.rendered = () ->
  $(".iframeBlock").hide()

Template.dockerInstancesList.events
  "click a.showInstance": (e, t)->
    e.stopPropagation()
    servicePort = $(e.target).attr "servicePort"
    $(".iframeBlock").show()
    iframeURL = "http://"+rootURL+":"+servicePort
    Session.set "iframeURL",iframeURL
    $("iframe#docker").attr "src", iframeURL
  
  "click a.hideInstance": (e, t)->
    e.stopPropagation()
    $(".iframeBlock").hide()

  "click a.reconnectInstance": (e, t)->
    servicePort = $(e.target).attr "servicePort"
    iframeURL = Session.get "iframeURL"
    $("iframe#docker").attr "src", iframeURL
  
  "click a.stopInstance": (e, t)->
    containerId = $(e.target).attr "containerId"
    Meteor.call "removeDocker", containerId, (err, res)->
      if not err
        console.log "res = "
        console.log res

Template.dockerImagesList.events
  "click a.runInstance": (e, t)->
    e.stopPropagation()
    imageId = $(e.target).attr "imageId"

    Meteor.call "runDocker", imageId, (err, res)->
      if not err
        console.log "res = "
        console.log res
  
      