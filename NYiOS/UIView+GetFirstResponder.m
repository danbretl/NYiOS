//
//  UIView+GetFirstResponder.m
//  NYiOS
//
//  Created by Dan Bretl on 8/22/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import "UIView+GetFirstResponder.h"

@implementation UIView (GetFirstResponder)

- (UIView *)getFirstResponder {
    
    if (self.isFirstResponder) {
        return self;
    }
    
    for (UIView * subView in self.subviews) {
        UIView * firstResponder = [subView getFirstResponder];
        
        if (firstResponder != nil) {
            return firstResponder;
        }
    }
    
    return nil;
    
}

@end
