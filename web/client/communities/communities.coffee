Template.communitiesList.helpers
  # communities:->
  #   db.communities.find()

  ids: ->
    _.uniq(
      db.communities
      .find()
      .map (x)->x.communityId
      )

  field: (key, communityId)->
    pair = db.communities.findOne {key:key, communityId:communityId}
    if pair?.isPublic
      pair.value

Template.communityPage.helpers
  field: (key)->
    pair = db.communities.findOne {key:key}
    if pair?.isPublic
      pair.value