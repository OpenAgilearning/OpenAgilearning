Template.resume.helpers
  field: (key)->
    resumeUserId = Router.current().params.userId
    pair = db.publicResume.findOne {key:key, userId:resumeUserId}
    if pair?.isPublic
      pair.value

Template.resume_profile.helpers
  field: (key)->
    resumeUserId = Router.current().params.userId
    pair = db.publicResume.findOne {key:key, userId:resumeUserId}
    if pair?.isPublic
      pair.value

Template.resume_setting.helpers

  doc:->
    keyValuePairs = db.publicResume.find userId:Meteor.userId()

    doc = {}
    _.each keyValuePairs.fetch(), (pair)-> doc[pair.key] = pair.value

    doc


Template.privacy_setting.helpers

  privacyDoc:->
    keyValuePairs = db.publicResume.find userId:Meteor.userId()

    doc =
      publicFields:[]

    _.each keyValuePairs.fetch(), (pair)->
      doc.publicFields.push(pair.key) if pair.isPublic

    doc
