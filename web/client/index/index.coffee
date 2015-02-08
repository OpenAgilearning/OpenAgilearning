
Template.nodesList.helpers
  nodes: ->
    Courses.find()

Template.nodesList.rendered = ->
  container = $(".nodeList")
  container.imagesLoaded ->
    container.masonry
      itemSelector: ".nodeInfo"
          
  # $('.nodesList').masonry
  #   # columnWidth: ".col-md-3"
  #   itemSelector: '.nodeInfo'

Template.nodeInfo.rendered = ->
#   elem = this.find ".nodeInfo"
  
#   $('.nodesList').masonry 'appended', elem 

  # $('.nodesList').masonry 'reloadItems' 
  $('.nodesList').masonry()

# Template.courseImage.rendered = ->
#   $('.nodesList').masonry('layout')