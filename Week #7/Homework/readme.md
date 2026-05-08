Use observer:start() to have a look at the supervision tree. You can kill one of the supervisors and see what happens. Do the things you know about processes supervision apply to apps as well? For example:
- what happens if you kill the top level supervisor of an app (a few times)?
- (stop the app if it's running, with application:stop(<app-name>) then) start the app with application:start(<app-name>, transient).; what happens if you kill the app top level supervisor now?

