@Exceptions = new Mongo.Collection "exceptions"

@Collections.Exceptions = @Exceptions
@db.exceptions = @Collections.Exceptions
