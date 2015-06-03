Template.userBlock.helpers
  userInfo: (userId) ->
    name = db.publicResume.findOne({userId:userId, key:"name"})?.value
    org = db.publicResume.findOne({userId:userId,key:"organization"})?.value
    thumb = db.publicResume.findOne(userId: userId, key: "thumb_link")?.value
    thumb or= "http://photos4.meetupstatic.com/img/noPhoto_50.png"

    res=
      name:name
      org:org
      thumb_link:thumb

Template.userBlock.events
  'click .remove-member': (e,t) ->
    groupId = Router.current().params.groupId
    Meteor.call "bundleServer.removeMember",groupId , t.data.userId

Template.adminBlock.events
  'click .remove-admin-permission': (e,t) ->
    groupId = Router.current().params.groupId
    Meteor.call "bundleServer.removeAdminPermission",groupId , t.data.userId

Template.memberBlock.events
  'click .set-as-admin': (e,t) ->
    groupId = Router.current().params.groupId
    Meteor.call "bundleServer.setMemberAsAdmin",groupId , t.data.userId