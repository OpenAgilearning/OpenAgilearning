SettingSchema = {}

SettingSchema.profile = new SimpleSchema({
  email: {
    type: String,
    optional: true,
    autoform: {
      afFieldInput: {
        type: "email"
      }
    }
  }
})