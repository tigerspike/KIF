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
#import "UIAlertView+KIFRUtils.h"
#import "KIFRMenuView.h"
#import "KIFRTest.h"
#import "KIFRTestStep.h"
#import "UIGestureRecognizer+KIFRUtils.h"
#import <objc/runtime.h>

@implementation UIApplication (KIFRUtils)

- (void)setupRecording {
    [self swizzleApp];
}

#pragma mark - Swizzle Methods

static inline void Swizzle(Class c, SEL orig, SEL new) {
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, new);
    if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_exchangeImplementations(origMethod, newMethod);
}

- (void)swizzleApp {
    // We need to swizzle the below methods in order to record the user's actions correctly and stop the recorder for doing things which we don't currently support (ie. flinging)
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Swizzle([UIPinchGestureRecognizer class], @selector(touchesBegan:withEvent:), @selector(KIFR_touchesBegan:withEvent:));
        Swizzle([UIPinchGestureRecognizer class], @selector(velocity), @selector(KIFR_velocity));
        Swizzle([UIPanGestureRecognizer class], @selector(velocityInView:), @selector(KIFR_velocityInView:));
        
        // We will need to add the recording wrapper to the Window
        Swizzle([UIWindow class], @selector(makeKeyAndVisible), @selector(KIFR_makeKeyAndVisible));
        
        // Intercept UIApplication's 'sendEvent:' method
        Swizzle([UIApplication class], @selector(sendEvent:), @selector(KIFR_sendEvent:));
    });
}

#pragma mark - TestEvent Data Management Methods

- (NSArray *)getSavedTests {
    NSString *docsDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:docsDir error:nil];
    NSArray *kifrTests = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.kifr'"]];
    
    NSMutableArray *existingTestArray = [NSMutableArray arrayWithCapacity:kifrTests.count];
    for (NSString *testFileName in kifrTests) {
        [existingTestArray addObject:[[KIFRTest alloc] initWithFileName:testFileName]];
    }
    
    return existingTestArray;
}

- (void)exportTests {
    __weak UIApplication *weakSelf = self;
    [UIAlertView showWithTitle:@"Export Test" message:@"What would you like to call the test?" cancelButtonTitle:@"Cancel" otherButtonTitles:@[ @"Export" ] style:UIAlertViewStylePlainTextInput andCallback:^(UIAlertView *alertView, NSInteger selectedButtonIndex) {
        UIApplication *strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        if (selectedButtonIndex == 1) {
            UITextField *textField = [alertView textFieldAtIndex:0];
            
            if (textField.text.length == 0) {
                // If there is no test name, throw and error and try again
                [UIAlertView showWithTitle:@"Error" message:@"Please enter a name for the test" cancelButtonTitle:@"OK" otherButtonTitles:nil andCallback:^(UIAlertView *alertView, NSInteger selectedButtonIndex) {
                    UIApplication *strongSelf = weakSelf;
                    if (!strongSelf) {
                        return;
                    }
                    
                    [strongSelf exportTests];
                }];
            }
            else {
                // Otherwise export the test
                [strongSelf exportTestWithName:textField.text canReplaceOldTest:NO];
            }
        }
    }];
}

- (void)exportTestWithName:(NSString *)testName canReplaceOldTest:(BOOL)canReplaceOldTest {
    // Make the test name acceptable
    NSString *capitalizedFirstCharacter = [[NSString stringWithFormat:@"%c", [testName characterAtIndex:0]] uppercaseString];
    testName = [NSString stringWithFormat:@"%@%@", capitalizedFirstCharacter, [testName substringFromIndex:1]];
    testName = [testName stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // If there is already a test with that name, Throw an alert
    __weak UIApplication *weakSelf = self;
    NSString *docsDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    if (!canReplaceOldTest && [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", docsDir, testName]]) {
        [UIAlertView showWithTitle:@"Error" message:@"A test with that name already exists! Please choose another name." cancelButtonTitle:@"OK" otherButtonTitles:nil andCallback:^(UIAlertView *alertView, NSInteger selectedButtonIndex) {
            UIApplication *strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            
            [strongSelf exportTests];
        }];
        
        return;
    }
    
    // Generate the new test method (Note: Method name MUST start with 'test')
    NSMutableString *testString = [NSMutableString new];
    [testString appendString:@"\n\n"];
    if ([[testName substringToIndex:4] caseInsensitiveCompare:@"test"]) {
        [testString appendFormat:@"- (void)test%@ {", [testName substringFromIndex:4]];
    }
    else {
        [testString appendFormat:@"- (void)test%@ {", testName];
    }
    
    for (KIFRTestStep *step in [KIFRTest currentTest].testStepsArray) {
        if (step.stepType == KIFRStepTypeUnknown) {
            NSLog(@"Warning! Attempted to export a recorded action with no export logic!");
            continue;
        }
        
        [testString appendString:step.testString];
    }
    
    [testString appendString:@"\n    [tester waitForTimeInterval:0.5];"];
    [testString appendString:@"\n}\n"];
    
    // Log and save the test to a file
    NSLog(@"%@", testString);
    
    [testString writeToFile:[NSString stringWithFormat:@"%@/%@.kifr", docsDir, testName] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    // Giev the tester feedback that exporting succeeded
    [UIAlertView showWithTitle:@"Export Successful" message:[NSString stringWithFormat:@"Test saved as '%@'", testName] cancelButtonTitle:@"OK" otherButtonTitles:nil andCallback:nil];
}

#pragma mark - Catching Events

- (void)KIFR_sendEvent:(UIEvent *)event {
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
    NSArray *possibleViews = [self viewsBelowView:[UIWindow kifrWindow] withAccessibilityContainingPoint:touchPoint];
    
    // Ignore the Testing UI
    if ((!touch.view && possibleViews.count) || (touch.view && !touch.view.kifrShouldIgnore)) {
        // If we got a result
        if (possibleViews.count || touch.isKeyboardEvent) {
            // Get the relevant view
            NSString *touchID = [NSString stringWithFormat:@"%p", touch];
            UIView *touchedView = [touch accessibleViewWithPossibilities:possibleViews];
            
            // Store the event in the array
            KIFRTestEvent *testEvent = [KIFRTestEvent eventWithID:touchID touches:touches targetView:touchedView andPotentialTargets:possibleViews];
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
    }
}

#pragma mark - Recording Methods

- (NSArray *)viewsBelowView:(UIView *)view withAccessibilityContainingPoint:(CGPoint)point {
    NSMutableArray *mutableArray = [NSMutableArray new];
    
    for (UIView *subview in view.subviews) {
        // Check if the user can interact with the view
        if (!subview.hidden && subview.userInteractionEnabled && subview.alpha > 0.01) {
            // Check if it contains the point
            CGPoint localPoint = [subview convertPoint:point fromView:view];
            if ([subview pointInside:localPoint withEvent:nil]) {
                // Only add this view if it has accessibility info (currently needed for testing)
                if (subview.accessibilityIdentifier.length > 0 || subview.accessibilityLabel.length > 0) {
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
