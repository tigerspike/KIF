//
//  UIPickerView+KIFRUtils.h
//  PTV
//
//  Created by Morgan Pretty on 31/03/2014.
//  Copyright (c) 2014 PTV. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^KIFRPickerViewCallbackBlock)(UIPickerView *pickerView, NSInteger selectedButtonIndex, NSInteger selectedItemIndex);

@interface UIPickerView (KIFRUtils)

+ (id)showWithContentArray:(NSArray *)contentArray selectedIndex:(NSInteger)selectedIndex cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles andCallback:(KIFRPickerViewCallbackBlock)callback;
+ (UIPickerView *)dismiss;
+ (UIPickerView *)dismissByPopingViewController:(UIViewController *)viewController;

@end
