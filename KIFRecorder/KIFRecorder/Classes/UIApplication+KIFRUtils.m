//
//  KIFRecordingApplication.m
//  TSSales
//
//  Created by Morgan Pretty on 24/03/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import "UIApplication+KIFRUtils.h"
#import "UIWindow+KIFRUtils.h"
#import "KIFRTestEvent.h"
#import "KIFRTargetInfo.h"
#import "UITouch+KIFRUtils.h"
#import "KIFRMenuView.h"
#import "KIFRTest.h"
#import "KIFRAddVerificationStepUI.h"
#import "UIView+KIFRContent.h"
#import <objc/runtime.h>

@implementation UIApplication (KIFRUtils)

- (void)KIFR_sendEvent:(UIEvent *)event {
    // Don't let KIFR process events if we are proccessing a validation step
    if (![KIFRAddVerificationStepUI sharedInstance].isProcessingStep) {
        if (![KIFRMenuView sharedInstance].isExpanded && event.type == UIEventTypeTouches) {
            NSArray *touches = [[event allTouches] allObjects];
            KIFRTestEvent *testEvent;
            
            // Not all of the touches will have a 'view' property, loop through the event touches until you find one which does
            // Default to the firstObject on the off chance that none of the touches have a view
            UITouch *touch = touches.firstObject;
            NSString *touchID = [NSString stringWithFormat:@"%p", touch];
            for (UITouch *eventTouch in touches) {
                // Try to get the event from the currentEvents dictionary
                NSString *tmpTouchID = [NSString stringWithFormat:@"%p", eventTouch];
                testEvent = [KIFRTest currentTest].currentEvents[tmpTouchID];
                
                // If the touch has a view then update the variables
                if (eventTouch.view) {
                    touch = eventTouch;
                    touchID = tmpTouchID;
                }
                
                // If we already have an event then break from the loop
                if (testEvent) {
                    touch = eventTouch;
                    touchID = tmpTouchID;
                    break;
                }
            }
            
            // If we didn't find an existing event and it's in the 'Began' phase, add a new one
            if (!testEvent && touch.phase == UITouchPhaseBegan) {
                // Create the 'KIFRTestEvent' and pass it to the currentTest
                testEvent = [self createTestEventForEvent:event];
                
                // The testEvent will be nil if there isn't a valid UIElement to select
                if (testEvent) {
                    [[KIFRTest currentTest] addTestEvent:testEvent];
                }
            }
            else if (testEvent && touch.phase == UITouchPhaseEnded) {
                // Otherwise if the event ended, nil the 'targetView' and remove it from the currentEvents dictionary
                [testEvent endWithTouches:touches];
                [[KIFRTest currentTest] completeTestEvent:testEvent];
            }
        }
    }
    
    // Now that is all done, call the real 'sendEvent:'
    [self KIFR_sendEvent:event];
}

- (KIFRTestEvent *)createTestEventForEvent:(UIEvent *)event {
    NSArray *touches = [[event allTouches] allObjects];
    
    // Not all of the touches will have a 'view' property, loop through the event touches until you find one which does
    // Default to the firstObject on the off chance that none of the touches have a view
    UITouch *touch = touches.firstObject;
    for (UITouch *eventTouch in touches) {
        if (eventTouch.view) {
            touch = eventTouch;
            break;
        }
    }
    
    // Passing 'nil' to 'locationInView:' returns the location in the window
    CGPoint touchPoint = [touch locationInView:nil];
    NSArray *touchedViews = [self viewsBelowView:[UIWindow kifrWindow] withAccessibilityContainingPoint:touchPoint];
    NSArray *possibleViews = [touchedViews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.userInteractionEnabled == YES && SELF.accessibilityIdentifier.length > 0"]];
    
    // Ignore the Testing UI
    if ((!touch.view && possibleViews.count) || (touch.view && !touch.view.kifrShouldIgnore)) {
        // If we got a result
        if (possibleViews.count || touch.isKeyboardEvent) {
            // Get the relevant view
            NSString *touchID = [NSString stringWithFormat:@"%p", touch];
            UIView *touchedView = [touch accessibleViewWithPossibilities:possibleViews];
            
            // Store the event in the array
            KIFRTestEvent *testEvent = [KIFRTestEvent eventWithID:touchID touches:touches targetView:touchedView andAllTouchedViews:touchedViews];
            testEvent.eventState = KIFREventStateStarted;
            
            return testEvent;
        }
    }
    
    return nil;
}

- (NSString *)eventTypeToString:(KIFREventType)eventType {
    switch (eventType) {
        case KIFREventTypeNone:
            return @"EventTypeNone";
            
        case KIFREventTypeTap:
            return @"EventTypeTap";
            
        case KIFREventTypeLongPress:
            return @"EventTypeLongPress";
            
        case KIFREventTypePan:
            return @"EventTypePan";
            
        case KIFREventTypePinch:
            return @"EventTypePinch";
            
        case KIFREventTypeEnterText:
            return @"EventTypeEnterText";
            
        case KIFREventTypeSetValue:
            return @"EventTypeSetValue";
    }
}

#pragma mark - Recording Methods

- (NSArray *)viewsBelowView:(UIView *)view withAccessibilityContainingPoint:(CGPoint)point {
    NSMutableArray *mutableArray = [NSMutableArray new];
    
    for (UIView *subview in view.subviews) {
        // Check if the user can see the view
        if (!subview.hidden && subview.alpha > 0.01) {
            // Check if it contains the point
            CGPoint localPoint = [subview convertPoint:point fromView:view];
            if ([subview pointInside:localPoint withEvent:nil]) {
                // Only add the view if it isn't one of the classes the user shouldn't care about
                if (![[UIView viewClassesToIgnoreWhenRecording] containsObject:[subview class]]) {
                    [mutableArray addObject:subview];
                }
                
                NSArray *childViews = [self viewsBelowView:subview withAccessibilityContainingPoint:localPoint];
                [mutableArray addObjectsFromArray:childViews];
            }
        }
    }
    
    return mutableArray;
}

@end
