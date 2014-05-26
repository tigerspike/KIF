//
//  KIFRecordingWindow.m
//  TSSales
//
//  Created by Morgan Pretty on 19/03/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import "UIWindow+KIFRUtils.h"
#import "UIApplication+KIFRUtils.h"
#import "KIFRTestEvent.h"
#import "UIGestureRecognizer+KIFRUtils.h"
#import "KIFRTest.h"
#import "KIFRController.h"
#import <objc/runtime.h>

#pragma mark - KIFRecordingWindow

@implementation UIWindow (KIFRUtils)

static UIWindow *sharedInstance;

+ (UIWindow *)kifrWindow {
    return sharedInstance;
}

- (void)KIFR_makeKeyAndVisible {
    if (![UIWindow kifrWindow]) {
        sharedInstance = self;
        [self setupRecordingUI];
    }
    
    [self KIFR_makeKeyAndVisible];
}

- (void)setupRecordingUI {
    // Add the magic menu
    [self addSubview:[KIFRController sharedInstance]];
    
    // Setup Gesture Recognizers (These make identifying the type of event much easier)
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(windowLongTapped:)];
    longPressGestureRecognizer.delegate = self;
    [self addGestureRecognizer:longPressGestureRecognizer];
    
    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(windowSwiped:)];
    swipeGestureRecognizer.delegate = self;
    [self addGestureRecognizer:swipeGestureRecognizer];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(windowPanned:)];
    panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:panGestureRecognizer];
    
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(windowPinched:)];
    pinchGestureRecognizer.delegate = self;
    [self addGestureRecognizer:pinchGestureRecognizer];
}

- (void)KIFR_addSubview:(UIView *)subview {
    [self KIFR_addSubview:subview];
    [self bringSubviewToFront:[KIFRController sharedInstance]];
}

#pragma mark - Gesture Handlers

- (KIFRTestEvent *)eventForTouches:(NSArray *)touches {
    // At this point the event should be in the 'currentEvents' dictionary
    KIFRTestEvent *event;
    for (UITouch *touch in touches) {
        NSString *touchID = [NSString stringWithFormat:@"%p", touch];
        event = [KIFRTest currentTest].currentEvents[touchID];
        
        // Break out of the loop once we have found the touch
        if (event) {
            return event;
        }
    }
    
    return nil;
}

- (void)windowLongTapped:(UILongPressGestureRecognizer *)sender {
    // All we need to do here is update the 'eventType' to match the gesture type
    KIFRTestEvent *event = [self eventForTouches:sender.kifrTouches];
    if (event) {
        event.eventType = KIFREventTypeLongPress;
    }
}

- (void)windowSwiped:(UISwipeGestureRecognizer *)sender {
    NSLog(@"Swiped");
}

- (void)windowPanned:(UIPanGestureRecognizer *)sender {
    // All we need to do here is update the 'eventType' to match the gesture type
    KIFRTestEvent *event = [self eventForTouches:sender.kifrTouches];
    if (event) {
        event.eventType = KIFREventTypePan;
    }
}

- (void)windowPinched:(UIPinchGestureRecognizer *)sender {
    // All we need to do here is update the 'eventType' to match the gesture type
    KIFRTestEvent *event = [self eventForTouches:sender.kifrTouches];
    if (event) {
        event.eventType = KIFREventTypePinch;
    }
}

#pragma mark - UIGestureRecognizerDelegate Methods

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return [KIFRController sharedInstance].items.count;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

@end
