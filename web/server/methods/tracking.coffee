Meteor.methods
  "track":(where, action) ->
    
    loggedInUserId = Meteor.userId()
    if loggedInUserId
      who =
        type:"l" # l stands for logged in
        id: loggedInUserId
    else
      who =
        type:"a" # a stands for anonymous
        id: @connection.clientAddress ? ""


    # who:
    #   type: #"userid" or "cookie"
    #   id: #hash
    # where:
    #   name: # Router.current().route.getName()
    #   params: # Router.current().params
    # when: new Date()
    # action:
    #   type:"click"
    #   target:
    #     type: "css"
    #     id: "#video"
    # connection:

    if where?.name and where?.params and action?.type and
    action?.target?.type and action?.target?.id
    # TODO: write in check & match approach

      UserBehaviorTracking.insert
        who: who
        where:
          name: where.name
          params: where.params
        time: new Date()
        action:
          type: action.type
          target:
            type: action.target.type
            id: action.target.id
        connection: @connection.id