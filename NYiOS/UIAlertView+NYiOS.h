//
//  UIAlertView+NYiOS.h
//  NYiOS
//
//  Created by Dan Bretl on 8/22/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ChangeUsernameAV = 1,
    NoMatchingAppsAV = 2,
    ConnectionErrorAV = 3,
    CancelAddAppAV = 4,
} NYiOSAlertView;

@interface UIAlertView (NYiOS)

+ (UIAlertView *) changeUsernameAVWithDelegate:(id<UIAlertViewDelegate>)delegate; // Not currently being used, because I'm getting lazy.

+ (UIAlertView *) connectionErrorAV;

+ (UIAlertView *) noMatchingAppsAVWithDelegate:(id<UIAlertViewDelegate>)delegate;

+ (UIAlertView *) cancelAddAppAVWithDelegate:(id<UIAlertViewDelegate>)delegate;

@end
