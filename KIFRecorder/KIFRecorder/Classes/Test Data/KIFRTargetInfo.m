//
//  KIFRTargetInfo.m
//  TSSales
//
//  Created by Morgan Pretty on 24/03/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import "KIFRTargetInfo.h"

@implementation KIFRTargetInfo

+ (KIFRTargetInfo *)targetInfoForView:(UIView *)view {
    KIFRTargetInfo *targetInfo = [KIFRTargetInfo new];
    targetInfo.targetClass = [view class];
    targetInfo.accessibilityLabel = view.accessibilityLabel;
    targetInfo.accessibilityIdentifier = view.accessibilityIdentifier;
    targetInfo.frame = view.frame;
    
    return targetInfo;
}

- (BOOL)equalToView:(UIView *)view {
    BOOL frameEqual = CGRectEqualToRect(view.frame, self.frame);
    BOOL tableViewCellStuffEqual = YES;
    
    // A UITableViewCell has additional parameters
    if ([view isKindOfClass:[UITableViewCell class]]) {
// TODO - If we end up using this anywhere
    }
    
    return (frameEqual && tableViewCellStuffEqual && [view isKindOfClass:self.targetClass] && [view.accessibilityIdentifier isEqualToString:self.accessibilityIdentifier] && [view.accessibilityLabel isEqualToString:self.accessibilityLabel]);
}

- (NSString *)identifier {
    if (self.accessibilityLabel.length > 0) {
        return self.accessibilityLabel;
    }
    
    return self.accessibilityIdentifier;
}

@end
