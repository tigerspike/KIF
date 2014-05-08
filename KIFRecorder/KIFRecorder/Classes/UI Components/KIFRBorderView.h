//
//  KIFRBorderView.h
//  TSSales
//
//  Created by Morgan Pretty on 24/03/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KIFRTestEvent.h"

@interface KIFRBorderView : UIView

@property (nonatomic, weak) KIFRTestEvent *event;

+ (void)createBorderForEvent:(KIFRTestEvent *)event;

@end
