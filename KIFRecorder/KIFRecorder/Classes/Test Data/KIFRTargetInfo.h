//
//  KIFRTargetInfo.h
//  TSSales
//
//  Created by Morgan Pretty on 24/03/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KIFRTargetInfo : NSObject

@property (nonatomic, copy) NSString *accessibilityIdentifier;
@property (nonatomic, copy) Class targetClass;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, copy) NSString *contentString;
@property (nonatomic, assign) NSUInteger numberOfSubviews;
@property (nonatomic, assign) BOOL interactionEnabled;

// Internal View Values
@property (nonatomic, assign) BOOL hasAccessibleParent;
@property (nonatomic, copy) Class firstAccessibleParentClass;
@property (nonatomic, copy) NSString *firstAccessibleParentAccessibilityIdentifier;
@property (nonatomic, copy) Class internalTargetClass;
@property (nonatomic, assign) BOOL isTargettingInternalSubview;

// UITableView Specific
@property (nonatomic, copy) NSString *tableViewAccessibilityIdentifier;
@property (nonatomic, strong) NSIndexPath *cellIndexPath;

// UISegmentedControl Specific
@property (nonatomic, assign) NSInteger selectedIndex;

+ (KIFRTargetInfo *)targetInfoForView:(UIView *)view;

@end
