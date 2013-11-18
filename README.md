Screenshot Feedback
===================

Simple screenshot feedback mechanism for iOS


If enabled, will present the user with a request for feedback whenever a screen shot is taken. If they decide to submit feedback, an email form will be opened, and the shot attached.



To use:

- add #import "SA_ScreenshotFeedback.h"
- call +[SA_ScreenshotFeedback enableWithDefaultEmailAddress: @"<feedback@your-company.com>"];
- optionally, call +[SA_ScreenshotFeedback setDefaultSubject: @"default email subject"];
- If you have a UIWindow *window property on your app delegate, no further action is required. Usually it will be able to find the presenting window, but if it doesn't appear for some reason, use +[SA_ScreenshotFeedback setPresentingWindow: mainWindow]

It is recommended that this be used for Development only.


Enjoy!

Ben Gottlieb
Stand Alone, Inc.



