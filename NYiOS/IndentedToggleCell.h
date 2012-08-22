//
//  IndentedToggleCell.h
//  NYiOS
//
//  Created by Dan Bretl on 8/21/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import <Parse/Parse.h>

@interface IndentedToggleCell : PFTableViewCell

@property (nonatomic, strong) UIColor * toggleColor;
@property (nonatomic) UIEdgeInsets textLabelInsets;

@end