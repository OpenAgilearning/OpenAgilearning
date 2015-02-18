Meteor.methods
  "track":(where, action) ->
    
    loggedInUserId = Meteor.userId()
    if loggedInUserId
      who =
        t:"l" # l stands for logged in
        id: loggedInUserId
    else
      who =
        t:"a" # a stands for anonymous
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
        u: who
        r: 
          n: where.name
          p: where.params
        d: new Date()
        a: 
          t: action.type
          tt:
            t: action.target.type
            id: action.target.id
        c: @connection.id