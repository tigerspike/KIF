//
//  UICollectionViewLayoutAttributes+KIFRUtils.m
//  KIFRecorder
//
//  Created by Morgan Pretty on 26/05/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import "UICollectionViewLayoutAttributes+KIFRUtils.h"
#import <objc/runtime.h>

#define kLayoutAttributeIsBackButton @"LayoutAttributeIsBackButton"

@implementation UICollectionViewLayoutAttributes (KIFRUtils)

- (void)setIsBackButton:(BOOL)isBackButton {
    objc_setAssociatedObject(self, kLayoutAttributeIsBackButton, @(isBackButton), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isBackButton {
    NSNumber *isBackButton = objc_getAssociatedObject(self, kLayoutAttributeIsBackButton);
    return [isBackButton boolValue];
}

@end
