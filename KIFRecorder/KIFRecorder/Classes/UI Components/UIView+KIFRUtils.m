//
//  UIView+KIFRUtils.m
//  KIFRecording
//
//  Created by Morgan Pretty on 26/03/14.
//  Copyright (c) 2013 Tigerspike. All rights reserved.
//

#import "UIView+KIFRUtils.h"
#import <objc/runtime.h>

#define kKifrShouldIgnoreKey @"KifrShouldIgnoreKey"

@implementation UIView (KIFRUtils)

- (UIView *)subviewWithClassName:(NSString *)className {
    if ([self isKindOfClass:NSClassFromString(className)]) {
        return self;
    }
    
    for (UIView *subview in self.subviews) {
        UIView *foundView = [subview subviewWithClassName:className];
        if (foundView) {
            return foundView;
        }
    }
    
    return nil;
}

#pragma mark - Associate Category Variable Methods

- (BOOL)kifrShouldIgnore {
    NSNumber *kifrShouldIgnore = objc_getAssociatedObject(self, kKifrShouldIgnoreKey);
    return [kifrShouldIgnore boolValue];
}

- (void)setKifrShouldIgnore:(BOOL)kifrShouldIgnore {
    objc_setAssociatedObject(self, kKifrShouldIgnoreKey, @(kifrShouldIgnore), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)recursiveKIFRShouldIgnore {
    return self.kifrShouldIgnore;
}

- (void)setRecursiveKIFRShouldIgnore:(BOOL)kifrShouldIgnore {
    self.kifrShouldIgnore = kifrShouldIgnore;
    
    for (UIView *view in self.subviews) {
        view.recursiveKIFRShouldIgnore = kifrShouldIgnore;
    }
}

#pragma mark - Modify Frame Methods

- (CGPoint)kifrOrigin {
    return self.frame.origin;
}

- (void)setKifrOrigin:(CGPoint)kifrOrigin {
    CGRect r = self.frame;
    r.origin = kifrOrigin;
    self.frame = r;
}

- (CGFloat)kifrX {
    return self.frame.origin.x;
}

- (void)setKifrX:(CGFloat)kifrX {
    CGRect r = self.frame;
    r.origin.x = kifrX;
    self.frame = r;
}

- (CGFloat)kifrY {
    return self.frame.origin.y;
}

- (void)setKifrY:(CGFloat)kifrY {
    CGRect r = self.frame;
    r.origin.y = kifrY;
    self.frame = r;
}

- (CGSize)kifrSize {
    return self.frame.size;
}

- (void)setKifrSize:(CGSize)kifrSize {
    CGRect r = self.frame;
    r.size = kifrSize;
    self.frame = r;
}

- (CGFloat)kifrWidth {
    return self.frame.size.width;
}

- (void)setKifrWidth:(CGFloat)kifrWidth {
    CGRect r = self.frame;
    r.size.width = kifrWidth;
    self.frame = r;
}

- (CGFloat)kifrHeight {
    return self.frame.size.height;
}

- (void)setKifrHeight:(CGFloat)kifrHeight {
    CGRect r = self.frame;
    r.size.height = kifrHeight;
    self.frame = r;
}

- (CGFloat)kifrFrameRight {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setKifrFrameRight:(CGFloat)kifrFrameRight {
    CGRect r = self.frame;
    r.origin.x = kifrFrameRight - r.size.width;
    self.frame = r;
}

- (CGFloat)kifrFrameBottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setKifrFrameBottom:(CGFloat)kifrFrameBottom {
    CGRect r = self.frame;
    r.origin.y = kifrFrameBottom - r.size.height;
    self.frame = r;
}

@end
