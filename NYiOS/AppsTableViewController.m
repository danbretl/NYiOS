//
//  AppsTableViewController.m
//  NYiOS
//
//  Created by Dan Bretl on 8/22/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppsTableViewController.h"
#import "IndentedToggleCell.h"
#import "AppDetailViewController.h"
#import "UIColor+NYiOS.h"
#import "ParseClient.h"

@interface AppsTableViewController ()
@property (nonatomic, strong) UISwipeGestureRecognizer * backSwipeGestureRecognizer;
- (void) swipedBack;
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
    // CGFloat screenMinDimension = MIN(screenSize.width, screenSize.height);
    
    self.tableView.rowHeight = floorf(screenMaxDimension / 8.5);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone; // This doesn't seem to be having any effect.
    self.tableView.separatorColor = [UIColor whiteColor]; // Fallback solution.
    
    self.backSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedBack)];
    self.backSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:self.backSwipeGestureRecognizer];
        
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

@end