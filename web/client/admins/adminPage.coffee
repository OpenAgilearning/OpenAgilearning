
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

Template.addNewDockerServer.helpers
  AddDockerServerSchema: ->
    res = new SimpleSchema
      serverName:
        type: String
        label: "serverName"
        min:3
        autoform:
          placeholder: "ds?-agilearning"

      host:
        type: String
        regEx: SimpleSchema.RegEx.IP
        autoform:
          placeholder: "000.000.000.000"

      # port:
      #   type: Number
      #   defaultValue: 2376

      useIn:
        type: String
        allowedValues: ["production","testing"]
        defaultValue:"production"
        autoform:
          options:"allowed"

      user:
        type: String
        allowedValues: ["toC","toB"]
        defaultValue:"toC"
        autoform:
          options:"allowed"

Template.removeDockerServer.helpers
  RemoveDockerServerSchema:->
    res = new SimpleSchema
      serverId:
        type: String
        label: "serverId"
        allowedValues: db.dockerServers.find().map (doc)->doc._id
        autoform:
          options:"allowed"

