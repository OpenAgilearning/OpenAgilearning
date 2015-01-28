
Template.courseClassroomsTable.helpers
  settings: ->
    goToClassroomBtnField =
      key: "_id"
      label: "Go To Classroom"
      tmpl: Template.goToClassroomBtn

    res =
      collection: Classrooms
      rowsPerPage: 5
      showFilter: true
      fields: [goToClassroomBtnField, "creatorId", "courseId", "publicStatus"]



Template.courses.helpers
  coursesSchema: -> coursesSchema


Template.courses.events
  "click input.createBt": (e,t) ->
    e.stopPropagation()
    data =
      courseName: $("input.courseName").val()
      dockerImage: $("input.dockerImage").val()
      slides: $("input.slides").val()
      description: $("input.description").val()

    Meteor.call "createCourse", data

  "click input.courseDeleteBtn":(e,t)->
    e.stopPropagation()
    courseId = this._id
    console.log "delete course: " + courseId
    Meteor.call "deleteCourse", courseId


Template.course.rendered = ->
  $("video").map ->
    videojs @, JSON.parse($(@).attr("data-setup"))

Template.classroom.rendered = ->
  $("video").map ->
    videojs @, JSON.parse($(@).attr("data-setup"))


Template.course.events
  "click .connectBt": (e, t)->
    e.stopPropagation()
    $("#docker").attr 'src', ""

    docker = Session.get "docker"
    url = "http://"+rootURL+":"+docker.servicePort

    $("#docker").attr 'src', url


Template.classroom.events
  "click .connectEnvBtn": (e, t)->
    e.stopPropagation()
    $("#docker").attr 'src', ""
    
    rootURL = $("#docker").attr "rootURL"
    servicePort = $("#docker").attr "servicePort"
    url = "http://"+rootURL+":"+servicePort

    $("#docker").attr 'src', url


Template.analyzer.events
  "click .connectBt": (e, t)->
    e.stopPropagation()
    $("#docker").attr 'src', ""

    docker = Session.get "docker"
    url = "http://"+rootURL+":"+docker.servicePort

    $("#docker").attr 'src', url
