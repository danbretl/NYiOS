//
//  AppDetailViewController.m
//  NYiOS
//
//  Created by Dan Bretl on 8/22/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import "AppDetailViewController.h"
#import "AppsTableViewController.h"
#import "ParseClient.h"
#import "UIColor+NYiOS.h"

@interface AppDetailViewController ()
@property (nonatomic, strong) PFObject * app;
@property (nonatomic, strong) PFUser * navMember;
@property (nonatomic, strong) PFUser * developer;
@property (nonatomic) BOOL isSearchingForDeveloper;
- (void) updateViewsWithData;
- (void) updateIconImageView;
- (void) updateByLineButton;
- (IBAction)swipedBack:(UISwipeGestureRecognizer *)sender;
@end

@implementation AppDetailViewController
@synthesize iconImageView = _iconImageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLabel.textColor = [UIColor meetupColor];
    self.tagLineLabel.textColor = [UIColor meetupColor];
    void(^buttonColorsGrayMeetup)(UIButton *) = ^(UIButton * button) {
        [button setTitleColor:[UIColor softGrayColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor meetupColor] forState:UIControlStateHighlighted];
    };
    buttonColorsGrayMeetup(self.byLineButton);
    buttonColorsGrayMeetup(self.appStoreButton);
    buttonColorsGrayMeetup(self.appWebsiteButton);
    
    BOOL iPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    self.tagLineLabel.font = [UIFont boldSystemFontOfSize:iPad ? 72.0 : 24.0];
    
    [self updateViewsWithData];
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setByLineButton:nil];
    [self setTagLineLabel:nil];
    [self setAppStoreButton:nil];
    [self setAppWebsiteButton:nil];
    [self setIconImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad || interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)setApp:(PFObject *)app by:(PFUser *)developer from:(PFUser *)navMember {
    
    self.app = app;
    self.developer = developer;
    self.navMember = navMember;
    
    [self updateViewsWithData];
    
    if (self.app) {
        BOOL developerKnown = self.developer != nil;
        if (!developerKnown) {
            self.isSearchingForDeveloper = YES;
            [self updateByLineButton];
            PFQuery * developerQuery = [PFQuery queryWithClassName:@"AppListing"];
            [developerQuery whereKey:@"app" equalTo:self.app];
            [developerQuery whereKey:@"relation" equalTo:PARSE_APP_LISTING_RELATION_DEVELOPER];
            [developerQuery orderByAscending:@"createdAt"];
            [developerQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error && objects.count > 0) {
                    self.developer = [objects objectAtIndex:0];
                }
                self.isSearchingForDeveloper = NO;
                [self updateByLineButton];
            }];
        }
    }
    
}

- (void) updateIconImageView {
    self.iconImageView.image = [UIImage imageNamed:@"appstore.png"]; // placeholder image
    self.iconImageView.file = (PFFile *)[self.app objectForKey:@"icon"]; // remote image
    [self.iconImageView loadInBackground];
}

- (void) updateByLineButton {
    self.byLineButton.enabled = self.developer != nil;
    NSString * byLineText = nil;
    if (self.developer != nil) {
        byLineText = [NSString stringWithFormat:@"by %@", [self.developer objectForKey:@"username"]];
    } else {
        byLineText = self.isSearchingForDeveloper ? @"(looking for developers)" : @"(developers not found)";
    }
    [self.byLineButton setTitle:byLineText forState:UIControlStateNormal];
}

- (void) updateViewsWithData {
    [self updateIconImageView];
    self.titleLabel.text = [self.app objectForKey:@"title"];
    [self updateByLineButton];
    self.tagLineLabel.text = [self.app objectForKey:@"tagLine"];
}

- (IBAction)appButtonTouched:(UIButton *)sender {
    NSString * urlString = nil;
    if (sender == self.appStoreButton) {
        urlString = [self.app objectForKey:@"appStoreLink"];
    } else if (sender == self.appWebsiteButton) {
        urlString = [self.app objectForKey:@"websiteLink"];
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

- (IBAction)byLineButtonTouched:(UIButton *)sender {
    if ([self.developer.objectId isEqualToString:self.navMember.objectId]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        AppsTableViewController * appsTableVC = [[AppsTableViewController alloc] initWithStyle:UITableViewStylePlain];
        appsTableVC.member = self.developer;
        [self.navigationController pushViewController:appsTableVC animated:YES];
    }
}

- (IBAction)swipedBack:(UISwipeGestureRecognizer *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
