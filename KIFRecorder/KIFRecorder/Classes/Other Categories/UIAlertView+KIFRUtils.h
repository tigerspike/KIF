//
//  UIAlertView+KIFRUtils.h
//  PTV
//
//  Created by Morgan Pretty on 28/03/2014.
//  Copyright (c) 2014 PTV. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^KIFRAlertViewCallbackBlock)(UIAlertView *alertView, NSInteger selectedButtonIndex);

@interface UIAlertView (KIFRUtils) <UIAlertViewDelegate>

@property (nonatomic, copy) KIFRAlertViewCallbackBlock callbackBlock;

+ (id)showWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles andCallback:(KIFRAlertViewCallbackBlock)callback;
+ (id)showWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles style:(UIAlertViewStyle)style andCallback:(KIFRAlertViewCallbackBlock)callback;

@end
