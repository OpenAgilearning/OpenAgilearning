
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


Template.course.events
  "click .connectBt": (e, t)->
    e.stopPropagation()
    $("#docker").attr 'src', ""

    docker = Session.get "docker"
    url = "http://"+rootURL+":"+docker.servicePort
    
    $("#docker").attr 'src', url


Template.analyzer.events
  "click .connectBt": (e, t)->
    e.stopPropagation()
    $("#docker").attr 'src', ""
    
    docker = Session.get "docker"
    url = "http://"+rootURL+":"+docker.servicePort
    
    $("#docker").attr 'src', url
