//
//  UIDatePicker+KIFRUtils.h
//  KIFRecorder
//
//  Created by Morgan Pretty on 20/05/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDatePicker (KIFRUtils)

- (void)onAnimationFinishedPerformBlock:(void (^)(NSDate *newDate))onAnimationFinished;

@end

@interface NSObject (UIPickerTableView_KIFRUtils)

- (void)_scrollingFinished;
- (void)KIFR_scrollingFinished;

@end
