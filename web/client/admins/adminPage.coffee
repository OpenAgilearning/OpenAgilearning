
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

Template.systemAdminInvitation.helpers
  settings: ->
    timeRepr = (value)->
      m = moment value
      "#{m.toDate()} [#{m.fromNow()}]"

    creator =
      key: "creator"
      label: "creator"
      fn:(value)-> Meteor.users.findOne(_id:value)?.profile?.name

    createdAt =
      key: "createdAt"
      label: "createdAt"
      sort:-1
      fn:(value)->timeRepr(value)
    expireAt =
      key: "expireAt"
      label: "expireAt"
      fn:(value)->timeRepr(value)

    quotaLife =
      key:"quotaLife"
      label: "quotaLife"
      fn:(value)->
        d = moment.duration value
        "#{d.asHours()} Hours [#{d.humanize()}]"
    url =
      key:"_id"
      labl:"url"
      fn:(value)->
        Router.url "invitation",{invitationId:value}

    res =
      collection: db.invitation.find(purpose: "personalQuota")
      rowsPerPage: 10
      showFilter: true
      fields: [creator,createdAt,expireAt,"expired","acceptedUserIds","quotaType",quotaLife,url]

Template.systemAdminInvitation.events
  'click #gen-free-quota': (e,t) ->

    quotaLife = parseInt $("#free-quota-life").prop("value"), 0
    if quotaLife >0
      Meteor.call "generatePersonalQuotaInvitationUrl", "freeTrialQuota", quotaLife*60*60*1000
    else
      console.log "invalid quotaLife"

  'click #gen-a-lot-of-quota':(e,t)->
    quotaLife = parseInt $("#a-lot-of-quota-life").prop("value"), 0
    if quotaLife >0
      Meteor.call "generatePersonalQuotaInvitationUrl", "aLotOfQuota", quotaLife*60*60*1000
    else
      console.log "invalid quotaLife"