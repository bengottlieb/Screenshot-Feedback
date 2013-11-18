//
//  SA_ScreenshotFeedback.h
//
//  Created by Ben Gottlieb on 11/18/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SA_ScreenshotFeedback : NSObject

+ (void) enableWithDefaultEmailAddress: (NSString *) emailAddress;
+ (void) setPresentingWindow: (UIWindow *) window;
+ (void) setDefaultSubject: (NSString *) subject;

@end
