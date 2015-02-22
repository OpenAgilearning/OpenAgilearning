new Meteor.Collection "publicResume"

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


Meteor.methods
  "updateResume": (updateData)->
    user = Meteor.user()

    check updateData, profileSchema

    @unblock()

    _.map updateData, (val, key)->
      db.publicResume.update(
        {
          userId:user._id
          key:key
          },
        {
          $set:
            value:val
            },
        {upsert:true})