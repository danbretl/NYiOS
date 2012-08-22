//
//  AddAppViewController.h
//  NYiOS
//
//  Created by Dan Bretl on 8/22/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@protocol AddAppDelegate;

@interface AddAppViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>

@property (nonatomic, strong) PFUser * member;

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;

@property (weak, nonatomic) IBOutlet UIView *mainContainer;

@property (strong, nonatomic) IBOutlet UITableView *appSearchResultsTableView;

@property (strong, nonatomic) IBOutlet UIScrollView *appDetailsScrollView;

@property (weak, nonatomic) IBOutlet UITextField *appStoreTextField;
@property (weak, nonatomic) IBOutlet UITextField *websiteTextField;
@property (weak, nonatomic) IBOutlet UITextView *tagLineTextView;

@property (weak, nonatomic) IBOutlet UIButton *relationDeveloperButton;
@property (weak, nonatomic) IBOutlet UIButton *relationFanButton;

@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@property (weak, nonatomic) id<AddAppDelegate> delegate;

@end

@protocol AddAppDelegate <NSObject>
- (void) addAppViewController:(AddAppViewController *)viewController didFinishWithAppListing:(PFObject *)appListing app:(PFObject *)app;
@end