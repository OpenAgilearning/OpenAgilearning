new Meteor.Collection "terms"

@AgreeToTerms= new SimpleSchema
  agree:
    type: Boolean
    label: "I agree to the terms of conditions above."
  tocId:
    type: String


Meteor.methods
  "agreeToTerms":(data)->

    user = Meteor.user()


    check data, AgreeToTerms

    @unblock()

    agree= data.agree
    tocId= data.tocId

    if agree and tocId and db.terms.find( _id:tocId ).count()>0
      Meteor.users.update {_id:user._id}, {$addToSet:agreedTOC:tocId}

