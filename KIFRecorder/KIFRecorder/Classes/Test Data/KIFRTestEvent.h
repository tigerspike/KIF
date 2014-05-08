//
//  KIFRTestEvent.h
//  TSSales
//
//  Created by Morgan Pretty on 24/03/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KIFRTargetInfo.h"
#import "KIFRTestStep.h"

@interface KIFRTestEvent : NSObject

@property (nonatomic, copy) NSString *eventID;
@property (nonatomic, weak) UIView *targetView;
@property (nonatomic, strong) NSArray *potentialTargets;

@property (nonatomic, strong) KIFRTargetInfo *targetInfo;
@property (nonatomic, strong) NSArray *potentialTargetInfo;
@property (nonatomic, assign) KIFREventType eventType;
@property (nonatomic, assign) KIFREventState eventState;
@property (nonatomic, assign) NSUInteger numberOfTaps;

@property (nonatomic, assign) double eventStartTimeInterval;
@property (nonatomic, assign) double eventEndTimeInterval;

// Keyboard event stuff
@property (nonatomic, assign) BOOL isKeyboardEvent;
@property (nonatomic, assign) BOOL isActionKey;
@property (nonatomic, assign) CGRect keyboardKeyFrame;
@property (nonatomic, copy) NSString *keyString;
@property (nonatomic, assign) KIFREventKey eventKey;

// Since we want to support multi-touch gestures, the start and end points need to be arrays
@property (nonatomic, strong) NSArray *startPoints;
@property (nonatomic, strong) NSArray *endPoints;

+ (KIFRTestEvent *)eventWithID:(NSString *)eventID touches:(NSArray *)touches targetView:(UIView *)target andPotentialTargets:(NSArray *)potentialTargets;

- (void)endWithTouches:(NSArray *)touches;

@end
