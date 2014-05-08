//
//  UIGestureRecognizer+KIFRUtils.m
//  TSSales
//
//  Created by Morgan Pretty on 24/03/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import "UIGestureRecognizer+KIFRUtils.h"
#import <objc/runtime.h>

#define kPinchTouchesKey @"PinchTouchesKey"

#pragma mark - Tap

@implementation UITapGestureRecognizer (KIFRUtils)

- (NSArray *)kifrTouches {
    return [self valueForKey:@"touches"];
}

@end

#pragma mark - Pan

@implementation UIPanGestureRecognizer (KIFRUtils)

- (NSArray *)kifrTouches {
    return [self valueForKey:@"touches"];
}

- (CGPoint)KIFR_velocityInView:(UIView *)view {
    // Remove any velocity (can't handle flinging at the moment)
    return CGPointZero;
}

@end

#pragma mark - Pinch

@implementation UIPinchGestureRecognizer (KIFRUtils)

- (NSArray *)kifrTouches {
    NSArray *touches = objc_getAssociatedObject(self, kPinchTouchesKey);
    return touches;
}

- (void)KIFR_touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Store the touches in an array
    objc_setAssociatedObject(self, kPinchTouchesKey, [touches allObjects], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self KIFR_touchesBegan:touches withEvent:event];
}

- (CGFloat)KIFR_velocity {
    // Remove any velocity (can't handle flinging at the moment)
    return 0;
}

@end

#pragma mark - Long Press

@implementation UILongPressGestureRecognizer (KIFRUtils)

- (NSArray *)kifrTouches {
    return [self valueForKey:@"touches"];
}

@end
