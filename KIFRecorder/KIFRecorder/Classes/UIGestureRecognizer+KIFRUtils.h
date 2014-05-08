//
//  UIGestureRecognizer+KIFRUtils.h
//  TSSales
//
//  Created by Morgan Pretty on 24/03/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - Tap

@interface UITapGestureRecognizer (KIFRUtils)

@property (nonatomic, readonly) NSArray *kifrTouches;

@end

#pragma mark - Pan

@interface UIPanGestureRecognizer (KIFRUtils)

@property (nonatomic, readonly) NSArray *kifrTouches;

- (CGPoint)KIFR_velocityInView:(UIView *)view;

@end

#pragma mark - Pinch

@interface UIPinchGestureRecognizer (KIFRUtils)

@property (nonatomic, readonly) NSArray *kifrTouches;

- (void)KIFR_touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (CGFloat)KIFR_velocity;

@end

#pragma mark - Long Press

@interface UILongPressGestureRecognizer (KIFRUtils)

@property (nonatomic, readonly) NSArray *kifrTouches;

@end
