
new Mongo.Collection "migrationJobs"

@Migration =
  Job: class MigrationJob extends Class.Job
    collection: db.migrationJobs



migrationHandlers =
  TODO: (job)->
    console.log "[in migrationHandlers TODO]"

    finishedAtKey = ["finished", job.status, "At"].join "_"

    updateData =
      status: "FINISHED"

    updateData[finishedAtKey] = new Date

    job.collection.update {_id:job.id}, {$set:updateData}

  FINISHED: (job)->
    console.log "[in migrationHandlers FINISHED]"


testMigrationJob = new Migration.Job "testMigration", migrationHandlers
# testMigrationJob.remove

testMigrationJob = new Migration.Job "testMigration", migrationHandlers
testMigrationJob.handle

chatmessageHandler =
  TODO: (job)->
    console.log "[in chatmessageHandler TODO]"

    finishedAtKey = ["finished", job.status, "At"].join "_"


    classroom = db.classrooms.findOne courseId:"RBasic"

    if classroom
      chatroom = db.chatrooms.findOne classroomId:classroom._id

      if chatroom
        db.chatMessages.update(
          {chatroomId : "z3PMD6DR9z5MupNgs", classroomId:"ZguyxsWNwqEgGdfch"},
          {chatroomId : chatroom._id , classroomId: classroom._id}
        )
      else
        console.log "chatroom fail"
    else
      console.log "classroom fail"


    updateData =
      status: "FINISHED"

    updateData[finishedAtKey] = new Date

    job.collection.update {_id:job.id}, {$set:updateData}

  FINISHED: (job)->
    console.log "[in chatmessageHandler FINISHED]"