@Fixture.bundleServerUserGroup =

  data: ->
    [
      _id: "taishin"
      name: "Taishin Bank User Group"
      desc: "This is a bundle server group for Taishin Commercial Bank"
      members: Meteor.users.find("services.meetup.id": $in: Meteor.settings.adminMeetupIds).map (u) -> u._id
      servers: ["[DockerServer]ds4-agilearning-taishin-ln"]
      usageLimits: [
        name: "basic"
        NCPU: 1
        Memory: 512 * 1024 * 1024
      ]
    ]

  set: ->
    for group in @data()
      if db.bundleServerUserGroup.find(group._id).count() is 0
        db.bundleServerUserGroup.insert group

  clear: ->
    db.bundleServerUserGroup.remove group for group in @data()

  reset: ->
    @clear()
    @set()

Meteor.startup ->
  if ENV.isDev
    Fixture.bundleServerUserGroup.reset()
  else
    Fixture.bundleServerUserGroup.set()
