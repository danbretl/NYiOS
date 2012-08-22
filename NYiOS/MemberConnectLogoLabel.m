//
//  MemberConnectLogoLabel.m
//  NYiOS
//
//  Created by Dan Bretl on 8/22/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import "MemberConnectLogoLabel.h"

@implementation MemberConnectLogoLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.font = [UIFont boldSystemFontOfSize:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 48.0 : 24.0];
        self.textColor = [UIColor whiteColor];
        self.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        self.shadowOffset = CGSizeMake(0, 1.0);
    }
    return self;
}

@end
