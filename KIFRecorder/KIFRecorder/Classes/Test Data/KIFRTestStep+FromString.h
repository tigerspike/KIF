//
//  KIFRTestStep+FromString.h
//  PTV
//
//  Created by Morgan Pretty on 31/03/2014.
//  Copyright (c) 2014 PTV. All rights reserved.
//

#import "KIFRTestStep.h"

@interface KIFRTestStep (FromString)

@property (nonatomic, readonly) BOOL hasExtraLine;

- (void)generateStepDataFromString:(NSString *)stepString;

@end
