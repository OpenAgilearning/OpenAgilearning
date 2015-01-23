Template.devMilestoneTable.helpers
  settings: ->
    res =
      collection: DevMileStone
      rowsPerPage: 3
      showFilter: false
      fields: [
        {key:"version", label:"Version", sortable: false},
        {key:"description", label:"Description", sortable: false}
        {key:"atCreate", label:"Created Time", sort: 'descending', hidden:true}
      ]
Template.wantedFeatureTabel.helpers
  settings: ->
    voteFeatureBtn =
      key:"vote"
      label:"Vote"
      tmpl: Template.voteFeatureBtn
      sortable:false
    res =
      collection: WantedFeature
      rowsPerPage: 3
      showFilter: false
      fields: [
        {key:"hot", label:"Hot", sort: 'descending'},
        {key:"description", label:"Description", sortable: false},
        {key:"creatorName", label:"Creator", sortable:false},
        voteFeatureBtn
      ]

Template.voteFeatureBtn.events
  "click input.upvoteFeatureBtn.btn.btn-success": (e,t)->
    e.stopPropagation()

    btnId = $(e.target).attr "id"
    user = Meteor.user()
    if not user
      throw new Meteor.Error(401, "You need to login !")

    # upvoter = WantedFeature.find({_id:btnId, upvoter:{$exists: true}}).fetch().map (obj) ->
    #   obj.upvoter
    feature = WantedFeature.findOne({_id:btnId, upvoter:{$exists: true}})
    if user._id in feature.upvoter
      console.log "already vote"
    else
      console.log "user._id ="
      console.log user._id
      console.log "upvoter ="
      console.log feature.upvoter
      feature.upvoter.push(user._id)
      feature.upvoterName.push(user.profile.name)
      feature.hot = feature.hot + 1
      res =
        upvoterName:feature.upvoterName
        upvoter:feature.upvoter
        hot:feature.hot
      Meteor.call "upvoteFeatureMethod", res, btnId

  "click input.cancelUpvoteFeatureBtn.btn.btn-warning": (e,t)->
    e.stopPropagation()

    btnId = $(e.target).attr "id"
    user = Meteor.user()
    if not user
      throw new Meteor.Error(401, "You need to login !")
    feature = WantedFeature.findOne({_id:btnId, upvoter:{$exists: true}})

    if user._id in feature.upvoter
      feature.upvoter.splice(feature.upvoter.indexOf(user._id), 1)
      feature.upvoterName.splice(feature.upvoterName.splice(user.profile.name), 1)
      if feature.hot > 0
        feature.hot = feature.hot - 1
      else
        feature.hot = 0
      res =
        upvoterName:feature.upvoterName
        upvoter:feature.upvoter
        hot:feature.hot
      Meteor.call "cancelUpvoteFeatureMethod", res, btnId
    else
      console.log "already vote"


# AutoForm.hooks
#   editWantedFeature:
#     onSuccess:->
#       console.log "autoform success"
#   editDevMilestone: