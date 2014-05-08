//
//  UITouch+KIFRUtils.m
//  TSSales
//
//  Created by Morgan Pretty on 24/03/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import "UITouch+KIFRUtils.h"

@implementation UITouch (KIFRUtils)

- (BOOL)isKeyboardEvent {
    return ([self.view.window isKindOfClass:NSClassFromString(@"UITextEffectsWindow")]);
}

- (CGPoint)recordedLocationInView:(UIView *)view {
    CGPoint localPoint = [self locationInView:view];
    
    // If it's a UIScrollView we need to modify the touch position by subtracting the contentOffset
    if ([view isKindOfClass:[UIScrollView class]]) {
        CGPoint contentOffset = [(UIScrollView *)view contentOffset];
        localPoint = CGPointMake(localPoint.x - contentOffset.x, localPoint.y - contentOffset.y);
    }
    
    return localPoint;
}

- (UIView *)accessibleViewWithPossibilities:(NSArray *)possibleViews {
    // We need a view to have an accessibility label to be a contender for recording interaction (unless it is a keyboard event)
    if (self.isKeyboardEvent || (self.view && self.view.accessibilityLabel.length > 0)) {
        return self.view;
    }
    
    // If the touched view doesn't meet the criteria then assume the lastObject in the 'possibleViews' array is the correct one (the array will be sorted by z-index by default, so it should be the top-most view, and the UIResponder chain would take care of the rest)
    return possibleViews.lastObject;
}

@end
