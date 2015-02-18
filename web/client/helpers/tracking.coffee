@Track = (target_id, target_type="css", action_type="click")->

  # action:
  #   type:"click"
  #   target:
  #     type: "css"
  #     id: "#video"
  params_raw = Router.current().params
  params_object = {}
  _.each Object.keys(params_raw), (k)-> 
    if params_raw[k] and not _.isEmpty params_raw[k]
      params_object[k] = params_raw[k]

  where =
    name: Router.current().route.getName()
    params: params_object
  action =
    type: action_type
    target:
      type: target_type
      id: target_id

  Meteor.call "track" , where, action

# Register all the tracking events here:


Template.nodeInfo.events
  "click .nodeInfo":(e,t) ->
    Track ".nodeInfo"

Template.classroom.events
  'click a[data-toggle^="tab"]':(e,t) ->
    target_id = $(e.target).attr "href"

    Track target_id