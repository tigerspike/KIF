//
//  KIFRAddVerificationStepUI.h
//  KIFRecorder
//
//  Created by Morgan Pretty on 19/05/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KIFRTestEvent;

@interface KIFRAddVerificationStepUI : NSObject

@property (nonatomic, assign) BOOL isAddingStep;
@property (nonatomic, assign) BOOL isProcessingStep;

+ (instancetype)sharedInstance;
- (void)show;
- (void)hideIfNeededForTouches:(NSArray *)touches;
- (void)addVerificationStepWithEvent:(KIFRTestEvent *)event;

@end
