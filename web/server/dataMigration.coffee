
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

        job1 = db.dockerServers.remove {}
        job2 = db.dockerHubs.remove {}
        job3 = db.dockerImageTags.remove {}
        job4 = db.dockerServers.remove {}
        job41= db.courses.remove {creatorAt:{$lt:new Date("2015-04-16T00:00:00.000Z")}}
        job42= db.classrooms.remove {creatorAt:{$lt:new Date("2015-04-16T00:00:00.000Z")}}

        job5 = db.chatMessages.update(
          {chatroomId : "z3PMD6DR9z5MupNgs", classroomId:"ZguyxsWNwqEgGdfch"},
          {$set:{chatroomId : chatroom._id , classroomId: classroom._id}},
          {multi:true}
        )

        if job1 and job2 and job3 and job4 and job41 and job42 and job5
          updateData =
            status: "FINISHED"

          updateData[finishedAtKey] = new Date

          job.collection.update {_id:job.id}, {$set:updateData}
        else
          Meteor.Error 404, 'Migration fail'



      else
        console.log "chatroom fail"
    else
      console.log "classroom fail"



  FINISHED: (job)->
    console.log "[in chatmessageHandler FINISHED]"


job_migrate_chatmessage = new Migration.Job "migrate chatMessages", chatmessageHandler
job_migrate_chatmessage.handle