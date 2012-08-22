//
//  MembersTableViewController.m
//  NYiOS
//
//  Created by Dan Bretl on 8/21/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import "MembersTableViewController.h"
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "IndentedToggleCell.h"
#import "AppsTableViewController.h"
#import "MemberLogInViewController.h"
#import "MemberSignUpViewController.h"
#import "UIColor+NYiOS.h"
#import "SBJson/SBJson.h"
#import "PushHelper.h"

@interface MembersTableViewController ()
- (void) pushAppsViewControllerForMember:(PFUser *)member;
@property (nonatomic, strong) UIButton * meButton;
@property (nonatomic, strong) UIButton * logOutButton;
@property (nonatomic, strong) NSArray * cornerButtons;
@property (nonatomic, strong) UIView * cornerButtonsContainer;
- (void) cornerButtonTouched:(UIButton *)button;
- (void) setCornerButton:(UIButton *)cornerButton visible:(BOOL)visible animated:(BOOL)animated;
@end

@implementation MembersTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        
        // The className to query on
        // self.className = @"User"; // We are not using this base property there is a special type of query you must use for Users, which we are setting up in [MembersTableViewController queryForTable...]
        
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = @"username";
        
        // Uncomment the following line to specify the key of a PFFile on the PFObject to display in the imageView of the default cell style
        // self.imageKey = @"image";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 25;
        
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat screenMaxDimension = MAX(screenSize.width, screenSize.height);
    CGFloat screenMinDimension = MIN(screenSize.width, screenSize.height);
    
    
    self.tableView.rowHeight = floorf(screenMaxDimension / 8.5);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone; // This doesn't seem to be having any effect.
    self.tableView.separatorColor = [UIColor clearColor]; // Fallback solution.
    
    self.meButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.meButton setTitle:@"me" forState:UIControlStateNormal];
    self.logOutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.logOutButton setTitle:@"log out" forState:UIControlStateNormal];
    self.cornerButtons = @[self.meButton, self.logOutButton];
    
    CGFloat cornerButtonSideLength = floorf(screenMinDimension / 6.0);
    CGFloat cornerButtonMargin = floorf(cornerButtonSideLength / 4.0);
    
    self.cornerButtonsContainer = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - cornerButtonMargin - cornerButtonSideLength, 0, cornerButtonSideLength, self.view.bounds.size.height)];
    self.cornerButtonsContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
    [self.view addSubview:self.cornerButtonsContainer];
    [self.view bringSubviewToFront:self.cornerButtonsContainer];
    
    for (UIButton * cornerButton in self.cornerButtons) {
        
        cornerButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        cornerButton.backgroundColor = [UIColor softGrayColor];
        [cornerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cornerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        cornerButton.titleLabel.font = [UIFont boldSystemFontOfSize:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 64.0 : 32.0];
        cornerButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        cornerButton.titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        cornerButton.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 3);
        [cornerButton addTarget:self action:@selector(cornerButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        
        cornerButton.frame = CGRectMake(0, self.cornerButtonsContainer.bounds.size.height - cornerButtonMargin - (cornerButtonSideLength + cornerButtonMargin) * [self.cornerButtons indexOfObject:cornerButton] - cornerButtonSideLength, cornerButtonSideLength, cornerButtonSideLength);
        cornerButton.layer.cornerRadius = floorf(cornerButtonSideLength / 4.0);
        
        [self.cornerButtonsContainer addSubview:cornerButton];
        
    }
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.meButton = nil;
    self.logOutButton = nil;
    self.cornerButtonsContainer = nil;
    self.cornerButtons = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setCornerButton:self.logOutButton visible:[PFUser currentUser] != nil animated:NO];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad || interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)cornerButtonTouched:(UIButton *)button {
    if (button == self.meButton) {
        if ([PFUser currentUser]) {
            [self pushAppsViewControllerForMember:[PFUser currentUser]];
        } else {
            MemberLogInViewController * logInViewController = [[MemberLogInViewController alloc] init];
            logInViewController.delegate = self;
            logInViewController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsPasswordForgotten | PFLogInFieldsLogInButton | PFLogInFieldsFacebook | PFLogInFieldsTwitter | PFLogInFieldsSignUpButton | PFLogInFieldsDismissButton;
            logInViewController.modalPresentationStyle = UIModalPresentationFormSheet;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                logInViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            }
            MemberSignUpViewController * signUpViewController = [[MemberSignUpViewController alloc] init];
            signUpViewController.delegate = self; // Need to investigate this more, but it seems like if the user signs up for an account via FB or Twitter, we don't get a PFSignUpViewControllerDelegate callback - we get a PFLogIn one instead. (If they sign up via username / email, we do get a PFSignUp callback, I think.)
            signUpViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            logInViewController.signUpController = signUpViewController;
            [self presentModalViewController:logInViewController animated:YES];
            
        }
    } else if (button == self.logOutButton) {
        if ([PFUser currentUser]) {
            [PFUser logOut];
            [self setCornerButton:self.logOutButton visible:NO animated:YES];
        }
    }
}

- (void) setCornerButton:(UIButton *)cornerButton visible:(BOOL)visible animated:(BOOL)animated {
    [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
        cornerButton.alpha = visible ? 1.0 : 0.0;
    }];
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self memberConnected:user];
}

- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self dismissModalViewControllerAnimated:YES];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) [self setCornerButton:self.logOutButton visible:[PFUser currentUser] != nil animated:YES];
    [PushHelper updatePushNotificationSubscriptionsForMember:[PFUser currentUser]]; // Possibly overkill
}

- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    UIAlertView * errorAlertView = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlertView show];
    [self dismissModalViewControllerAnimated:YES];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) [self setCornerButton:self.logOutButton visible:[PFUser currentUser] != nil animated:YES];
    [PushHelper updatePushNotificationSubscriptionsForMember:[PFUser currentUser]]; // Possibly overkill
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        signUpController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    }
    [self memberConnected:user];
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    UIAlertView * errorAlertView = [[UIAlertView alloc] initWithTitle:@"Sign Up Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlertView show];
    [self dismissModalViewControllerAnimated:YES];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) [self setCornerButton:self.logOutButton visible:[PFUser currentUser] != nil animated:YES];
    [PushHelper updatePushNotificationSubscriptionsForMember:[PFUser currentUser]]; // Possibly overkill
}

- (void) memberConnected:(PFUser *)member {
    
    BOOL deferDismissal = YES;
    if ([PFFacebookUtils isLinkedWithUser:member]) {
        // User signed up with Facebook
        NSLog(@"User is connected to Facebook");
        [[PFFacebookUtils facebook] requestWithGraphPath:@"me" andDelegate:self];
    } else if ([PFTwitterUtils isLinkedWithUser:member]) {
        // User signed up with Twitter
        NSLog(@"User is connected to Twitter");
        NSURL *verify = [NSURL URLWithString:@"https://api.twitter.com/1/account/verify_credentials.json"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:verify];
        [[PFTwitterUtils twitter] signRequest:request];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * response, NSData * data, NSError * error) {
            if (!error) {
                NSLog(@"Twitter request success");
                NSString * responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSString * username = [[responseString JSONValue] objectForKey:@"screen_name"];
                [self updateUser:member withUsername:username email:nil dismissModal:YES];
            } else {
                NSLog(@"Twitter request failure");
                [self dismissModalViewControllerAnimated:YES];
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) [self setCornerButton:self.logOutButton visible:[PFUser currentUser] != nil animated:YES];
                [PushHelper updatePushNotificationSubscriptionsForMember:[PFUser currentUser]]; // Possibly overkill
            }
        }];
    } else {
        NSLog(@"User is not very social");
        // User signed up with username / email
        deferDismissal = NO;
    }
    
    if (!deferDismissal) {
        [self dismissModalViewControllerAnimated:YES];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) [self setCornerButton:self.logOutButton visible:[PFUser currentUser] != nil animated:YES];
        [PushHelper updatePushNotificationSubscriptionsForMember:[PFUser currentUser]]; // Possibly overkill
    }
    
}

- (void)request:(PF_FBRequest *)request didLoad:(id)result {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    NSString * firstName = [result objectForKey:@"first_name"];
    NSString * lastName  = [result objectForKey:@"last_name"];
    NSString * username  = [[NSString stringWithFormat:@"%@%@", firstName.lowercaseString, lastName.lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString * email     = [result objectForKey:@"email"];
    [self updateUser:[PFUser currentUser] withUsername:username email:email dismissModal:YES];
}

- (void)request:(PF_FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self dismissModalViewControllerAnimated:YES];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) [self setCornerButton:self.logOutButton visible:[PFUser currentUser] != nil animated:YES];
    [PushHelper updatePushNotificationSubscriptionsForMember:[PFUser currentUser]]; // Possibly overkill
}

- (void) updateUser:(PFUser *)user withUsername:(NSString *)username email:(NSString *)email dismissModal:(BOOL)shouldDismissModal {
    if (username) user.username = username;
    if (email) user.email = email;
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error != nil) {
            UIAlertView * errorAlertView = [[UIAlertView alloc] initWithTitle:@"Edit Account Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [errorAlertView show];
        }
        if (shouldDismissModal) {
            [self dismissModalViewControllerAnimated:YES];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) [self setCornerButton:self.logOutButton visible:[PFUser currentUser] != nil animated:YES];
            [PushHelper updatePushNotificationSubscriptionsForMember:[PFUser currentUser]]; // Possibly overkill
        }
    }];
}

#pragma mark - PFQueryTableViewController

- (void)objectsWillLoad {
    [super objectsWillLoad];
    
    // This method is called before a PFQuery is fired to get more objects
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    // This method is called every time objects are loaded from Parse via the PFQuery
}


// Override to customize what kind of query to perform on the class. The default is to query for all objects ordered by createdAt descending.
- (PFQuery *)queryForTable {
    
    PFQuery *query = [PFUser query]; // queryWithClassName:self.className]; // The User class is a special one in Parse, and as a result, when you are querying for users, you must use this special constructor.

    // If Pull To Refresh is enabled, query against the network by default.
    if (self.pullToRefreshEnabled) {
        query.cachePolicy = kPFCachePolicyNetworkOnly;
    }

    // If no objects are loaded in memory, we look to the cache first to fill the table and then subsequently do a query against the network.
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }

    [query orderByAscending:@"username"]; // Less chaotic looking this way for demo

    return query;
    
}


// Override to customize the look of a cell representing an object. The default is to display a UITableViewCellStyleDefault style cell with the label being the textKey in the object, and the imageView being the imageKey in the object.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"Cell";
    
    IndentedToggleCell *cell = (IndentedToggleCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[IndentedToggleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabelInsets = UIEdgeInsetsMake(0, 40.0, 0, 20.0);
        cell.toggleColor = [UIColor meetupColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 72.0 : 36.0];
    }
    
    // Configure the cell
    cell.textLabel.text = [object objectForKey:self.textKey];
    // cell.imageView.file = [object objectForKey:self.imageKey];
    
    return cell;
}


// Override if you need to change the ordering of objects in the table.
- (PFObject *)objectAtIndex:(NSIndexPath *)indexPath {
    return [self.objects objectAtIndex:indexPath.row];
}

// Override to customize the look of the cell that allows the user to load the next page of objects.
// The default implementation is a UITableViewCellStyleDefault cell with simple labels.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"NextPage";
    
    IndentedToggleCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[IndentedToggleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.text = @"load more";
        cell.textLabel.font = [UIFont boldSystemFontOfSize:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 48.0 : 24.0];
        cell.toggleColor = [UIColor softGrayColor];
        cell.textLabelInsets = UIEdgeInsetsMake(0, 40.0, floorf(self.tableView.rowHeight / 4.0), 20.0);
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = self.tableView.rowHeight;
    if (indexPath.row >= self.objects.count) height = floorf(height * 3.0 / 4.0);
    return height;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.objects.count) {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    } else {
        [self pushAppsViewControllerForMember:(PFUser *)[self objectAtIndexPath:indexPath]];
    }
}

- (void) pushAppsViewControllerForMember:(PFUser *)member {
    AppsTableViewController * appsVC = [[AppsTableViewController alloc] initWithStyle:UITableViewStylePlain];
    appsVC.member = member;
    [self.navigationController pushViewController:appsVC animated:YES];
}

// The following is necessary due to the fact that the table view is (annoyingly / as is custom) the main view for this UITableViewController subclass.
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
        CGRect cornerButtonsContainerFrame = self.cornerButtonsContainer.frame;
        cornerButtonsContainerFrame.origin.y = self.tableView.contentOffset.y;
        self.cornerButtonsContainer.frame = cornerButtonsContainerFrame;
    }
}

@end