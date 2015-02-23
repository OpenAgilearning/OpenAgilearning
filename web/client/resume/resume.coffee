Template.resume.helpers
  field: (key)->
    pair = db.publicResume.findOne key:key
    if pair?.isPublic
      pair.value


Template.resume_setting.helpers
  # field: (key)->
  #   pair = db.publicResume.findOne
  #     key:key
  #     userId:Meteor.userId()

  #   pair.value
  doc:->
    keyValuePairs = db.publicResume.find userId:Meteor.userId()
    #console.log keyValuePairs
    doc = {}
    _.each keyValuePairs.fetch(), (pair)-> doc[pair.key] = pair.value
    #console.log doc
    doc


Template.privacy_setting.helpers

  privacyDoc:->
    keyValuePairs = db.publicResume.find userId:Meteor.userId()

    doc =
      publicFields:[]

    _.each keyValuePairs.fetch(), (pair)->
      doc.publicFields.push(pair.key) if pair.isPublic

    doc

#   settings:->

#     keyField =
#       key: "key"
#       label: "Fields"

#     valueField =
#       key: "value"


#     isPublicField =
#       key: "isPublic"
#       label: "Seen by the public"

#     valueEditField =
#       key: "value"
#       label:"edit"
#       tmpl: Template.edit_value


#     res =
#       collection: db.publicResume
#       rowsPerPage: 5
#       fields: [
#         keyField
#         valueField
#         isPublicField
#         valueEditField
#       ]

# Template.edit_value.helpers
#   schema: new SimpleSchema
#     key:
#       type: String
#       max: 30
#     value:
#       type: String
#       max:30
#     isPublic:
#       type: Boolean