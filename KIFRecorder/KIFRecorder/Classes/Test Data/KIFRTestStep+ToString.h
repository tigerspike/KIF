//
//  KIFRTestStep+ToString.h
//  PTV
//
//  Created by Morgan Pretty on 31/03/2014.
//  Copyright (c) 2014 PTV. All rights reserved.
//

#import "KIFRTestStep.h"

@interface KIFRTestStep (ToString)

- (void)generateStepData;
- (KIFRTestStep *)createActualTapStep;

@end
