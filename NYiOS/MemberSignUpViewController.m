//
//  MemberSignUpViewController.m
//  NYiOS
//
//  Created by Dan Bretl on 8/22/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import "MemberSignUpViewController.h"
#import "MemberConnectLogoLabel.h"

@interface MemberSignUpViewController ()

@end

@implementation MemberSignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    MemberConnectLogoLabel * logoLabel = [[MemberConnectLogoLabel alloc] init];
    logoLabel.text = @"NYiOS";
    [logoLabel sizeToFit];
    self.signUpView.logo = logoLabel;
}

@end
