//
//  AddAppViewController.m
//  NYiOS
//
//  Created by Dan Bretl on 8/22/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import "AddAppViewController.h"
#import "IndentedToggleCell.h"
#import "UIView+GetFirstResponder.h"
#import "UIAlertView+NYiOS.h"
#import "UIColor+NYiOS.h"
#import <QuartzCore/QuartzCore.h>
#import "ParseClient.h"
#import "PushHelper.h"

NSString * const AAVC_TAG_LINE_PLACEHOLDER_TEXT = @"tag line / micro-description of the app";

@interface AddAppViewController ()
- (void) showScrollContainer:(UIScrollView *)scrollContainer animated:(BOOL)animated;
@property (nonatomic, strong) NSArray * appSearchResults;
- (void) keyboardWillShow:(NSNotification *)notification;
- (void) keyboardWillHide:(NSNotification *)notification;
@property (nonatomic, strong) PFObject * appExisting;
- (IBAction)relationButtonTouched:(UIButton *)sender;
- (IBAction)submitButtonTouched:(UIButton *)sender;
- (IBAction)swipedBack:(UISwipeGestureRecognizer *)sender;
@property (nonatomic, strong) NSString * titlePreEdit;
@end

@implementation AddAppViewController
@synthesize submitButton = _submitButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.appSearchResults = nil;
        self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        self.modalPresentationStyle = UIModalPresentationPageSheet;
        self.titlePreEdit = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Register for keyboard events
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.appSearchResultsTableView.rowHeight = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 60.0 : 30.0;
    self.tagLineTextView.font = [UIFont systemFontOfSize:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 36.0 : 18.0];
    
//    self.titleTextField.layer.borderColor = [UIColor softGrayColor].CGColor;
//    self.titleTextField.layer.borderWidth = 1.0;
//    self.appStoreTextField.layer.borderColor = [UIColor softGrayColor].CGColor;
//    self.appStoreTextField.layer.borderWidth = 1.0;
//    self.websiteTextField.layer.borderColor = [UIColor softGrayColor].CGColor;
//    self.websiteTextField.layer.borderWidth = 1.0;
//    self.tagLineTextView.layer.borderColor = [UIColor softGrayColor].CGColor;
//    self.tagLineTextView.layer.borderWidth = 1.0;
    
    [self.relationDeveloperButton setTitleColor:[UIColor meetupColor] forState:UIControlStateHighlighted|UIControlStateSelected];
    [self.relationFanButton setTitleColor:[UIColor meetupColor] forState:UIControlStateHighlighted|UIControlStateSelected];
    
    [self updateAppDetailsFromApp:self.appExisting updateTitle:YES];
    [self updateSubmitButton];
    self.relationDeveloperButton.selected = YES;
    self.relationFanButton.selected = NO;
    
    self.appSearchResultsTableView.frame = self.mainContainer.bounds;
    self.appDetailsScrollView.frame = self.mainContainer.bounds;
    self.appDetailsScrollView.contentSize = self.appDetailsScrollView.bounds.size;
    [self.mainContainer addSubview:self.appDetailsScrollView];
    [self.mainContainer addSubview:self.appSearchResultsTableView];
    [self showScrollContainer:self.appSearchResultsTableView animated:NO];
    
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [self setTitleTextField:nil];
    [self setAppStoreTextField:nil];
    [self setWebsiteTextField:nil];
    [self setTagLineTextView:nil];
    [self setRelationDeveloperButton:nil];
    [self setRelationFanButton:nil];
    [self setAppDetailsScrollView:nil];
    [self setAppSearchResultsTableView:nil];
    [self setMainContainer:nil];
    [self setSubmitButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ||
            UIInterfaceOrientationIsPortrait(interfaceOrientation));
}

- (void)showScrollContainer:(UIScrollView *)scrollContainer animated:(BOOL)animated {
    void(^alphaChanges)(void) = ^{
        self.appSearchResultsTableView.alpha = scrollContainer == self.appSearchResultsTableView ? 1.0 : 0.0;
        self.appDetailsScrollView.alpha = scrollContainer == self.appDetailsScrollView ? 1.0 : 0.0;
    };
    if (animated) {
        [UIScrollView animateWithDuration:0.25 animations:^{
            alphaChanges();
            [scrollContainer setContentOffset:CGPointZero];
        }];
    } else {
        alphaChanges();
        [scrollContainer setContentOffset:CGPointZero];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.appSearchResults.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"Cell";
    
    IndentedToggleCell *cell = (IndentedToggleCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[IndentedToggleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabelInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        cell.textLabel.font = [UIFont boldSystemFontOfSize:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 36.0 : 18.0];
    }
    
    // Configure the cell
    if (indexPath.row < self.appSearchResults.count) {
        cell.textLabel.text = [[self.appSearchResults objectAtIndex:indexPath.row] objectForKey:@"title"];
        cell.toggleColor = [UIColor meetupColor];
    } else {
        cell.textLabel.text = @"new app";
        cell.toggleColor = [UIColor softGrayColor];
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.titleTextField.text.length == 0) {
        [self.titleTextField becomeFirstResponder];
        return;
    }
    
    [self.titleTextField resignFirstResponder];
    
    PFObject * app = nil;
    BOOL updateTitle = NO;
    if (indexPath.row < self.appSearchResults.count) {
        app = [self.appSearchResults objectAtIndex:indexPath.row];
        updateTitle = YES;
    } else {
        app = nil;
    }
    self.appExisting = app;
    
    [self updateAppDetailsFromApp:self.appExisting updateTitle:updateTitle];
    [self showScrollContainer:self.appDetailsScrollView animated:YES];
    self.appSearchResults = nil;
    [self.appStoreTextField becomeFirstResponder];
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.titlePreEdit = textField.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    BOOL shouldReturn = YES;
    if (textField == self.titleTextField ||
        textField == self.appStoreTextField ||
        textField == self.websiteTextField) {
        shouldReturn = NO;
        [textField resignFirstResponder];
        if (textField == self.titleTextField &&
            self.titleTextField.text.length > 0 &&
            !([self.titleTextField.text isEqualToString:self.titlePreEdit] &&
              self.appDetailsScrollView.alpha > 0.0)) {
                [self showScrollContainer:self.appSearchResultsTableView animated:YES];
                [self searchForAppsWithName:self.titleTextField.text];
        }
    }
    return shouldReturn;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (textField == self.titleTextField) {
        self.titlePreEdit = nil;
    } else if (textField == self.appStoreTextField) {
        [self.websiteTextField becomeFirstResponder];
    } else if (textField == self.websiteTextField) {
        [self.tagLineTextView becomeFirstResponder];
    }
    [self updateSubmitButton];
}

// The following is a hack *to*the*extreme*! I don't like it.
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (textView == self.tagLineTextView) {
        if([text isEqualToString:@"\n"]) {
            [textView resignFirstResponder];
            return NO;
        }
    }
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView == self.tagLineTextView) {
        textView.text = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (textView.text.length == 0) {
            textView.text = AAVC_TAG_LINE_PLACEHOLDER_TEXT;
        }
    }
    [self updateSubmitButton];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == NoMatchingAppsAV) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            self.appExisting = nil;
            [self updateAppDetailsFromApp:self.appExisting updateTitle:NO];
            [self showScrollContainer:self.appDetailsScrollView animated:YES];
            [self.appStoreTextField becomeFirstResponder];
            self.appSearchResults = nil;
        } else {
            [self.titleTextField becomeFirstResponder];
        }
    } else if (alertView.tag == CancelAddAppAV) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [self.delegate addAppViewController:self didFinishWithAppListing:nil app:nil];
        }
    }
}

- (void) updateAppDetailsFromApp:(PFObject *)app updateTitle:(BOOL)shouldUpdateTitle {
    if (shouldUpdateTitle) self.titleTextField.text = [app objectForKey:@"title"];
    self.appStoreTextField.text = [app objectForKey:@"appStoreLink"];
    self.websiteTextField.text = [app objectForKey:@"websiteLink"];
    NSString * tagLineText = [app objectForKey:@"tagLine"];
    if (tagLineText.length == 0) {
        tagLineText = AAVC_TAG_LINE_PLACEHOLDER_TEXT;
    }
    self.tagLineTextView.text = tagLineText;
    [self updateSubmitButton];
}

- (void) updateSubmitButton {
    self.submitButton.enabled = (self.appDetailsScrollView.alpha > 0.0 &&
                                 self.titleTextField.text.length > 0 &&
                                 self.appStoreTextField.text.length > 0 &&
                                 self.websiteTextField.text.length > 0 &&
                                 self.tagLineTextView.text.length > 0 &&
                                 ![self.tagLineTextView.text isEqualToString:AAVC_TAG_LINE_PLACEHOLDER_TEXT]);
}

- (void) searchForAppsWithName:(NSString *)appName {
    PFQuery * appsQuery = [PFQuery queryWithClassName:@"App"];
    [appsQuery whereKey:@"title" matchesRegex:appName modifiers:@"i"];
    [appsQuery orderByAscending:@"title"];
    [appsQuery addDescendingOrder:@"createdAt"];
    [appsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.appSearchResults = objects;
            [self.appSearchResultsTableView reloadData];
            if (self.appSearchResults.count == 0) {
                [[UIAlertView noMatchingAppsAVWithDelegate:self] show];
            }
        } else {
            [[UIAlertView connectionErrorAV] show];
            [self.titleTextField becomeFirstResponder];
        }
    }];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary * info = [notification userInfo];
	CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    double keyboardAnimationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve keyboardAnimationCurve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    [UIScrollView animateWithDuration:keyboardAnimationDuration delay:0.0 options:keyboardAnimationCurve animations:^{
        UIEdgeInsets insetsForKeyboard = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0);
        self.appSearchResultsTableView.contentInset = insetsForKeyboard;
        self.appSearchResultsTableView.scrollIndicatorInsets = insetsForKeyboard;
        self.appDetailsScrollView.contentInset = insetsForKeyboard;
        self.appDetailsScrollView.scrollIndicatorInsets = insetsForKeyboard;
        UIView * inputFirstResponder = [self.appDetailsScrollView getFirstResponder];
        if (inputFirstResponder) {
            [self.appDetailsScrollView scrollRectToVisible:inputFirstResponder.frame animated:NO];
        }
    } completion:NULL];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary * info = [notification userInfo];
    double keyboardAnimationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve keyboardAnimationCurve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    [UIView animateWithDuration:keyboardAnimationDuration delay:0.0 options:keyboardAnimationCurve animations:^{
        self.appSearchResultsTableView.contentInset = UIEdgeInsetsZero;
        self.appDetailsScrollView.contentInset = UIEdgeInsetsZero;
    } completion:NULL];
}

- (IBAction)submitButtonTouched:(UIButton *)sender {
    // NOTE THAT WE ARE COMPLETELY IGNORING THE POSSIBILITY OF A NETWORK ERROR OCCURRING. VERY BAD IDEA!
    PFObject * app = self.appExisting;
    if (app == nil) {
        app = [PFObject objectWithClassName:@"App"];
        [app setObject:self.titleTextField.text forKey:@"title"];
        [app setObject:self.appStoreTextField.text forKey:@"appStoreLink"];
        [app setObject:self.websiteTextField.text forKey:@"websiteLink"];
        [app setObject:self.tagLineTextView.text forKey:@"tagLine"];
        [app save]; // Really bad idea! Synchronous network calls are GROSS. But they make for slightly easier demo code.
    }
    PFObject * appListing = [PFObject objectWithClassName:@"AppListing"];
    [appListing setObject:app forKey:@"app"];
    [appListing setObject:self.member forKey:@"member"];
    [appListing setObject:self.relationDeveloperButton.selected ? PARSE_APP_LISTING_RELATION_DEVELOPER : PARSE_APP_LISTING_RELATION_FAN forKey:@"relation"]; // If we have ever more than two possible relations that can be set in this VC, this logic will have to be improved. I'm getting lazy.
    [appListing save]; // Seriously! Don't ever use these synchronous network calls in production!
    [PushHelper sendPushNotificationFromMember:self.member forListingOfApp:app claimedRelation:[appListing objectForKey:@"relation"]];
    [PushHelper updatePushNotificationSubscriptionsForMember:[PFUser currentUser]];
    [self.delegate addAppViewController:self didFinishWithAppListing:appListing app:app];
}

- (IBAction)relationButtonTouched:(UIButton *)sender {
    self.relationDeveloperButton.selected = sender == self.relationDeveloperButton;
    self.relationFanButton.selected = sender == self.relationFanButton;
    [self updateSubmitButton];
}

- (IBAction)swipedBack:(UISwipeGestureRecognizer *)sender {
    if (self.appDetailsScrollView.alpha > 0.0) {
        [[UIAlertView cancelAddAppAVWithDelegate:self] show];
    } else {
        [self.delegate addAppViewController:self didFinishWithAppListing:nil app:nil];
    }
}

@end
