//
//  SA_ScreenshotFeedback.m
//
//  Created by Ben Gottlieb on 11/18/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SA_ScreenshotFeedback.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MessageUI/MessageUI.h>

@interface SA_ScreenshotFeedback () <UIAlertViewDelegate, MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) UIAlertView *currentAlert;
@property (nonatomic, strong) NSDate *screenshotTakenAt;
@property (nonatomic, strong) NSString *defaultEmailAddress, *defaultSubject;
@property (nonatomic, readonly) UIViewController *presentingController;
@property (nonatomic, weak) UIWindow *presentingWindow;
@property (nonatomic) BOOL enabled;
@end

static SA_ScreenshotFeedback			*s_screenshotFeedback = nil;

@implementation SA_ScreenshotFeedback

//================================================================================================================
#pragma mark class methods

+ (SA_ScreenshotFeedback *) defaultManager {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		if (![MFMailComposeViewController canSendMail]) {
			NSLog(@"There is no mail account enabled on this device; Screen Shot Feedback disabled");
			return;
		}
		s_screenshotFeedback = [[self alloc] init];
	});
	return s_screenshotFeedback;
}

+ (void) enableWithDefaultEmailAddress: (NSString *) emailAddress {
	if (![self defaultManager].enabled) {
		s_screenshotFeedback.enabled = YES;
		[[NSNotificationCenter defaultCenter] addObserver: s_screenshotFeedback selector: @selector(screenshotTaken:) name: UIApplicationUserDidTakeScreenshotNotification object: nil];
	}
	s_screenshotFeedback.defaultEmailAddress = emailAddress;
}

+ (void) setDefaultSubject: (NSString *) subject {
	[self defaultManager].defaultSubject = subject;
}

+ (void) setPresentingWindow: (UIWindow *) window {
	[self defaultManager].presentingWindow = window;
}

//================================================================================================================
#pragma mark Properties
- (NSString *) defaultSubject {
	if (_defaultSubject) return _defaultSubject;
	
	NSDictionary			*info = [[NSBundle mainBundle] infoDictionary];
	NSString				*version = info[@"CFBundleVersion"];
	NSString				*name = info[@"CFBundleDisplayName"];
	
	return [NSString stringWithFormat: @"%@, v%@", name, version];
}


//================================================================================================================
#pragma mark Notifications
- (void) screenshotTaken: (NSNotification *) note {
	if (self.currentAlert) return;
	
	self.currentAlert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Screenshot Taken", nil)
												   message: NSLocalizedString(@"Would you like to submit this screenshot as feedback?", nil)
												  delegate: self
										 cancelButtonTitle: NSLocalizedString(@"No, Thanks", nil)
										 otherButtonTitles: NSLocalizedString(@"Yes", nil), nil];
	
	self.screenshotTakenAt = [NSDate date];
	[self.currentAlert show];
}

- (void) alertView: (UIAlertView *) alertView clickedButtonAtIndex: (NSInteger) buttonIndex {
	self.currentAlert = nil;
	
	if (buttonIndex == alertView.cancelButtonIndex) return;
	
	ALAssetsLibrary		*library = [[ALAssetsLibrary alloc] init];
	
	[library enumerateGroupsWithTypes: ALAssetsGroupSavedPhotos usingBlock: ^(ALAssetsGroup *group, BOOL *stop) {
		*stop = [self groupContainsScreenshot: group];
	} failureBlock: ^(NSError *error) {
		
	}];

}

//================================================================================================================
#pragma mark Media Library Interface

- (BOOL) groupContainsScreenshot: (ALAssetsGroup *) group {
	ALAssetsFilter					*filter = [ALAssetsFilter allPhotos];
	CGSize							screenSize = [[UIScreen mainScreen] bounds].size;
	__block ALAssetRepresentation	*shotRep = nil;
	
	screenSize = CGSizeScale(screenSize, [UIScreen mainScreen].scale, [UIScreen mainScreen].scale);

	[group setAssetsFilter: filter];
	[group enumerateAssetsUsingBlock: ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
		NSString			*type = [asset valueForProperty: ALAssetPropertyType];
		NSTimeInterval		threshold = 1.0;
		
		if (![type isEqual: ALAssetTypePhoto]) return;											//wrong type
		
		NSDate				*date = [asset valueForProperty: ALAssetPropertyDate];
		
		if ([self.screenshotTakenAt timeIntervalSinceDate: date] > threshold) return;			//too old
		
		ALAssetRepresentation			*rep = [asset defaultRepresentation];
		CGSize							dims = [rep dimensions];
		BOOL							rightSize = CGSizeEqualToSize(dims, screenSize);
		
		if (!rightSize) rightSize = CGSizeEqualToSize(CGSizeMake(dims.height, dims.width), screenSize);
		if (!rightSize) return;
		shotRep = rep;
		*stop = YES;
	}];
	
	if (shotRep) {
		CGImageRef					imageRef = [shotRep fullResolutionImage];
		UIImage						*image = [UIImage imageWithCGImage: imageRef];
		NSData						*data = UIImagePNGRepresentation(image);
		
		MFMailComposeViewController	*controller = [[MFMailComposeViewController alloc] init];
		
		[controller setSubject: self.defaultSubject];
		if (self.defaultEmailAddress.length) [controller setToRecipients: @[ self.defaultEmailAddress ]];
		[controller addAttachmentData: data mimeType: @"image/png" fileName: [NSString stringWithFormat: @"screenshot %@.png", self.screenshotTakenAt]];
		controller.mailComposeDelegate = self;
		
		[self.presentingController presentViewController: controller animated: YES completion: nil];
		
		return YES;
	}
	return NO;
}

- (UIViewController *) presentingController {
	UIApplication	*app = [UIApplication sharedApplication];
	id				appDelegate = [app delegate];
	UIWindow		*mainWindow = self.presentingWindow;
	
	if (mainWindow == nil && [appDelegate respondsToSelector: @selector(window)]) mainWindow = [appDelegate window];
	
	if (mainWindow == nil && app.windows.count) {
		for (UIWindow *window in app.windows) {
			if (window.rootViewController) {
				mainWindow = window;
				break;
			}
		}
	}
	
	return mainWindow.rootViewController;
}

//================================================================================================================
#pragma mark Mail Compose Delegate
- (void) mailComposeController: (MFMailComposeViewController *) controller didFinishWithResult: (MFMailComposeResult) result error: (NSError *) error {
	[controller dismissViewControllerAnimated: YES completion: nil];
}


@end
