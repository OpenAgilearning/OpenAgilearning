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

  # classroomId = Router.current().params.classroomId
  # Meteor.call "getClassroomDocker", classroomId, (err, data)->
  #   if not err
  #     console.log "get env successfully!"
  #   else
  #     console.log "get env failed!"


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
Template.envIframe.rendered = ->

  _.map @$(".copy-button"), (dom)->
    button = $(dom)
    copybtn = new ZeroClipboard button
    copybtn.on 'ready', (readyEvent) ->
      button.attr("data-original-title", "Click to Copy")
      .tooltip()

      copybtn.on 'aftercopy', (event) ->
        button
        .attr("data-original-title", "Copied")
        .tooltip "show"
        .attr("data-original-title", "Click to Copy")

Template.sftpInfo.rendered = ->
  _.map @$(".copy-button"), (dom)->
    button = $(dom)
    copybtn = new ZeroClipboard button
    copybtn.on 'ready', (readyEvent) ->
      button.attr("data-original-title", "Click to Copy")
      .tooltip()

      copybtn.on 'aftercopy', (event) ->
        button
        .attr("data-original-title", "Copied")
        .tooltip "show"
        .attr("data-original-title", "Click to Copy")


Template.envIframe.events
  "click .connectEnvBtn": (e, t)->
    e.stopPropagation()
    t.$(".envIframe").attr 'src', ""

    ip = t.$(".envIframe").attr "ip"
    port = t.$(".envIframe").attr "port"
    url = "http://"+ip+":"+port

    t.$(".envIframe").attr 'src', url
  "click .env-fullscreen":(e,t)->
    elem = t.$(".envIframe")[0]

    req = elem.requestFullScreen || elem.webkitRequestFullScreen || elem.mozRequestFullScreen
    req.call elem

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
  hasVideo:-> db.videos.find().count() > 0
  hasSlide:-> db.slides.find().count() > 0
  hash:(string)->string.replace /[\[\]:\/]+/g, ""
  isPDF: -> @url.match /.+\.pdf$/


showExpiredAt = (expiredAt)->
  if expiredAt > 0
    (expiredAt - new Date().getTime()) / (60*1000) + " Minutes"
  else
    null



Template.codingEnvironment.helpers
  dockerInstance: -> DockerInstances.findOne imageTag:@tag
  dockerImageTag: -> db.dockerImageTags.findOne tag:@tag
  useThisEnvironment: ->
    Session.get("useThisEnvironment" + @tag) or (@tag is Router.current().data().course().dockerImageTag)

  personalQuotaSelectorSchema: ->
    res = new SimpleSchema
      quota:
        type: String
        label: "quota"
        allowedValues: db.dockerPersonalUsageQuota.find().map (doc)-> doc._id
        autoform:
          options: db.dockerPersonalUsageQuota.find().map (doc)-> {label:"#{doc.name} (CPU: #{doc.NCPU} / Memory: #{doc.Memory} / ExpireAt: #{showExpiredAt doc.expiredAt})", value:doc._id}
      NCPU:
        type: Number
        label: "Numbers of CPUs"
      Memory:
        type: Number
        label: "Memory space (MB)"
      tag:
        type: String
        defaultValue: @tag
        autoform:
          type: "hidden"
          label: false

  groupQuotaSelectorSchema: ->
    res = new SimpleSchema
      quota:
        type: String
        label: "quota"
        allowedValues: db.bundleServerUserGroup.find().map (doc)-> doc._id
        autoform:
          options: db.bundleServerUserGroup.find().map (doc) -> {label:doc.name, value:doc._id}

      usageLimit:
        type: String
        label: "Usage Limit"
        autoform:
          type:"select"

      tag:
        type: String
        autoform:
          type: "hidden"
          label: false


  maximumNCPU: ->
    db.dockerPersonalUsageQuota.findOne(Session.get "personalQuotaSelection").NCPU

  maximumMemory: ->
    db.dockerPersonalUsageQuota.findOne(Session.get "personalQuotaSelection").Memory / 1024 / 1024

  personalQuotaSelectionSelected: ->
    Session.get "personalQuotaSelection"

  usageLimitsOptions: ->
    db.bundleServerUserGroup.findOne(Session.get "groupQuotaSelection")?.usageLimits.map (u)->
      {label:"[#{u.name}] NCPU:#{u.NCPU} Memory:#{u.Memory}" ,value:u.name}

  groupQuotaSelectionSelected:->
    Session.get "groupQuotaSelection"

  hasPersonalQuota: ->
    db.dockerPersonalUsageQuota.find().count() > 0

  hasServerGroupQuota: ->
    db.bundleServerUserGroup.find(members: Meteor.userId()).count() > 0

  currentlyNoQuota: ->
    not (
      db.dockerPersonalUsageQuota.find().count() +
      db.bundleServerUserGroup.find(members: Meteor.userId()).count()
    )

Template.codingEnvironment.events
  "click #submitInvitationCode": (e,t) ->
    invitationCode = $("#invitationCodeInput").val()
    Router.go "invitation", {invitationId:invitationCode}


  "click .wantToCode": (e) ->
    e.stopPropagation()

    classroomId = Router.current().params.classroomId
    Meteor.call "getClassroomDocker", classroomId, @tag, (err, data)->
      if not err
        console.log "get env successfully!"
      else
        console.log "get env failed!"

    Session.set ("useThisEnvironment" + @tag), yes

  "change #personalQuotaSelector [name=quota]": (event, template) ->
    Session.set "personalQuotaSelection", event.target.value

  "change #groupQuotaSelector [name=quota]": (event, template) ->
    Session.set "groupQuotaSelection", event.target.value

  "click #get-free-trial": (event, template) ->
    Meteor.call "getFreeTrialQuota"#, (error) ->
      #if not error
      #  window.temp1 = template.firstNode.parentElement
      #  Blaze.render Template.spinner, template.firstNode.parentElement
      #  template.$(".spinner-container").css("background-color", "#EEEEEE")
      #  Meteor.call "selectPersonalQuota",
      #    tag: template.data.tag
      #    quota: db.dockerPersonalUsageQuota.findOne()._id
      #    NCPU: 1
      #    Memory: 512
      #  , ->
      #    $(template.firstNode.parentElement).children(".spinner-container").hide()
      #    $(template.firstNode.parentElement).children()



Template.codingEnvironment.rendered = ->
  tag = @data.tag
  Session.set "personalQuotaSelection", null
  Session.set "groupQuotaSelection", null
  Session.set ("useThisEnvironment" + tag), no
  #$ "#NCPUslider"
  #  .Link("upper").to "#NCPUvalue", "html"
  #$ "MemorySlider"
  #  .Link("upper").to "#MemoryValue", "html"



Blaze.registerHelper "flashDisabled", -> ZeroClipboard.state().flash.disabled
