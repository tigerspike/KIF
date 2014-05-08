//
//  KIFRTest.m
//  PTV
//
//  Created by Morgan Pretty on 31/03/2014.
//  Copyright (c) 2014 PTV. All rights reserved.
//

#import "KIFRTest.h"
#import "KIFRTestEvent.h"
#import "KIFRTestStep+ToString.h"
#import "KIFRTestStep+FromString.h"

@implementation KIFRTest

+ (KIFRTest *)currentTest {
    static KIFRTest *currentTest;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        currentTest = [KIFRTest new];
        currentTest.isCurrentBuild = YES;
    });
    
    return currentTest;
}

- (id)init {
    if ((self = [super init])) {
        _testName = @"Current Test";
        _lastModifiedDate = [NSDate date];
        _currentEvents = [NSMutableDictionary new];
        _testStepsArray = [NSMutableArray new];
    }
    
    return self;
}

- (id)initWithFileName:(NSString *)fileName {
    if ((self = [super init])) {
        NSString *docsDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSDictionary *fileAttrs = [[NSFileManager defaultManager] attributesOfItemAtPath:[NSString stringWithFormat:@"%@/%@", docsDir, fileName] error:nil];
        
        NSString *extension = @".kifr";
        _testName = [fileName substringToIndex:fileName.length - extension.length];
        _lastModifiedDate = fileAttrs[NSFileModificationDate];
        
        NSString *stepsString = [[NSString alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", docsDir, fileName] encoding:NSUTF8StringEncoding error:nil];
        _testStepsArray = [NSMutableArray new];
        
        NSInteger stepIndex = 0;
        NSString *stepStartString = @"    [tester ";
        NSArray *stepsArray = [stepsString componentsSeparatedByString:@"\n"];
        for (NSString *kifStep in stepsArray) {
            if (kifStep.length < stepStartString.length || ![[kifStep substringToIndex:stepStartString.length] isEqualToString:stepStartString]) {
                continue;
            }
            
            [_testStepsArray addObject:[KIFRTestStep stepForStringStep:kifStep withIndex:stepIndex]];
            ++stepIndex;
        }
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    KIFRTest *newTest = [[[self class] allocWithZone:zone] init];
    
    if (newTest) {
        newTest.testName = [self.testName copy];
        newTest.lastModifiedDate = [self.lastModifiedDate copy];
        newTest.currentEvents = [self.currentEvents mutableCopy];
        newTest.testStepsArray = [self.testStepsArray mutableCopy];
        newTest.isCurrentBuild = self.isCurrentBuild;
    }
    
    return newTest;
}

- (void)updateWithTest:(KIFRTest *)otherTest {
    self.testName = [otherTest.testName copy];
    self.lastModifiedDate = [otherTest.lastModifiedDate copy];
    self.currentEvents = [otherTest.currentEvents mutableCopy];
    self.testStepsArray = [otherTest.testStepsArray mutableCopy];
}

#pragma mark - KIFRTestEvent Management

- (void)addTestEvent:(KIFRTestEvent *)testEvent {
    [self.currentEvents setObject:testEvent forKey:testEvent.eventID];
    
//    // Sanity Check
//    if (testEvent) {
//        testEvent.eventState = KIFREventStateStarted;
//        
//        NSMutableString *touchList = [NSMutableString new];
//        for (UITouch *tmpTouch in touches) {
//            [touchList appendFormat:@"%p", tmpTouch];
//            
//            if (tmpTouch != touches.lastObject) {
//                [touchList appendString:@", "];
//            }
//        }
//        
//        NSLog(@"Added Event\nID: %@\nTouches: %@", touchID, touchList);
//    }
}

- (void)completeTestEvent:(KIFRTestEvent *)testEvent {
    [self.currentEvents removeObjectForKey:testEvent.eventID];
    
    switch (testEvent.eventType) {
        case KIFREventTypeEnterText: {
            // We want to combine 'EnterText' events here
            KIFRTestStep *previousStep = self.testStepsArray.lastObject;
            
            // If the previous event was also an 'EnterText' event then combine them (there is no point to enter each character individually)
            if (previousStep && previousStep.stepType == KIFRStepTypeEnterText && !testEvent.isActionKey) {
                [previousStep updateEnteredTextByAddingText:testEvent.keyString];
                return;
            }
        } break;
            
        case KIFREventTypeTap: {
            // Multi-tap gestures are recorded as different touches so each one would create a seperate event. This is here to remove the duplicates
            if (testEvent.numberOfTaps > 1) {
                KIFRTestStep *previousStep = self.testStepsArray.lastObject;
                
                // Sanity Check
                if (previousStep && previousStep.testEventData) {
                    NSTimeInterval intervalBetweenEvents = testEvent.eventStartTimeInterval - previousStep.testEventData.eventEndTimeInterval;
                    
                    // We assume the multi-tap gestures need the taps to be within 0.5 sec of each other
                    if (previousStep.testEventData.eventType == KIFREventTypeTap && intervalBetweenEvents < 0.5) {
                        [self.testStepsArray removeObject:previousStep];
                    }
                }
            }
        } break;
            
        default:
            break;
    }
    
    // Add the KIFRTestEvent as a KIFRTestStep
    [self addStepForTestEvent:testEvent];
}

- (void)addStepForTestEvent:(KIFRTestEvent *)testEvent {
    KIFRTestStep *testStep = [KIFRTestStep stepFromTestEvent:testEvent];
    testStep.originalIndex = self.testStepsArray.count;
    
    [self.testStepsArray addObject:testStep];
    
    // In this one case we need to create an additional step
    if (testStep.stepType == KIFRStepTypeWaitForTableCell) {
        KIFRTestStep *tapStep = [testStep createActualTapStep];
        tapStep.originalIndex = self.testStepsArray.count;
        
        [self.testStepsArray addObject:tapStep];
    }
}

#pragma mark - Saving

- (void)saveCurrentState {
    if (self.isCurrentBuild) {
        [[KIFRTest currentTest] updateWithTest:self];
        return;
    }
    
    NSMutableString *testString = [NSMutableString new];
    [testString appendString:@"\n\n"];
    if ([[self.testName substringToIndex:4] caseInsensitiveCompare:@"test"]) {
        [testString appendFormat:@"- (void)test%@ {", [self.testName substringFromIndex:4]];
    }
    else {
        [testString appendFormat:@"- (void)test%@ {", self.testName];
    }
    
    for (KIFRTestStep *step in self.testStepsArray) {
        [testString appendFormat:@"\n%@", step.testString];
        
        if (step.hasExtraLine) {
            [testString appendString:@"\n"];
        }
    }
    [testString appendString:@"\n}\n"];
    
    NSString *docsDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    [testString writeToFile:[NSString stringWithFormat:@"%@/%@.kifr", docsDir, self.testName] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

@end
