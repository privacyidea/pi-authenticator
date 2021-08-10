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

:plus: This is what we currently do
:minus: This is not possible anymore because of api changes in the platform sdk(s)

It is unclear if/when google's engineering team will make it possible 

#### 2. Initialize default FirebaseApp from code

\+ Allows similar behaviour to current implementation
\- Does not work on Android if the app is terminated
\- Same behaviour as when using `google-services.json` does not seem possible
\- Unknown if it works on iOS

On iOS talking to the APNS directly could be an alternative. Support for background notifications must be ended.

#### 3. 'Hard code' FirebaseApp

