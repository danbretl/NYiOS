//
//  AppDetailViewController.h
//  NYiOS
//
//  Created by Dan Bretl on 8/22/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface AppDetailViewController : UIViewController

- (void) setApp:(PFObject *)app by:(PFUser *)developer from:(PFUser *)navMember; // At a minimum, we need an app object. The rest of the parameters are optional. The logic of this VC is simpler if we require other classes to set these properties all at once.

@property (weak, nonatomic) IBOutlet PFImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *byLineButton;
- (IBAction)byLineButtonTouched:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *tagLineLabel;

@property (weak, nonatomic) IBOutlet UIButton *appStoreButton;
@property (weak, nonatomic) IBOutlet UIButton *appWebsiteButton;

- (IBAction)appButtonTouched:(UIButton *)sender;

- (IBAction)swipedBack;

@end
