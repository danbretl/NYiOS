//
//  IndentedToggleCell.m
//  NYiOS
//
//  Created by Dan Bretl on 8/21/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import "IndentedToggleCell.h"
#import "UIColor+NYiOS.h"

@interface IndentedToggleCell()
- (void) setToggled:(BOOL)toggled animated:(BOOL)animated; // Currently ignoring the animated parameter
@end

@implementation IndentedToggleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.textLabelInsets = UIEdgeInsetsZero;
        self.toggleColor = [UIColor blackColor];
        
        self.textLabel.adjustsFontSizeToFitWidth = YES;
        
    }
    return self;
}

- (void)setTextLabelInsets:(UIEdgeInsets)textLabelInsets {
    _textLabelInsets = textLabelInsets;
    [self setNeedsLayout];
}

- (void)setToggleColor:(UIColor *)toggleColor {
    _toggleColor = toggleColor;
    self.textLabel.textColor = self.toggleColor;
    self.textLabel.highlightedTextColor = [UIColor whiteColor];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [self setToggled:highlighted animated:animated];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [self setToggled:selected animated:animated];
}

- (void) setToggled:(BOOL)toggled animated:(BOOL)animated {
    self.backgroundColor = !toggled ? [UIColor whiteColor] : self.toggleColor;
    self.textLabel.highlighted = toggled;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textLabel.frame = UIEdgeInsetsInsetRect(self.contentView.bounds, self.textLabelInsets);
}

@end
