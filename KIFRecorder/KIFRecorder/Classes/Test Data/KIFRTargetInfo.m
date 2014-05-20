//
//  KIFRTargetInfo.m
//  TSSales
//
//  Created by Morgan Pretty on 24/03/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import "KIFRTargetInfo.h"
#import "UIView+KIFRContent.h"

@implementation KIFRTargetInfo

+ (KIFRTargetInfo *)targetInfoForView:(UIView *)view {
    KIFRTargetInfo *targetInfo = [KIFRTargetInfo new];
    targetInfo.targetClass = [view class];
    targetInfo.accessibilityIdentifier = view.accessibilityIdentifier;
    targetInfo.frame = view.frame;
    targetInfo.numberOfSubviews = view.subviews.count;
    targetInfo.interactionEnabled = view.userInteractionEnabled;
    targetInfo.contentString = view.kifrContentString;
    
    // If we don't have an 'accessibilityIdentifier' then store the closest parent which does
    if (!view.accessibilityIdentifier) {
        UIView *tmpSuper = view.superview;
        while (tmpSuper) {
            if (tmpSuper.accessibilityIdentifier) {
                targetInfo.hasAccessibleParent = YES;
                targetInfo.firstAccessibleParentClass = [tmpSuper class];
                targetInfo.firstAccessibleParentAccessibilityIdentifier = tmpSuper.accessibilityIdentifier;
                break;
            }
            
            // Step up to the next super
            tmpSuper = tmpSuper.superview;
        }
    }
    
    return targetInfo;
}

- (BOOL)equalToView:(UIView *)view {
    BOOL frameEqual = CGRectEqualToRect(view.frame, self.frame);
    BOOL tableViewCellStuffEqual = YES;
    
    // A UITableViewCell has additional parameters
    if ([view isKindOfClass:[UITableViewCell class]]) {
// TODO - If we end up using this anywhere
    }
    
    return (frameEqual && tableViewCellStuffEqual && [view isKindOfClass:self.targetClass] && [view.accessibilityIdentifier isEqualToString:self.accessibilityIdentifier]);
}

@end
