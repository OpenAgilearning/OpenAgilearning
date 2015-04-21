new Meteor.Collection "publicResume"

@editablePrivacyFields = ["hometown", "email","description"]

@profileSchema = new SimpleSchema
  name:
    type: String
    min: 6
    max: 30

  hometown:
    type: String
    max: 30

  email:
    type: String
    regEx: SimpleSchema.RegEx.Email
    autoform:
      afFieldInput:
        type: "email"
        placeholder: "please edit email"

  organization:
    type: String
    label: "Organization"
    max:100
    optional:true


  description:
    type: String
    label: "About me"
    max:140
    optional:true
    autoform:
      afFieldInput:
        type: "textarea"
        placeholder: "I like learning more than I can say!"


@privacySchema = new SimpleSchema
  publicFields:
    type: [String]
    allowedValues: editablePrivacyFields
    optional:true
    autoform:
      type:"select-checkbox-inline"
      options: "allowed"



Meteor.methods
  "updateResume": (updateData)->
    user = Meteor.user()

    check updateData, profileSchema

    @unblock()

    # TODO: expensive update
    _.map updateData, (val, key)->
      db.publicResume.update {
        userId: user._id
        key: key
        type: "profile"
      }, {$set:
        value: val
        isPublic : true }, upsert: true

  "updatePrivacy": (updateData)->
    user = Meteor.user()

    check updateData, privacySchema

    @unblock()


    # TODO: expensive update
    if updateData.publicFields
      _.each editablePrivacyFields, (field)->
        db.publicResume.update {
          userId: user._id
          key: field
          type: "profile"
        }, {$set:
          isPublic : (field in updateData.publicFields) }, upsert: true
    else
      _.each editablePrivacyFields, (field)->
        db.publicResume.update {
          userId: user._id
          key: field
          type: "profile"
        }, {$set:
          isPublic : false }, upsert: true