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

// UITableView Specific
@property (nonatomic, copy) NSString *tableViewAccessibilityIdentifier;
@property (nonatomic, strong) NSIndexPath *cellIndexPath;

// UISegmentedControl Specific
@property (nonatomic, assign) NSInteger selectedIndex;

+ (KIFRTargetInfo *)targetInfoForView:(UIView *)view;

@end
