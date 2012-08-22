//
//  UIAlertView+NYiOS.m
//  NYiOS
//
//  Created by Dan Bretl on 8/22/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import "UIAlertView+NYiOS.h"

@implementation UIAlertView (NYiOS)

+ (UIAlertView *) changeUsernameAVWithDelegate:(id<UIAlertViewDelegate>)delegate {
    UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"Edit Username?" message:@"Would you like to edit your username?" delegate:delegate cancelButtonTitle:@"No" otherButtonTitles:@"Sure", nil];
    av.tag = ChangeUsernameAV;
    return av;
}

+ (UIAlertView *) connectionErrorAV {
    UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"There was a problem connecting with the server." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    av.tag = ConnectionErrorAV;
    return av;
}

+ (UIAlertView *) noMatchingAppsAVWithDelegate:(id<UIAlertViewDelegate>)delegate {
    UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"No Apps Found" message:@"There were no apps found matching your search. Would you like to create a new app, or else search again?" delegate:delegate cancelButtonTitle:@"Search" otherButtonTitles:@"New App", nil];
    av.tag = NoMatchingAppsAV;
    return av;
}

+ (UIAlertView *)cancelAddAppAVWithDelegate:(id<UIAlertViewDelegate>)delegate {
    UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"Close without Adding?" message:@"You're about to lose your progress. Are you sure you don't want to add this app?" delegate:delegate cancelButtonTitle:@"Continue" otherButtonTitles:@"Don't Add", nil];
    av.tag = CancelAddAppAV;
    return av;
}

@end
