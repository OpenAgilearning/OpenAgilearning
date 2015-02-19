
@Collections = {}

@db = {}
@db.AllCollections = []

@OldCollection = Mongo.Collection
@NewCollection = class NewCollection extends @OldCollection
  constructor: (name,options)->
    super name, options
    if name not in db.AllCollections
      db.AllCollections.push name


@Mongo.Collection = @NewCollection
@Meteor.Collection = @NewCollection


