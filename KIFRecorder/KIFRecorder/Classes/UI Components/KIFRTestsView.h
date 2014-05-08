//
//  KIFRTestsViewController.h
//  TSSales
//
//  Created by Morgan Pretty on 27/03/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KIFRMenuView;

@interface KIFRTestsView : UIView

@property (nonatomic, copy) NSArray *testArray;
@property (nonatomic, assign) BOOL parentIsAnimating;

- (id)initWithMenuView:(KIFRMenuView *)menuView;
- (void)updateTests;
- (void)reset;

@end
