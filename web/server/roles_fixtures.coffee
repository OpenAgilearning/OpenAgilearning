@Fixture.SystemAdmins =
  set: ->

    adminMeetupIds = Meteor.settings.adminMeetupIds
    defaultAdminUidArray = Meteor.users.find({"services.meetup.id" : {$in:adminMeetupIds}}).fetch().map (xx)-> xx._id

    console.log "defaultAdminUidArray = ",defaultAdminUidArray

    systemAdminGroup = "agilearning.io"


    for role in ["admin"] # ,"cofounder","developer"]
      roleType =
        group: "agilearning.io"
        role: role

      if db.roles.find(roleType).count() is 0
        roleId = db.roles.insert roleType
      else
        roleId = db.roles.findOne(roleType)._id

      for uid in defaultAdminUidArray
        userIsRole =
          roleId: roleId
          userId: uid

        if db.userIsRole.find(userIsRole).count() is 0
          db.userIsRole.insert userIsRole




  clear: ->
    roleQuery =
      group: "agilearning.io"

    db.roles.remove roleQuery



  reset: ->
    @clear()
    @set()


if ENV.isDev
  Fixture.SystemAdmins.reset()

Fixture.SystemAdmins.set()



adminMeetupIds = Meteor.settings.adminMeetupIds
defaultAdminUidArray = Meteor.users.find({"services.meetup.id" : {$in:adminMeetupIds}}).fetch().map (xx)-> xx._id


roleGroupData =
  _id: "agilearning.io"
  type: "agilearning.io"

if db.roleGroups.find(roleGroupData).count() is 0
  roleGroupDataId = db.roleGroups.insert roleGroupData
else
  roleGroupDataId = db.roleGroups.findOne(roleGroupData)._id

for uid in defaultAdminUidArray
  for roleType in ["admin","cofounder","developer"]
    userRoleData =
      userId:uid
      role:roleType
      groupId:roleGroupDataId

    if db.roles.find(userRoleData).count() is 0
      db.roles.insert userRoleData
