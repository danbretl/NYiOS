//
//  MembersTableViewController.h
//  NYiOS
//
//  Created by Dan Bretl on 8/21/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import <Parse/Parse.h>

@interface MembersTableViewController : PFQueryTableViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, UIAlertViewDelegate, PF_FBRequestDelegate>

@end
