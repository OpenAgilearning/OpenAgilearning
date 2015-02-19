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

Template.envIframe.events
  "click .connectEnvBtn": (e, t)->
    e.stopPropagation()
    $("#envIframe").attr 'src', ""
    
    ip = $("#envIframe").attr "ip"
    port = $("#envIframe").attr "port"
    url = "http://"+ip+":"+port

    $("#envIframe").attr 'src', url

Template.classroomEnvIframe.helpers
  iframeIp: ->
    # console.log @
    @docker.ip

  iframePort: ->
    httpPortData = @docker?.portDataArray?.filter (portData)-> portData["type"] is "http"
    if httpPortData.length > 0
      httpPortData[0].hostPort
    
     
Template.classroomEnvIframe.rendered = ->
  
  $("#envIframe").attr 'src', ""
    
  ip = $("#envIframe").attr "ip"
  port = $("#envIframe").attr "port"
  url = "http://"+ip+":"+port

  $("#envIframe").attr 'src', url



Template.setEnvConfigsForm.helpers
  envConfigsSchema: ->
    userId = Meteor.userId()
    classroomDoc = Classrooms.findOne _id:@classroomId
    courseData = Courses.findOne _id:classroomDoc.courseId
    imageTag = courseData.dockerImage
    
    configTypeId = DockerImages.findOne({_id:imageTag}).type
    
    envConfigsData = EnvConfigTypes.findOne _id:configTypeId
    schemaSettings = {}

    if envConfigsData?.configs?.envs
      envConfigsData.configs.envs.map (env)->
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
