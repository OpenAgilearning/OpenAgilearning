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

      new SimpleSchema schemaSettings

Template.classroom.helpers
  users:Meteor.users.find()

Template.studentListTable.helpers
  settings: ->
    roles =
      key: "roles.classroom_" + @classroomId
      label:"Roles"
      fn: (value) ->value.join "/"
#        allRoles = []
#        if value
#            Object.keys(value[xx]).map (yy)->
#              allRoles.push value[xx][yy] + "." + xx
#
#        allRoles.join " / "

    res =
      collection: Meteor.users
      rowsPerPage: 30
      showFilter: true
      fields:[
        {key: "_id", label: "id", hidden: true},
        {key: "profile.photo.thumb_link", label: "Pic", tmpl: Template.studentPhoto},
        {key: "profile.name", label: "Name"},
        roles
      ]
