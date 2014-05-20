//
//  UIView+KIFRUtils.h
//  KIFRecording
//
//  Created by Morgan Pretty on 26/03/14.
//  Copyright (c) 2013 Tigerspike. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (KIFRUtils)

@property (nonatomic, assign) BOOL kifrShouldIgnore;
@property (nonatomic, assign) BOOL recursiveKIFRShouldIgnore;

- (UIView *)subviewWithClassName:(NSString *)className;
- (NSArray *)getSubviewsOfClass:(Class)classType;

#pragma mark - Modify Frame Methods

- (CGPoint)kifrOrigin;
- (void)setKifrOrigin:(CGPoint)kifrOrigin;
- (CGFloat)kifrX;
- (void)setKifrX:(CGFloat)kifrX;
- (CGFloat)kifrY;
- (void)setKifrY:(CGFloat)kifrY;

- (CGSize)kifrSize;
- (void)setKifrSize:(CGSize)kifrSize;
- (CGFloat)kifrWidth;
- (void)setKifrWidth:(CGFloat)kifrWidth;
- (CGFloat)kifrHeight;
- (void)setKifrHeight:(CGFloat)kifrHeight;

- (CGFloat)kifrFrameRight;
- (void)setKifrFrameRight:(CGFloat)kifrFrameRight;
- (CGFloat)kifrFrameBottom;
- (void)setKifrFrameBottom:(CGFloat)kifrFrameBottom;

@end
