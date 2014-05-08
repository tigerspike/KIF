//
//  KIFRWaitStepCell.h
//  PTV
//
//  Created by Morgan Pretty on 31/03/2014.
//  Copyright (c) 2014 PTV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KIFRWaitStepCell : UITableViewCell

- (void)updateWithWaitTime:(CGFloat)waitTime;
+ (CGFloat)cellHeight;

@end
