
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
      sortByValue:yes
      fn:(value)->timeRepr(value)

    expireAt =
      key: "expireAt"
      label: "expireAt"
      sortByValue:yes
      fn:(value)->timeRepr(value)

    quota_name =
      key: "quota_name"
      label: "Name"
      fn:(value, object)-> value or object.quotaType

    quotaLife =
      key:"quota_life"
      label: "Life"
      sortByValue:yes
      fn:(value, object)->
        if value
          d = moment.duration value
          "#{d.asHours()} Hours [#{d.humanize()}]"
        else if object.quotaLife
          d = moment.duration object.quotaLife
          "#{d.asHours()} Hours [#{d.humanize()}]"


    quota_NCPU =
      key:"quota_NCPU"
      label: "NCPU"

    quota_memory =
      key: "quota_memory"
      label: "Mem"
      fn:(value)->
        value /(1024*1024*1024)

    url =
      key:"_id"
      label:"url"
      fn:(value)->
        Router.url "invitation",{invitationId:value}

    res =
      collection: db.invitation.find(purpose: "personalQuota")
      rowsPerPage: 10
      showFilter: true
      fields: [creator,createdAt,expireAt,"expired","acceptedUserIds",quota_name,quotaLife,quota_NCPU,quota_memory,url]

Template.systemAdminInvitation.events
  'click #gen-free-quota': (e,t) ->
    doc =
      quota_life: (parseInt $("#free-quota-life").prop("value"), 0)*60*60*1000
      quota_name: "Free Trial Quota"

    if doc.quota_life >0
      Meteor.call "generatePersonalQuotaInvitationUrl", doc
    else
      console.log "invalid quotaLife"

  'click #gen-custom-quota': (e,t) ->


    doc =
      quota_life: (parseInt $("#custom-quota-life").prop("value"), 0)*60*60*1000
      quota_name: $("#custom-quota-name").prop("value")
      quota_NCPU: parseInt $("#custom-quota-NCPU").prop("value"), 0
      quota_memory: (parseFloat $("#custom-quota-memory").prop("value"), 0) * 1024 * 1024 * 1024

    if doc.quota_life >0
      Meteor.call "generatePersonalQuotaInvitationUrl", doc
    else
      console.log "invalid quotaLife"