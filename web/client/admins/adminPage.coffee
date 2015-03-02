
Template.pullImageForm.helpers
  allowImageTags: ->
    values = _.uniq(db.dockerImageTagsMonitor.find().fetch().map((xx) -> xx["tag"]))
    res = {}
    values.map (xx) ->
      res[xx] = xx
    res
  allowServerNames: ->
    values = db.dockerServers.find().fetch().map (xx)-> xx._id
    res = {}
    values.map (xx) ->
      res[xx] = xx
    res
  DockerServerPullImageSchema:->
    res = new SimpleSchema
      serverName:
        type: String
        label: "serverName"

      repoTag:
        type: String
        label: "Tag"
