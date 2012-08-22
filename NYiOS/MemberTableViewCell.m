//
//  MemberTableViewCell.m
//  NYiOS
//
//  Created by Dan Bretl on 8/21/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import "MemberTableViewCell.h"
#import "UIColor+NYiOS.h"

@implementation MemberTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
//        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.textLabel.font = [UIFont boldSystemFontOfSize:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 72.0 : 36.0];
        self.textLabel.adjustsFontSizeToFitWidth = YES;
        self.textLabel.textColor = [UIColor meetupColor];
        self.textLabel.highlightedTextColor = [UIColor whiteColor];
        
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    self.backgroundColor = highlighted ? [UIColor meetupColor] : [UIColor whiteColor];
    self.textLabel.highlighted = highlighted;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    self.backgroundColor = selected ? [UIColor meetupColor] : [UIColor whiteColor];
    self.textLabel.highlighted = selected;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textLabel.frame = CGRectInset(self.contentView.frame, 20.0, 0.0);
}

@end
