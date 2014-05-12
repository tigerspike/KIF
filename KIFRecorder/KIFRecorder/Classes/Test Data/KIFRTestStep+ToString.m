//
//  KIFRTestStep+ToString.m
//  PTV
//
//  Created by Morgan Pretty on 31/03/2014.
//  Copyright (c) 2014 PTV. All rights reserved.
//

#import "KIFRTestStep+ToString.h"
#import "KIFRTestEvent.h"

@implementation KIFRTestStep (ToString)

- (void)generateStepData {
    // We need the testEventData in order to generate the strings
    if (!self.testEventData) {
        return;
    }
    
    switch (self.testEventData.eventType) {
        case KIFREventTypeTap:
            [self generateTapStep];
            break;
            
        case KIFREventTypeLongPress:
            [self generateLongPressStep];
            break;
            
        case KIFREventTypePan:
            [self generatePanStep];
            break;
            
        case KIFREventTypePinch:
            [self generatePinchStep];
            break;
            
        case KIFREventTypeEnterText: {
            if (self.testEventData.isActionKey) {
                [self generateKeyboardKeyStep];
            }
            else {
                [self generateEnterTestStep];
            }
        } break;
            
        case KIFREventTypeNone:
            break;
    }
}

- (KIFRTestStep *)createActualTapStep {
    // Should only call this on a step which is waiting for a UITableViewCell
    if (!self.stepType == KIFRStepTypeWaitForTableCell) {
        return nil;
    }
    
    KIFRTestStep *step = [KIFRTestStep new];
    step.testEventData = self.testEventData;
    step.stepType = KIFRStepTypeTapTableCell;
    
    KIFRTargetInfo *targetInfo = self.testEventData.targetInfo;
    step.readableString = [NSString stringWithFormat:@"Tap cell at (%li, %li) in the table '%@'.", (long)targetInfo.cellIndexPath.row, (long)targetInfo.cellIndexPath.section, targetInfo.tableViewAccessibilityIdentifier];
    step.testString = [NSString stringWithFormat:@"\n    [tester tapRowAtIndexPath:[NSIndexPath indexPathForRow:%li inSection:%li] inTableViewWithAccessibilityIdentifier:@\"%@\"];\n", (long)targetInfo.cellIndexPath.row, (long)targetInfo.cellIndexPath.section, targetInfo.tableViewAccessibilityIdentifier];
    
    return step;
}

#pragma mark - Tap Step

- (void)generateTapStep {
    KIFRTargetInfo *targetInfo = self.testEventData.targetInfo;
    
    if (self.testEventData.numberOfTaps == 1) {
        // If it's a UITableViewCell then use the specific method
        if ([targetInfo.targetClass isSubclassOfClass:[UITableViewCell class]]) {
            self.stepType = KIFRStepTypeWaitForTableCell;
            self.readableString = [NSString stringWithFormat:@"Wait for cell at (%li, %li) in the table '%@'.", (long)targetInfo.cellIndexPath.row, (long)targetInfo.cellIndexPath.section, targetInfo.tableViewAccessibilityIdentifier];
            self.testString = [NSString stringWithFormat:@"\n    [tester waitForRowAtIndexPath:[NSIndexPath indexPathForRow:%li inSection:%li] inTableViewWithAccessibilityIdentifier:@\"%@\"];", (long)targetInfo.cellIndexPath.row, (long)targetInfo.cellIndexPath.section, targetInfo.tableViewAccessibilityIdentifier];
        }
        else if ([targetInfo.targetClass isSubclassOfClass:[UISegmentedControl class]]) {
            self.stepType = KIFRStepTypeSelectSegment;
            self.readableString = [NSString stringWithFormat:@"Tap segment %li in the segment control '%@'.", (long)targetInfo.selectedIndex, targetInfo.accessibilityIdentifier];
            self.testString = [NSString stringWithFormat:@"\n    [tester tapSegmentAtIndex:%li inSegmentedControlWithAccessibilityIdentifier:@\"%@\"];", (long)targetInfo.selectedIndex, targetInfo.accessibilityIdentifier];
        }
        else {
            self.stepType = KIFRStepTypeTap;
            self.readableString = [NSString stringWithFormat:@"Tap on view '%@'.", targetInfo.accessibilityIdentifier];
            self.testString = [NSString stringWithFormat:@"\n    [tester tapViewWithAccessibilityIdentifier:@\"%@\"];", targetInfo.accessibilityIdentifier];
        }
    }
    else {
        self.stepType = KIFRStepTypeMultiTap;

        NSArray *tapNumberStrings = @[ @"", @"", @"Double ", @"Triple ", @"Multi (4+) " ];
        NSString *tapAmount = tapNumberStrings[MIN(self.testEventData.numberOfTaps, 4)];
        self.readableString = [NSString stringWithFormat:@"%@Tap on view '%@'.", tapAmount, targetInfo.accessibilityIdentifier];
        self.testString = [NSString stringWithFormat:@"\n    [tester multiTapViewWithAccessibilityIdentifier:@\"%@\" andNumberOfTaps:%lu];", targetInfo.accessibilityIdentifier, (unsigned long)self.testEventData.numberOfTaps];
    }
}

#pragma mark - Long Press Step

- (void)generateLongPressStep {
    //    [stepString appendString:[NSString stringWithFormat:@"\n    [tester longPressViewWithAccessibilityIdentifier:@\"%@\" duration:%.2f];", self.targetInfo.identifier, (self.eventEndTimeInterval - self.eventStartTimeInterval)]];
    
    self.stepType = KIFRStepTypeUnknown;
    self.readableString = @"Unknown Step";
}

#pragma mark - Pan Step

- (void)generatePanStep {
    KIFRTargetInfo *targetInfo = self.testEventData.targetInfo;
    
    // Single finger pan
    if (self.testEventData.startPoints.count == 1) {
        self.stepType = KIFRStepTypeScroll;
        
        CGPoint startPoint = [self.testEventData.startPoints[0] CGPointValue];
        CGPoint endPoint = [self.testEventData.endPoints[0] CGPointValue];
        
        CGFloat xDistance = endPoint.x - startPoint.x;
        CGFloat yDistance = endPoint.y - startPoint.y;
        CGFloat horizontalFraction = (xDistance / targetInfo.frame.size.width);
        CGFloat verticalFraction = (yDistance / targetInfo.frame.size.height);
        
        self.readableString = [NSString stringWithFormat:@"Scroll view '%@' by %.0f%% width and %.0f%% height.", targetInfo.accessibilityIdentifier, (horizontalFraction * 100), (verticalFraction * 100)];
        self.testString = [NSString stringWithFormat:@"\n    [tester scrollViewWithAccessibilityIdentifier:@\"%@\" byFractionOfSizeHorizontal:%f vertical:%f];", targetInfo.accessibilityIdentifier, horizontalFraction, verticalFraction];
    }
    else {
        NSLog(@"Warning - Attempt to have unsupported multi-finger pan!");
    }
}

#pragma mark - Pinch Step

- (void)generatePinchStep {
    KIFRTargetInfo *targetInfo = self.testEventData.targetInfo;
    
    // iOS only supports a two finger pinch so this is just a sanity check
    if (self.testEventData.startPoints.count == 2) {
        CGPoint startPoint1 = [self.testEventData.startPoints[0] CGPointValue];
        CGPoint startPoint2 = [self.testEventData.startPoints[1] CGPointValue];
        CGPoint endPoint1 = [self.testEventData.endPoints[0] CGPointValue];
        CGPoint endPoint2 = [self.testEventData.endPoints[1] CGPointValue];
        
        // Convert the points to relative ones (so the test could potentially work for different screen sizes)
        CGPoint relativeStartPoint1 = CGPointMake(startPoint1.x / targetInfo.frame.size.width, startPoint1.y / targetInfo.frame.size.height);
        CGPoint relativeStartPoint2 = CGPointMake(startPoint2.x / targetInfo.frame.size.width, startPoint2.y / targetInfo.frame.size.height);
        CGPoint relativeEndPoint1 = CGPointMake(endPoint1.x / targetInfo.frame.size.width, endPoint1.y / targetInfo.frame.size.height);
        CGPoint relativeEndPoint2 = CGPointMake(endPoint2.x / targetInfo.frame.size.width, endPoint2.y / targetInfo.frame.size.height);
        
        self.stepType = KIFRStepTypePinch;
        self.readableString = [NSString stringWithFormat:@"Pinch view '%@' from [(%.0f%%, %.0f%%), (%.0f%%, %.0f%%)] to [(%.0f%%, %.0f%%), (%.0f%%, %.0f%%)].", targetInfo.accessibilityIdentifier, (relativeStartPoint1.x * 100), (relativeStartPoint1.y * 100), (relativeStartPoint2.x * 100), (relativeStartPoint2.y * 100), (relativeEndPoint1.x * 100), (relativeEndPoint1.y * 100), (relativeEndPoint2.x * 100), (relativeEndPoint2.y * 100)];
        self.testString = [NSString stringWithFormat:@"\n    [tester pinchViewWithAccessibilityIdentifier:@\"%@\" atRelativeStartPoints:@[ %@, %@ ] andRelativeEndPoints:@[ %@, %@ ]];", targetInfo.accessibilityIdentifier, [self valueStringForCGPoint:relativeStartPoint1], [self valueStringForCGPoint:relativeStartPoint2], [self valueStringForCGPoint:relativeEndPoint1], [self valueStringForCGPoint:relativeEndPoint2]];
    }
}

- (NSString *)valueStringForCGPoint:(CGPoint)point {
    return [NSString stringWithFormat:@"[NSValue valueWithCGPoint:CGPointMake(%f, %f)]", point.x, point.y];
}

#pragma mark - Enter Text Step

// Note: This method doesn't handle entering standard characters, that is still handled in the 'UIWindow+KIFRUtils' category
- (void)generateKeyboardKeyStep {
    if (!self.testEventData.isActionKey) {
        return;
    }
    
    self.stepType = KIFRStepTypeKeyboardKey;
        
    // The only special key we should need to handle is the 'Dismiss' key (iPad keyboard - it's accessibility identifier is actually 'Hide keyboard' for some reason)
    switch (self.testEventData.eventKey) {
        case KIFREventKeyDismissKeyboard: {
            self.readableString = @"Press dismiss keyboard key.";
            
            // For some reason we need to call this twice or it doesn't work
            NSString *dismissKeyboardString = @"\n\n    // For some reason we need to call this twice or it doesn't work\n    [tester tapViewWithAccessibilityIdentifier:@\"Hide keyboard\"\n    [tester tapViewWithAccessibilityIdentifier:@\"Hide keyboard\"];";
            self.testString = dismissKeyboardString;
        } break;
            
        case KIFREventKeyDelete: {
            self.readableString = @"Press keyboard delete key.";
            
            // The delete key only needs to be pressed once (unlike the 'undo' or 'dimiss' keys)
            self.testString = [NSString stringWithFormat:@"\n    [tester tapViewWithAccessibilityIdentifier:@\"%@\"];", self.testEventData.keyString];
        } break;
            
        case KIFREventKeyOther: {
            self.readableString = [NSString stringWithFormat:@"Press keyboard '%@' key.", self.testEventData.keyString];
            
            NSString *otherKeyString = [NSString stringWithFormat:@"\n\n    // For some reason we need to call this twice or it doesn't work"@"\n    [tester tapViewWithAccessibilityIdentifier:@\"%@\"];\n    [tester tapViewWithAccessibilityIdentifier:@\"%@\"];", self.testEventData.keyString, self.testEventData.keyString];
            self.testString = otherKeyString;
        } break;
            
        case KIFREventKeyReturn: {
            self.readableString = [NSString stringWithFormat:@"Press keyboard '%@' key.", self.testEventData.keyString];
            
            // The delete key only needs to be pressed once (unlike the 'undo' or 'dimiss' keys)
            self.testString = [NSString stringWithFormat:@"\n    [tester tapViewWithAccessibilityIdentifier:@\"%@\"];", self.testEventData.keyString];
        } break;
            
        default: {
            // Ignore any other key but log it in case
            self.readableString = @"Press unknown keyboard key.";
            self.stepType = KIFRStepTypeUnknown;
        } break;
    }
}

- (void)generateEnterTestStep {
    self.stepType = KIFRStepTypeEnterText;
    self.readableString = [NSString stringWithFormat:@"Enter text '%@' in to selected field.", self.testEventData.keyString];
    self.testString = [NSString stringWithFormat:@"\n    [tester enterTextIntoCurrentFirstResponder:@\"%@\"];\n", self.testEventData.keyString];
}

@end
