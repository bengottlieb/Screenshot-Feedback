Screenshot Feedback
===================

Simple screenshot feedback mechanism for iOS


If enabled, will present the user with a request for feedback whenever a screen shot is taken. If they decide to submit feedback, an email form will be opened, and the shot attached.



To use:


- add the `AssetsLibrary.framework` and `MessageUI.framework` to your project

- in your app delegate, add `#import "SA_ScreenshotFeedback.h"`

- call +`[SA_ScreenshotFeedback enableWithDefaultEmailAddress: @"<feedback@your-company.com>"];`

 Once you've enabled it, no further configuration is required. Whenever a screenshot is taken in your app, the user will be prompted to send feedback.
 
 - optionally, call +`[SA_ScreenshotFeedback setDefaultSubject: @"default email subject"];`

- normally the proper window (and rootViewController) can be determined. If, however, you're seeing odd behavior (or no behavior at all) you may want to call +`[SA_ScreenshotFeedback setPresentingWindow: mainWindow];` to explicitly tell it where your main app window is.

 

It is recommended that this be used for Development only.


Enjoy!



Ben Gottlieb

Stand Alone, Inc.



