Template.classroom.rendered = ->

  $("video.video-js").map ->
    videojs @, JSON.parse($(@).attr("data-setup"))

  showFeedBack = ->
    if Router.current().route.getName() is "classroom"
      $("#feedback").popover("show")

  if Meteor.settings.public.environment is "production"
    # sleep 10 min in production
    setTimeout showFeedBack , ( 10 * 60 * 1000 )
  else
    setTimeout showFeedBack , 3000

  classroomId = Router.current().params.classroomId
  Meteor.call "getClassroomDocker", classroomId, (err, data)->
    if not err
      console.log "get env successfully!"
    else
      console.log "get env failed!"

  # timer = setInterval((->
  #   xhr = new XMLHttpRequest()
  #   xhr.onload=->
  #     # console.log "pinging", @status # Always 200
  #     console.log "pinging", @.getResponseHeader "Server"
  #     # if @.getResponseHeader "Server"
  #     #   clearInterval timer
  #   xhr.onerror= (e)->
  #     console.log "error",e, @
  #     clearInterval timer

  #   xhr.open 'get', $("#envIframe").attr('src')
  #   xhr.send()
  #   return
  # ), 1000)


Template.envIframe.events
  "click .connectEnvBtn": (e, t)->
    e.stopPropagation()
    $("#envIframe").attr 'src', ""

    ip = $("#envIframe").attr "ip"
    port = $("#envIframe").attr "port"
    url = "http://"+ip+":"+port

    $("#envIframe").attr 'src', url

Template.classroomEnvIframe.helpers
  iframeUser:->
    @docker.envs.USER
  iframePassword:->
    @docker.envs.PASSWORD
  iframeIp: ->
    # console.log @
    @docker.ip

  iframePort: ->
    httpPortData = @docker?.portDataArray?.filter (portData)-> portData["type"] is "http"
    if httpPortData.length > 0
      httpPortData[0].hostPort


Template.classroomEnvIframe.rendered = ->

  # $("#beforeIframeLoadedSpinner").css("display", "none")
  # $("#envIframe").css("visibility", "visible")

  # $('#iframe').load (e) ->
  #   iframe = $("#envIframe")[0]
  #   if iframe.innerHTML()
  #     ifTitle = iframe.contentDocument.title
  #     if ifTitle.indexOf('http') >= 0
  #       iframe.src=iframe.src

  # $("#envIframe").on "onError",->
  #   console.log "error:adadasass"
  #   $("#envIframe").attr 'src', ""

  #   ip = $("#envIframe").attr "ip"
  #   port = $("#envIframe").attr "port"
  #   url = "http://"+ip+":"+port

  #   $("#envIframe").attr 'src', url

  # $("#envIframe").on "load",->
  #   console.log "load:s.dm.asm.,sm"

  wait = 3000

  setTimeout((->
    $("#beforeIframeLoadedSpinner").css("display", "none")
    $("#envIframe").attr 'src', ""

    ip = $("#envIframe").attr "ip"
    port = $("#envIframe").attr "port"
    url = "http://"+ip+":"+port

    $("#envIframe").attr 'src', url

  ),wait)

  setTimeout((->
    $("#envIframe").css("visibility", "visible")
  ),wait + 700)



Template.setEnvConfigsForm.helpers
  envConfigsSchema: ->
    userId = Meteor.userId()
    classroomDoc = Classrooms.findOne _id:@classroomId
    courseData = Courses.findOne _id:classroomDoc.courseId
    imageTag = courseData.dockerImageTag
    imageTagData = db.dockerImageTags.findOne({tag:imageTag})

    # configTypeId = DockerImages.findOne({_id:imageTag}).type

    envConfigsData = db.envConfigTypes.findOne name:imageTagData.envConfigTypeName
    # envConfigsData = EnvConfigTypes.findOne _id:configTypeId
    schemaSettings = {}

    if envConfigsData?.envs
      envConfigsData.envs.map (env)->
        schemaSettings[env.name] = {type: String}

        if not env.mustHave
          schemaSettings[env.name].optional = true

        if env.limitValues
          schemaSettings[env.name].allowedValues = env.limitValues

      schemaSettings.classroomId =
        type: String
        defaultValue: @classroomId
        autoform:
          type: "hidden"
          label: false

      new SimpleSchema schemaSettings

Template.classroom.helpers
  TermsSigned:-> _.contains Meteor.user().agreedTOC, "toc_main"