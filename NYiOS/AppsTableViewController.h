//
//  AppsTableViewController.h
//  NYiOS
//
//  Created by Dan Bretl on 8/22/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import <Parse/Parse.h>

@interface AppsTableViewController : PFQueryTableViewController

@property (nonatomic, strong) PFUser * member;

@end
