//
//  MemberLogInViewController.m
//  NYiOS
//
//  Created by Dan Bretl on 8/22/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import "MemberLogInViewController.h"
#import "MemberConnectLogoLabel.h"

@interface MemberLogInViewController ()

@end

@implementation MemberLogInViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    MemberConnectLogoLabel * logoLabel = [[MemberConnectLogoLabel alloc] init];
    logoLabel.text = @"NYiOS";
    [logoLabel sizeToFit];
    self.logInView.logo = logoLabel;
}

@end
