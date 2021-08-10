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

Pro:
+ This is what we currently do 

Con:
+ This is not possible anymore because of api changes in the platform sdk(s)

It is unclear if/when google's engineering team will make it possible 

#### 2. Initialize default FirebaseApp from code

Pro:
+ Allows similar behaviour to current implementation

Con:
+ Requires custom changes made to the plugin(s)
+ Does not work on Android if the app is terminated
+ Same behaviour as when using `google-services.json` does not seem possible
+ Unknown if it works on iOS

On iOS talking to the APNS directly could be an alternative. Support for background notifications must be ended.

#### 3. 'Hard code' FirebaseApp

Pro:
- The 'recommended' way, i.e., the only thing information and support is actually available for
- Less work for implementation / does not require code changes
- SLA customers can supply own firebase configuration

Con:
- Needs mayor changes on app and server side
- Mayor change for customers / firebase is not in their hands anymore (and never was for iOS?)
- netknights is responsible for the firebase project
- More work when building app / app may be needed to be build multiple times

Because firebase only acts as the delivery service for challenges it should not be a big challenge to change which project is used.
The combination of serial and fbToken guarantees delivery to correct recipient.

