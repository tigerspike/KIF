//
//  UITouch+KIFRUtils.h
//  TSSales
//
//  Created by Morgan Pretty on 24/03/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITouch (KIFRUtils)

@property (nonatomic, readonly) BOOL isKeyboardEvent;

- (CGPoint)recordedLocationInView:(UIView *)view;
- (UIView *)accessibleViewWithPossibilities:(NSArray *)possibleViews;

@end
