let authServiceSideEffects = [
  AuthMiddleWare.requestSms,
  AuthMiddleWare.logIn
]

let eventsServiceSideEffects = [
  EventsSideEffects.eventsEffects
]

let settingsServiceSideEffects = [
  SettingsSideEffects.settingsSideEffects
]

