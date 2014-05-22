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
    // We need a view to have an accessibility identifier to be a contender for recording interaction (unless it is a keyboard event)
    if (self.isKeyboardEvent || (self.view && self.view.accessibilityIdentifier.length > 0)) {
        return self.view;
    }
    
    // If the touched view doesn't meet the criteria then try find the relevant view in the 'possibleViews' array.
    
    // MKAnnotationViews have the same z-index so if there are multiple options we actually want the first one (as that's what would have been clicked)
    if ([possibleViews.lastObject isKindOfClass:NSClassFromString(@"MKAnnotationView")]) {
        UIView *annotationView;
        for (int i = (int)possibleViews.count - 1; i >= 0; --i) {
            if ([possibleViews[i] isKindOfClass:NSClassFromString(@"MKAnnotationView")]) {
                annotationView = possibleViews[i];
            }
            else {
                // There aren't any more MKAnnotationViews in front of this one so return it
                return annotationView;
            }
        }
    }
    
    // If we don't need to worry about any special cases then ssume the lastObject in the 'possibleViews' array is the correct one (the array will be sorted by z-index by default, so it should be the top-most view, and the UIResponder chain would take care of the rest)
    return possibleViews.lastObject;
}

@end
