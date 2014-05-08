//
//  KIFRecordingWindow.h
//  TSSales
//
//  Created by Morgan Pretty on 19/03/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWindow (KIFRUtils) <UIGestureRecognizerDelegate>

+ (UIWindow *)kifrWindow;
- (void)KIFR_makeKeyAndVisible;

@end
