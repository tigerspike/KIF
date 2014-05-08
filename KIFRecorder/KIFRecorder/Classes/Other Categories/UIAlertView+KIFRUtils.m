//
//  UIAlertView+KIFRUtils.m
//  PTV
//
//  Created by Morgan Pretty on 28/03/2014.
//  Copyright (c) 2014 PTV. All rights reserved.
//

#import "UIAlertView+KIFRUtils.h"
#import <objc/runtime.h>

#define ASSOCIATED_OBJ_KEY @"UIAlertView_Block_Key"

@implementation UIAlertView (KIFRUtils)

+ (id)showWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles andCallback:(KIFRAlertViewCallbackBlock)callback {
    return [self showWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles style:UIAlertViewStyleDefault andCallback:callback];
};

+ (id)showWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles style:(UIAlertViewStyle)style andCallback:(KIFRAlertViewCallbackBlock)callback {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    alertView.alertViewStyle = style;
    
    // Tell KIFR to ignore the interaction with the UIAlertView
    alertView.recursiveKIFRShouldIgnore = YES;
    
    // Make the alert view it's own delegate
    alertView.delegate = alertView;
    
    for (NSString *buttonTitle in otherButtonTitles) {
        [alertView addButtonWithTitle:buttonTitle];
    }
    
    // Associate the callback block
    [alertView setCallbackBlock:callback];
    
    // Show the alert
    dispatch_async(dispatch_get_main_queue(), ^{
        [alertView show];
    });
    
    return alertView;
}

- (KIFRAlertViewCallbackBlock)callbackBlock {
    KIFRAlertViewCallbackBlock callbackBlock = (KIFRAlertViewCallbackBlock)objc_getAssociatedObject(self, ASSOCIATED_OBJ_KEY);
    if (callbackBlock != nil) {
        return callbackBlock;
    }
    
    return nil;
}

- (void)setCallbackBlock:(KIFRAlertViewCallbackBlock)callbackBlock {
    objc_setAssociatedObject(self, ASSOCIATED_OBJ_KEY, callbackBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    KIFRAlertViewCallbackBlock callbackBlock = alertView.callbackBlock;
    if (callbackBlock != nil) {
        callbackBlock(alertView, buttonIndex);
    }
    
    // Now release the associated object by setting it to nil
    [alertView setCallbackBlock:nil];
}

@end
