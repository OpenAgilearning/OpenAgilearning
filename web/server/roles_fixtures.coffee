adminMeetupIds = Meteor.settings.public.adminMeetupIds

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
