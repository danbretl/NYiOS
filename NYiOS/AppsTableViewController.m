//
//  AppsTableViewController.m
//  NYiOS
//
//  Created by Dan Bretl on 8/22/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "AppsTableViewController.h"
#import "IndentedToggleCell.h"
#import "AppDetailViewController.h"
#import "UIColor+NYiOS.h"
#import "ParseClient.h"

@interface AppsTableViewController ()
@property (nonatomic, strong) UISwipeGestureRecognizer * backSwipeGestureRecognizer;
- (void) swipedBack;
@property (nonatomic, strong) UIButton * addButton;
@property (nonatomic, strong) NSArray * cornerButtons;
@property (nonatomic, strong) UIView * cornerButtonsContainer;
- (void) cornerButtonTouched:(UIButton *)button;
- (void) setCornerButton:(UIButton *)cornerButton visible:(BOOL)visible animated:(BOOL)animated;
@end

@implementation AppsTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        
        // The className to query on
        self.className = @"AppListing";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 100;
        
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
    
    self.backSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedBack)];
    self.backSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:self.backSwipeGestureRecognizer];
    
    self.addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.addButton setTitle:@"+" forState:UIControlStateNormal];
    self.cornerButtons = @[self.addButton];
    
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
        cornerButton.titleLabel.font = [UIFont boldSystemFontOfSize:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 48.0 : 24.0];
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
    self.addButton = nil;
    self.cornerButtonsContainer = nil;
    self.cornerButtons = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setCornerButton:self.addButton visible:[[PFUser currentUser].objectId isEqualToString:self.member.objectId] animated:NO];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad || interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)setMember:(PFUser *)member {
    _member = member;
    [self loadObjects];
}

- (void)swipedBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) setCornerButton:(UIButton *)cornerButton visible:(BOOL)visible animated:(BOOL)animated {
    [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
        cornerButton.alpha = visible ? 1.0 : 0.0;
    }];
}

- (void)cornerButtonTouched:(UIButton *)button {
    if (button == self.addButton) {
        AddAppViewController * addAppVC = [[AddAppViewController alloc] initWithNibName:@"AddAppViewController" bundle:[NSBundle mainBundle]];
        addAppVC.member = self.member;
        addAppVC.delegate = self;
        [self presentModalViewController:addAppVC animated:YES];
    }
}

- (void)addAppViewController:(AddAppViewController *)viewController didFinishWithAppListing:(PFObject *)appListing app:(PFObject *)app {
    if (appListing && app) {
        [self loadObjects];
    }
    [self dismissModalViewControllerAnimated:YES];
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
    
    PFQuery *query = [PFQuery queryWithClassName:self.className];
    
    // If Pull To Refresh is enabled, query against the network by default.
    if (self.pullToRefreshEnabled) {
        query.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    
    // If no objects are loaded in memory, we look to the cache first to fill the table and then subsequently do a query against the network.
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query whereKey:@"member" equalTo:self.member];
    [query addAscendingOrder:@"relation"]; // This ordering is really weak, based solely on the coincidence that what we want at the top happens to (currently) be alphabetically the first option.
    [query addDescendingOrder:@"createdAt"];
    [query includeKey:@"app"];
    
    return query;
    
}


// Override to customize the look of a cell representing an object. The default is to display a UITableViewCellStyleDefault style cell with the label being the textKey in the object, and the imageView being the imageKey in the object.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"Cell";
    
    IndentedToggleCell *cell = (IndentedToggleCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[IndentedToggleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabelInsets = UIEdgeInsetsMake(0, 20.0, 0, 20.0);
        cell.toggleColor = [UIColor meetupColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 72.0 : 36.0];
    }
    
    // Configure the cell
    cell.textLabel.text = [[object objectForKey:@"app"] objectForKey:@"title"];
    cell.toggleColor = [[object objectForKey:@"relation"] isEqualToString:PARSE_APP_LISTING_RELATION_DEVELOPER] ? [UIColor meetupColor] : [UIColor softGrayColor];
    
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
        AppDetailViewController * appDetailVC = [[AppDetailViewController alloc] initWithNibName:@"AppDetailViewController" bundle:[NSBundle mainBundle]];
        PFObject * appListing = [self objectAtIndex:indexPath];
        PFObject * app = [appListing objectForKey:@"app"];
        PFUser * developer = nil;
        if ([[appListing objectForKey:@"relation"] isEqualToString:PARSE_APP_LISTING_RELATION_DEVELOPER]) {
            developer = self.member;
        }
        [appDetailVC setApp:app by:developer from:self.member];
        [self.navigationController pushViewController:appDetailVC animated:YES];
    }
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