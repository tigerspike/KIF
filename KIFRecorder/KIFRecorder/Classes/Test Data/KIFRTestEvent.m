//
//  KIFRTestEvent.m
//  TSSales
//
//  Created by Morgan Pretty on 24/03/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import "KIFRTestEvent.h"
#import "KIFRBorderView.h"
#import "UITouch+KIFRUtils.h"
#import "UIView+KIFRContent.h"
#import "UIDatePicker+KIFRUtils.h"
#import "KIFRTestStep+ToString.h"
#import <objc/runtime.h>

@implementation KIFRTestEvent

+ (NSArray *)classesWithInternalViews {
    return @[
             [UITableViewCell class],
             [UISearchBar class],
             NSClassFromString(@"MKMapView")
             ];
}

+ (KIFRTestEvent *)eventWithID:(NSString *)eventID touches:(NSArray *)touches targetView:(UIView *)target andAllTouchedViews:(NSArray *)allTouchedViews {
    KIFRTestEvent *testEvent = [KIFRTestEvent new];
    testEvent.eventID = eventID;
    testEvent.targetView = target;
    testEvent.targetInfo = [KIFRTargetInfo targetInfoForView:target];
    testEvent.eventType = KIFREventTypeTap;
    testEvent.eventState = KIFREventStateNone;
    testEvent.eventStartTimeInterval = [[NSDate date] timeIntervalSince1970];
    testEvent.eventKey = KIFREventKeyNone;
    
    // Get the targetInfo for each potentialView
    testEvent.allTouchedViews = allTouchedViews;
    NSMutableArray *touchedViewInfoArray = [NSMutableArray arrayWithCapacity:allTouchedViews.count];
    for (UIView *view in allTouchedViews) {
        KIFRTargetInfo *viewInfo = [KIFRTargetInfo targetInfoForView:view];
        [touchedViewInfoArray addObject:viewInfo];
    }
    testEvent.touchedViewsInfo = touchedViewInfoArray;
    
    // Set the touch details
    if (touches.count == 1) {
        UITouch *touch = touches[0];
        testEvent.startPoints = @[ [NSValue valueWithCGPoint:[touch recordedLocationInView:target]] ];
        testEvent.isKeyboardEvent = touch.isKeyboardEvent;
        
        if (testEvent.isKeyboardEvent) {
            testEvent.eventType = KIFREventTypeEnterText;
            [testEvent updateKeyboardValuesForTouch:touch];
        }
    }
    else {
        // Don't allow multi-touch on the keyboard - the recorder is just messing with you...
        NSMutableArray *mutableStartTouches = [NSMutableArray arrayWithCapacity:touches.count];
        for (UITouch *touch in touches) {
            [mutableStartTouches addObject:[NSValue valueWithCGPoint:[touch recordedLocationInView:target]]];
        }
        testEvent.startPoints = mutableStartTouches;
    }
    
    // Create the border view
    [KIFRBorderView createBorderForEvent:testEvent];
    
    return testEvent;
}

- (void)endWithTouches:(NSArray *)touches {
    // Set the touch details
    if (touches.count == 1) {
        UITouch *touch = touches[0];
        self.numberOfTaps = touch.tapCount;
        self.endPoints = @[ [NSValue valueWithCGPoint:[touch recordedLocationInView:self.targetView]] ];
    }
    else {
        // Don't allow multi-touch on the keyboard - the recorder is just messing with you...
        NSUInteger tapCount = 0;
        BOOL allEndPointsAreZero = YES;
        NSMutableArray *mutableEndTouches = [NSMutableArray arrayWithCapacity:touches.count];
        for (UITouch *touch in touches) {
            [mutableEndTouches addObject:[NSValue valueWithCGPoint:[touch recordedLocationInView:self.targetView]]];
            
            if (!CGPointEqualToPoint([mutableEndTouches.lastObject CGPointValue], CGPointZero)) {
                allEndPointsAreZero = NO;
            }
            
            // Lets go with the max tap count for now and fix this if it causes issues later
            if (touch.tapCount > tapCount) {
                tapCount = touch.tapCount;
            }
        }
        
        self.numberOfTaps = tapCount;
        self.endPoints = mutableEndTouches;
    }
    
    // If the targetView is a UITableViewCell then we want to get it's indexPath
    if ([self.targetView isKindOfClass:[UITableViewCell class]]) {
        [self finalizeUITableViewCellWithTouches:touches];
    }
    else if ([self.targetView isKindOfClass:[UISegmentedControl class]]) {
        [self finalizeUISegmentedControlWithTouches:touches];
    }
    else if ([self.targetView isKindOfClass:[UIDatePicker class]]) {
        [self finalizeDatePickerWithTouches:touches];
    }
    
    // Check if we tapped an 'internal view' (a control which we don't have direct access to)
    if ([[KIFRTestEvent classesWithInternalViews] containsObject:self.targetInfo.targetClass]) {
        // Are we tapping an internal view inside the TableViewCell?
        UITouch *touch = touches.firstObject;
        for (UITouch *eventTouch in touches) {
            if (eventTouch.view) {
                touch = eventTouch;
                break;
            }
        }
        
        // If the touch's view is not the same as the targetClass (then it's probably an internal view)
        if (![[UIView viewClassesToIgnoreWhenRecording] containsObject:[touch.view class]] && ![touch.view isKindOfClass:self.targetInfo.targetClass]) {
            self.targetInfo.isTargettingInternalSubview = YES;
            self.internalTargetView = touch.view;
            self.targetInfo.internalTargetClass = [touch.view class];
            
            // If we have a touchedViewInfo which matches the above details then set the 'contentString' to match (so the step records correctly)
            for (KIFRTargetInfo *info in self.touchedViewsInfo) {
                if (info.targetClass == [touch.view class] && info.contentString) {
                    self.targetInfo.contentString = info.contentString;
                    break;
                }
            }
        }
    }
    
    // We don't want to keep hanging on the the 'targetView' or 'potentialTargets' references (to avoid memory issues, also the red 'BorderView' will only disappear once this value has been cleared)
    self.targetView = nil;
    self.allTouchedViews = nil;
    self.eventState = KIFREventStateEnded;
    self.eventEndTimeInterval = [[NSDate date] timeIntervalSince1970];
}

#pragma mark - Specific UIElement Type Methods

- (void)finalizeUITableViewCellWithTouches:(NSArray *)touches {
    UITableViewCell *cell = (UITableViewCell *)self.targetView;
    
    // The UITableView should be a superview of the cell somewhere so look until you find it
    UITableView *tableView = (UITableView *)cell.superview;
    while (tableView && ![tableView isKindOfClass:[UITableView class]]) {
        tableView = (UITableView *)tableView.superview;
    }
    
    // Sanity Check
    if (tableView) {
        NSIndexPath *cellIndexPath = [tableView indexPathForCell:cell];
        self.targetInfo.cellIndexPath = cellIndexPath;
        self.targetInfo.tableViewAccessibilityIdentifier = tableView.accessibilityIdentifier;
    }
}

- (void)finalizeUISegmentedControlWithTouches:(NSArray *)touches {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)self.targetView;
    UITouch *touch = touches.firstObject;
    
    // I don't like this but it seem like it's the only way to get the index of the segment
    NSInteger segmentIndex = 0;
    for (UIView *subview in segmentedControl.subviews) {
        CGPoint localPoint = [touch locationInView:subview];
        
        if ([subview pointInside:localPoint withEvent:nil]) {
            segmentIndex = segmentedControl.subviews.count - [segmentedControl.subviews indexOfObject:subview] - 1;
        }
    }
    
    self.targetInfo.selectedIndex = segmentIndex;
}

- (void)finalizeDatePickerWithTouches:(NSArray *)touches {
    // Set the date to the UIDatePicker's date
    UIDatePicker *datePicker = (UIDatePicker *)self.targetView;
    self.eventType = KIFREventTypeSetValue;
    self.targetInfo.targetDate = datePicker.date;
    
    // Add an 'onAnimationFinished' block so we can get the new date value
    datePicker.userInteractionEnabled = NO;
    [datePicker onAnimationFinishedPerformBlock:^(NSDate *newDate) {
        self.targetInfo.targetDate = newDate;
        datePicker.userInteractionEnabled = YES;
        
        // If we have set the 'testStep' then this event has been marked as complete, so update the data
        if (self.testStep) {
            [self.testStep generateStepData];
        }
    }];
}

#pragma mark - Crazy Keyboard Methods

- (void)updateKeyboardValuesForTouch:(UITouch *)touch {
    if (!touch.isKeyboardEvent) {
        return;
    }
    
    // Each key on the keyboard does not have its own view, so we have to ask for the list of keys,
    // find the appropriate one, and tap inside the frame of that key on the main keyboard view.
    UIWindow *keyboardWindow = touch.view.window;
    UIView *keyboardView = [[self subviewsWithClassNamePrefix:@"UIKBKeyplaneView" inView:keyboardWindow] lastObject];
    
    // If we didn't find the standard keyboard view, then we may have a custom keyboard
    if (!keyboardView) {
        NSLog(@"OH NOES!");
        return;
    }
    
    CGPoint keyboardPoint = [touch locationInView:keyboardView];
    id /*UIKBKeyplane*/ keyplane = [keyboardView valueForKey:@"keyplane"];
    NSArray *keys = [keyplane valueForKey:@"keys"];
    
    for (id/*UIKBKey*/ key in keys) {
        CGRect keyFrame = [key frame];
        NSString *representedString = [key valueForKey:@"representedString"];
        
        if (CGRectContainsPoint(keyFrame, keyboardPoint)) {
            // Determine if it is an 'action' key (if it is we won't enter text but will just tap at that location instead)
            BOOL isReturnKey = [representedString isEqualToString:@"\n"];
            if (representedString.length > 1 || isReturnKey) {
                self.isActionKey = YES;
            }
            
            self.keyboardKeyFrame = keyFrame;
            self.keyString = representedString;
            [self setKeyTypeForString:representedString];
            
            // For the return key get the 'displayString' (It should be something alog the lines of 'Search' and we want the lowercaseString because it won't respond when KIF attempts to tap it)
            if (isReturnKey) {
                self.keyString = [[key valueForKey:@"displayString"] lowercaseString];
            }
            
            break;
        }
    }
}

// Note: This is taken from KIF's 'UIView-KIFAdditions.h. category
- (NSArray *)subviewsWithClassNamePrefix:(NSString *)prefix inView:(UIView *)targetView {
    NSMutableArray *result = [NSMutableArray array];
    
    // Breadth-first population of matching subviews
    // First traverse the next level of subviews, adding matches.
    for (UIView *view in targetView.subviews) {
        if ([NSStringFromClass([view class]) hasPrefix:prefix]) {
            [result addObject:view];
        }
    }
    
    // Now traverse the subviews of the subviews, adding matches.
    for (UIView *view in targetView.subviews) {
        NSArray *matchingSubviews = [self subviewsWithClassNamePrefix:prefix inView:view];
        [result addObjectsFromArray:matchingSubviews];
    }
    
    return result;
}

- (void)setKeyTypeForString:(NSString *)keyName {
    NSArray *keyboardKeysToInclude = @[ @"undo" ];
    
    if ([keyName isEqualToString:@"Dismiss"]) {
        self.eventKey = KIFREventKeyDismissKeyboard;
    }
    else if ([keyName isEqualToString:@"Delete"]) {
        self.eventKey = KIFREventKeyDelete;
    }
    else if ([keyName isEqualToString:@"\n"]) {
        self.eventKey = KIFREventKeyReturn;
    }
    else if ([keyboardKeysToInclude containsObject:keyName]) {
        self.eventKey = KIFREventKeyOther;
    }
}

@end
