//
//  KIFRBorderView.m
//  TSSales
//
//  Created by Morgan Pretty on 24/03/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import "KIFRBorderView.h"

@implementation KIFRBorderView

+ (void)createBorderForEvent:(KIFRTestEvent *)event {
    if (!event) {
        return;
    }
    
    // Is it better to attach border to the window or the view?
    BOOL attachToWindow = YES;
    KIFRBorderView *borderView = [KIFRBorderView new];
    borderView.event = event;
    borderView.userInteractionEnabled = NO;
    borderView.layer.borderWidth = 3;
    borderView.layer.borderColor = [UIColor redColor].CGColor;
    
    // Create a red border around the tapped view
    if (attachToWindow) {
        if (event.isKeyboardEvent) {
            borderView.frame = [event.targetView.window convertRect:event.keyboardKeyFrame fromView:event.targetView];
        }
        else {
            borderView.frame = [event.targetView.window convertRect:event.targetView.frame fromView:event.targetView.superview];
        }
        [event.targetView.window addSubview:borderView];
    }
    else {
        if (event.isKeyboardEvent) {
            borderView.frame = event.keyboardKeyFrame;
        }
        else {
            borderView.frame = event.targetView.bounds;
        }
        [event.targetView addSubview:borderView];
    }
    
    [borderView tryRemoveBorder];
}

- (void)tryRemoveBorder {
    // Remove it after 0.2 seconds
    __weak KIFRBorderView *weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        KIFRBorderView *strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        // If the 'targetView' doesn't exist anymore
        if (!strongSelf.event || !strongSelf.event.targetView) {
            // Remove the border
            [strongSelf removeFromSuperview];
        }
        else {
            // Otherwise, delay it some more
            [strongSelf tryRemoveBorder];
        }
    });
}

@end
