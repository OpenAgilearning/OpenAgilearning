
Meteor.startup ->
  Exceptions.upsert {_id:"ExceptionPermissionDeny"},{_id:"ExceptionPermissionDeny"}
  Exceptions.upsert {_id:"ExceptionPublishEmpty"},{_id:"ExceptionPublishEmpty"}
