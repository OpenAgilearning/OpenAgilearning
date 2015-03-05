new Meteor.Collection "terms"

@AgreeToTerms= new SimpleSchema
  agree:
    type: Boolean
    label: "I agree to the Terms of Service above."
    custom:->
      if @value is false
        return "pleaseAgree"
  tocId:
    type: String

SimpleSchema.messages
  "pleaseAgree":"Please agree to the Terms of Service."

Meteor.methods
  "agreeToTerms":(data)->

    user = Meteor.user()


    check data, AgreeToTerms

    @unblock()

    agree= data.agree
    tocId= data.tocId

    if agree and tocId and db.terms.find( _id:tocId ).count()>0
      Meteor.users.update {_id:user._id}, {$addToSet:agreedTOC:tocId}

