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

@end
