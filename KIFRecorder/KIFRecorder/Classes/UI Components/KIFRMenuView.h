//
//  KIFRMenuView.h
//  TSSales
//
//  Created by Morgan Pretty on 27/03/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KIFRMenuView : UIView

@property (nonatomic, assign) BOOL isExpanded;

+ (KIFRMenuView *)sharedInstance;
- (void)setExpanded:(BOOL)expanded animated:(BOOL)animated;

@end
