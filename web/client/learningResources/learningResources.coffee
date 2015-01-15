
# Template.resourcesList.rendered = ->
#   $('.resourcesList').masonry
#     columnWidth: 300
#     itemSelector: '.resourceNode'

# Template.resourceNode.rendered = ->
#   # elem = this.find ".resourceNode"
#   # $('.resourcesList').masonry 'appended', elem 

#   $('.resourcesList').masonry 'reloadItems' 
#   $('.resourcesList').masonry 'layout' 


Template.learningResourcesPage.helpers
  settings: ->
    youtubeVideoPlayerField =
      key: "youtubeVideoId"
      label: "Youtube Video"
      tmpl: Template.youtubeVideoPlayer
    

    res = 
      collection: LearningResources
      rowsPerPage: 10
      showFilter: true
      fields: [youtubeVideoPlayerField, "type", "title", "description"]

Template.learningResourcesPage.rendered = ->
  $("video").map -> 
    videojs @, JSON.parse($(@).attr("data-setup"))

# Template.youtubeVideoPlayer.rendered = ->
#   youtubeId = @data.youtubeVideoId
#   $el = $("#"+youtubeId)
#   videojs $el[0], JSON.parse($el.attr("data-setup"))
  