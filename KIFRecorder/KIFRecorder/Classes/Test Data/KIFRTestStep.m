//
//  KIFRStepInfo.m
//  PTV
//
//  Created by Morgan Pretty on 28/03/2014.
//  Copyright (c) 2014 PTV. All rights reserved.
//

#import "KIFRTestStep.h"
#import "KIFRTestEvent.h"
#import "KIFRTestStep+ToString.h"
#import "KIFRTestStep+FromString.h"

@implementation KIFRTestStep

+ (KIFRTestStep *)stepFromTestEvent:(KIFRTestEvent *)testEvent {
    KIFRTestStep *step = [KIFRTestStep new];
    step.testEventData = testEvent;
    [step generateStepData];
    
    return step;
}

+ (KIFRTestStep *)stepForStringStep:(NSString *)stepString withIndex:(NSInteger)index {
    KIFRTestStep *step = [KIFRTestStep new];
    step.originalIndex = index;
    step.testString = stepString;
    [step generateStepDataFromString:stepString];
    
    return step;
}

- (void)updateEnteredTextByAddingText:(NSString *)textToAdd {
    // Append the string and re-generate the data
    self.testEventData.keyString = [NSString stringWithFormat:@"%@%@", self.testEventData.keyString, textToAdd];
    [self generateStepData];
}

@end
