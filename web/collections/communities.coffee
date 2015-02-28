new Meteor.Collection "communities"

new Meteor.Collection "communityIds"

@communitySchema = new SimpleSchema
  name:
    type: String
    min: 3
    max: 30

  # TODO: implement later
  # pic_url:
  #   type: String

  description:
    type: String
    max: 200
    autoform:
      afFieldInput:
        type: "textarea"

Meteor.methods
  "createCommunity":(data)->

    loggedInUserId = Meteor.userId()

    if loggedInUserId

      # TODO: check if the user is able to create community.
      # Example:
      if db.communities.find(
        key:"createdBy"
        value: loggedInUserId
        ).count() <= 3

        check data, communitySchema

        @unblock()

        data.createdBy = loggedInUserId
        data.createdAt = new Date()

        db.communityIds.insert {}, (error, id)->

          if id
            _.map data, (val, key)->
              db.communities.insert
                communityId: id
                key: key
                value: val
                isPublic : true
          else
            throw new Error 5566, 'Error 5566: Cannot create community', error
      else
        throw new Error  5566, "Maximum personal community quota reached"


