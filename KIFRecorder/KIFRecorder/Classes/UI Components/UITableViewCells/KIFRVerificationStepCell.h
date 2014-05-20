//
//  KIFRVerificationStepCell.h
//  KIFRecorder
//
//  Created by Morgan Pretty on 19/05/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KIFRTargetInfo;

@interface KIFRVerificationStepCell : UITableViewCell

- (void)updateWithTargetInfo:(KIFRTargetInfo *)targetInfo;
+ (CGFloat)cellHeight;

@end
