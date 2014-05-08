//
//  KIFRStepInfo.h
//  PTV
//
//  Created by Morgan Pretty on 28/03/2014.
//  Copyright (c) 2014 PTV. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    KIFREventTypeNone = -1,
    KIFREventTypeTap = 0,
    KIFREventTypeLongPress,
    KIFREventTypePan,
    KIFREventTypePinch,
    KIFREventTypeEnterText
} KIFREventType;

typedef enum {
    KIFREventStateNone = -1,
    KIFREventStateStarted = 0,
    KIFREventStateEnded
} KIFREventState;

typedef enum {
    KIFREventKeyNone = -1,
    KIFREventKeyDismissKeyboard = 0,
    KIFREventKeyDelete,
    KIFREventKeyReturn,
    KIFREventKeyOther
} KIFREventKey;

typedef enum {
    KIFRStepTypeUnknown = -1,
    KIFRStepTypeWait = 0,
    KIFRStepTypeTap,
    KIFRStepTypeMultiTap,
    KIFRStepTypeWaitForTableCell,
    KIFRStepTypeTapTableCell,
    KIFRStepTypeScroll,
    KIFRStepTypeEnterText,
    KIFRStepTypePinch,
    KIFRStepTypeKeyboardKey,
    KIFRStepTypeSelectSegment
} KIFRStepType;

@class KIFRTestEvent;

@interface KIFRTestStep : NSObject

@property (nonatomic, strong) KIFRTestEvent *testEventData;

@property (nonatomic, assign) KIFRStepType stepType;
@property (nonatomic, copy) NSString *readableString;
@property (nonatomic, copy) NSString *testString;
@property (nonatomic, assign) NSInteger originalIndex;

+ (KIFRTestStep *)stepFromTestEvent:(KIFRTestEvent *)testEvent;
+ (KIFRTestStep *)stepForStringStep:(NSString *)stepString withIndex:(NSInteger)index;
- (void)updateEnteredTextByAddingText:(NSString *)textToAdd;

@end
