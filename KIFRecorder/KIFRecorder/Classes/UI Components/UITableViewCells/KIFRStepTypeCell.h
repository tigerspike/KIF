//
//  StepTypeCell.h
//  PTV
//
//  Created by Morgan Pretty on 31/03/2014.
//  Copyright (c) 2014 PTV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KIFRTestStep.h"

@interface KIFRStepTypeCell : UITableViewCell

- (void)updateWithStepType:(KIFRStepType)stepType;
+ (CGFloat)cellHeight;

@end
