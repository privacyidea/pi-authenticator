# Updating flutter and firebase

### Why update flutter?

- stay up to date
- replace deprecated plugins
- implement new features (e.g., asking for device password)
- easier localization

### Problems with firebase cloud messaging (FCM)

The official plugin for FCM underwent a mayor rework together with the underlying platform sdk(s). This makes it necessary to adapt our app.

What are possible ways to use FCM now:

#### 1. Use a secondary FirebaseApp

[+]