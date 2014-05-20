//
//  KIFRTest.h
//  PTV
//
//  Created by Morgan Pretty on 31/03/2014.
//  Copyright (c) 2014 PTV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KIFRTestEvent.h"

@interface KIFRTest : NSObject

@property (nonatomic, copy) NSString *testName;
@property (nonatomic, strong) NSDate *lastModifiedDate;
@property (nonatomic, strong) NSMutableDictionary *currentEvents;
@property (nonatomic, strong) NSMutableArray *testStepsArray;
@property (nonatomic, assign) BOOL isCurrentBuild;

+ (KIFRTest *)currentTest;
- (id)initWithFileName:(NSString *)fileName;
- (void)updateWithTest:(KIFRTest *)otherTest;

- (void)addTestEvent:(KIFRTestEvent *)testEvent;
- (void)completeTestEvent:(KIFRTestEvent *)testEvent;
- (void)addStepForTestEvent:(KIFRTestEvent *)testEvent;
- (void)addVerificationStep:(KIFRVerificationType)verificationType forTargetInfo:(KIFRTargetInfo *)targetInfo;
- (void)saveCurrentState;

@end
