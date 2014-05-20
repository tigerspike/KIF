//
//  UIDatePicker+KIFRUtils.m
//  KIFRecorder
//
//  Created by Morgan Pretty on 20/05/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import "UIDatePicker+KIFRUtils.h"
#import <objc/runtime.h>

#define ON_ANIMATION_FINISHED_BLOCK_KEY @"onAnimationFinished_Block_Key"
#define UIPICKERTABLEVIEW_IS_ANIMATING_KEY @"UIPickerTableView_isAnimating_Key"

@interface UIDatePicker (KIFRUtils_Private)

@property (nonatomic, copy) void (^onAnimationFinished)(NSDate *newDate);

@end

@implementation UIDatePicker (KIFRUtils)

#pragma mark - Internal methods to track the block

- (void)setOnAnimationFinished:(void (^)(NSDate *newDate))onAnimationFinished {
    objc_setAssociatedObject(self, ON_ANIMATION_FINISHED_BLOCK_KEY, onAnimationFinished, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(NSDate *newDate))onAnimationFinished {
    void (^onAnimationFinished)(NSDate *newDate) = (void (^)(NSDate *newDate))objc_getAssociatedObject(self, ON_ANIMATION_FINISHED_BLOCK_KEY);
    if (onAnimationFinished != nil) {
        return onAnimationFinished;
    }
    
    return nil;
}

#pragma mark - Public method to call

- (void)onAnimationFinishedPerformBlock:(void (^)(NSDate *newDate))onAnimationFinished {
    self.onAnimationFinished = onAnimationFinished;
    
    NSArray *pickerTableViews = [self getSubviewsOfClass:NSClassFromString(@"UIPickerTableView")];
    for (UIView *view in pickerTableViews) {
        [view setValue:@(YES) forKey:@"kifrIsAnimatingScrolling"];
        [view addObserver:self forKeyPath:@"kifrIsAnimatingScrolling" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSArray *pickerTableViews = [self getSubviewsOfClass:NSClassFromString(@"UIPickerTableView")];
    for (UIView *view in pickerTableViews) {
        [view removeObserver:self forKeyPath:@"kifrIsAnimatingScrolling"];
    }
    
    void (^onAnimationFinished)(NSDate *newDate) = self.onAnimationFinished;
    if (onAnimationFinished != nil) {
        onAnimationFinished(self.date);
    }
    self.onAnimationFinished = nil;
}

@end

@interface UIDatePicker (UIPickerTableView_KIFRUtils_Private)

@property (nonatomic, assign) BOOL kifrIsAnimatingScrolling;

@end

@implementation NSObject (UIPickerTableView_KIFRUtils)

- (void)setKifrIsAnimatingScrolling:(BOOL)kifrIsAnimatingScrolling {
    objc_setAssociatedObject(self, UIPICKERTABLEVIEW_IS_ANIMATING_KEY, @(kifrIsAnimatingScrolling), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)kifrIsAnimatingScrolling {
    BOOL isAnimatingScrolling = [(NSNumber *)objc_getAssociatedObject(self, UIPICKERTABLEVIEW_IS_ANIMATING_KEY) boolValue];
    return isAnimatingScrolling;
}

- (void)KIFR_scrollingFinished {
    [self KIFR_scrollingFinished];
    
    [self willChangeValueForKey:@"kifrIsAnimatingScrolling"];
    self.kifrIsAnimatingScrolling = NO;
    [self didChangeValueForKey:@"kifrIsAnimatingScrolling"];
}

@end
