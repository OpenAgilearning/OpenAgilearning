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

    new SimpleSchema schemaSettings
