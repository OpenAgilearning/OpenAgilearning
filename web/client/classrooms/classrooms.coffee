Template.classroom.rendered = ->
  $("video.video-js").map ->
    videojs @, JSON.parse($(@).attr("data-setup"))

Template.envIframe.events
  "click .connectEnvBtn": (e, t)->
    e.stopPropagation()
    $("#EnvIframe").attr 'src', ""
    
    ip = $("#envIframe").attr "ip"
    port = $("#envIframe").attr "port"
    url = "http://"+ip+":"+port

    $("#envIframe").attr 'src', url

Template.classroomEnvIframe.helpers
  iframeIp: ->
    console.log @
    @docker.ip

  iframePort: ->
    httpPortData = @docker.portDataArray.filter (portData)-> portData["type"] is "http"
    if httpPortData.length > 0
      httpPortData[0].hostPort
    
     


Template.setEnvConfigsForm.helpers
  envConfigsSchema: ->
    userId = Meteor.userId()
    classroomDoc = Classrooms.findOne _id:@classroomId
    courseData = Courses.findOne _id:classroomDoc.courseId
    imageTag = courseData.dockerImage
    
    configTypeId = DockerImages.findOne({_id:imageTag}).type
    
    envConfigsData = EnvConfigTypes.findOne _id:configTypeId
    schemaSettings = {}

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

    new SimpleSchema schemaSettings
