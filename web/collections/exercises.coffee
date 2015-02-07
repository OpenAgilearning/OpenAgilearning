@Exercises = new Mongo.Collection "exercises"

@ExercisesSchema = new SimpleSchema
  classroomId:
    type: String
  title:
    type: String
    label: "Title"
    max: 200
  creatAt:
    type: Date
  expectedTime:
    type: Number
    label: "Expected Finish Time"
  
    
#  completedStudents:
#    type: Array
#    optional: true
#    minCount: 0
#    maxCount: 5
#  'items.$':
#    type: Object
#    optional: true
#  'items.$.name': type: String
#  'items.$.quantity': type: Number