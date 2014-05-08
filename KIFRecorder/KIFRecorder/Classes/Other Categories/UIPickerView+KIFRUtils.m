//
//  UIPickerView+KIFRUtils.m
//  PTV
//
//  Created by Morgan Pretty on 31/03/2014.
//  Copyright (c) 2014 PTV. All rights reserved.
//

#import "UIPickerView+KIFRUtils.h"
#import <objc/runtime.h>

#define PICKER_HEIGHT 216
#define INPUT_ACCESSORY_VIEW_HEIGHT 44

#define kCallbackBlockKey @"CallbackBlockKey"
#define kPickerContentKey @"PickerContentKey"
#define kContentViewKey @"ContentViewKey"
#define kInputAccessoryViewKey @"InputAccessoryViewKey"

// We should only have one on the screen at a time, so static variables should work
static BOOL pickerIsVisible = NO;
static UIPickerView *pickerInstance;

@interface UIPickerView (KIFRUtilsPrivate) <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, copy) KIFRPickerViewCallbackBlock callbackBlock;
@property (nonatomic, strong) NSArray *pickerContent;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *inputAccessoryView;

@end

@implementation UIPickerView (KIFRUtils)

+ (id)showWithContentArray:(NSArray *)contentArray selectedIndex:(NSInteger)selectedIndex cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles andCallback:(KIFRPickerViewCallbackBlock)callback {
    if (!pickerIsVisible) {
        UIWindow *window = [[UIApplication sharedApplication] delegate].window;
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        
        BOOL needsAccessoryView = (cancelButtonTitle.length > 0 || otherButtonTitles.count > 0);
        if (!pickerInstance) {
            pickerInstance = [UIPickerView new];
        }
        
        // Setup the picker size and contentView
        pickerInstance.frame = CGRectMake(0, (needsAccessoryView ? INPUT_ACCESSORY_VIEW_HEIGHT : 0), screenWidth, PICKER_HEIGHT);
        pickerInstance.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, window.kifrHeight, screenWidth, PICKER_HEIGHT + (needsAccessoryView ? INPUT_ACCESSORY_VIEW_HEIGHT : 0))];
        pickerInstance.contentView.backgroundColor = [UIColor whiteColor];
        
        
        // If we need an 'inputAccessoryView' set it up
        if (needsAccessoryView) {
            pickerInstance.inputAccessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, INPUT_ACCESSORY_VIEW_HEIGHT)];
            pickerInstance.inputAccessoryView.backgroundColor = [UIColor darkGrayColor];
            UIFont *buttonTitleFont = [UIFont boldSystemFontOfSize:16];
            
            if (cancelButtonTitle.length > 0) {
                CGSize titleSize = [cancelButtonTitle sizeWithAttributes:@{ NSFontAttributeName : buttonTitleFont }];
                UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, titleSize.width, pickerInstance.inputAccessoryView.kifrHeight)];
                cancelButton.tag = 0;
                cancelButton.titleLabel.font = buttonTitleFont;
                [cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
                [cancelButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
                [cancelButton addTarget:pickerInstance action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                [pickerInstance.inputAccessoryView addSubview:cancelButton];
            }
            
            UIButton *previousButton;
            for (NSString *titleString in otherButtonTitles) {
                CGSize titleSize = [cancelButtonTitle sizeWithAttributes:@{ NSFontAttributeName : buttonTitleFont }];
                UIButton *otherButton = [[UIButton alloc] initWithFrame:CGRectMake((previousButton ? previousButton.kifrX - titleSize.width - 10 : pickerInstance.inputAccessoryView.kifrWidth - titleSize.width - 10), 0, titleSize.width, pickerInstance.inputAccessoryView.kifrHeight)];
                otherButton.tag = [otherButtonTitles indexOfObject:titleString] + 1;
                otherButton.titleLabel.font = buttonTitleFont;
                [otherButton setTitle:titleString forState:UIControlStateNormal];
                [otherButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
                [otherButton addTarget:pickerInstance action:@selector(otherButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                [pickerInstance.inputAccessoryView addSubview:otherButton];
                
                previousButton = otherButton;
            }
            
            [pickerInstance.contentView addSubview:pickerInstance.inputAccessoryView];
        }
        
        pickerInstance.pickerContent = contentArray;
        pickerInstance.callbackBlock = callback;
        pickerInstance.delegate = pickerInstance;
        pickerInstance.dataSource = pickerInstance;
        [pickerInstance selectRow:selectedIndex inComponent:0 animated:NO];
        [pickerInstance.contentView addSubview:pickerInstance];
        
        
        // Hijack the 'UIKeyboardWillShowNotification' notification since we want the same keyboard avoidance stuff
        [[NSNotificationCenter defaultCenter] postNotificationName:UIKeyboardWillShowNotification object:pickerInstance.contentView userInfo:@{UIKeyboardAnimationDurationUserInfoKey : @(0.3), UIKeyboardFrameEndUserInfoKey : [NSValue valueWithCGRect:CGRectMake(0, window.kifrHeight, screenWidth, pickerInstance.contentView.kifrHeight)]}];
        
        // Add the date picker to the window
        if (!pickerInstance.contentView.superview) {
            pickerInstance.contentView.kifrY = window.kifrHeight;
            [window addSubview:pickerInstance.contentView];
        }
        
        // Hide keyboard automatically
        [pickerInstance.contentView.superview endEditing:YES];
        
        // Play the Animation
        pickerIsVisible = YES;
        [UIView animateWithDuration:0.3 animations:^{
            pickerInstance.contentView.kifrFrameBottom = window.kifrHeight;
        }];
        
        return pickerInstance;
    }
    else {
        // Change the selectedIndex animated
        [pickerInstance selectRow:selectedIndex inComponent:0 animated:YES];
    }
    
    return nil;

}

#pragma mark - UIControl Handlers

- (void)cancelButtonPressed:(UIButton *)sender {
    if (pickerInstance.callbackBlock) {
        pickerInstance.callbackBlock(pickerInstance, sender.tag, [pickerInstance selectedRowInComponent:0]);
    }
    
    [UIPickerView dismiss];
}

- (void)otherButtonPressed:(UIButton *)sender {
    if (pickerInstance.callbackBlock) {
        pickerInstance.callbackBlock(pickerInstance, sender.tag, [pickerInstance selectedRowInComponent:0]);
    }
    
    [UIPickerView dismiss];
}

#pragma mark - Associated Object Methods

- (KIFRPickerViewCallbackBlock)callbackBlock {
    KIFRPickerViewCallbackBlock callbackBlock = (KIFRPickerViewCallbackBlock)objc_getAssociatedObject(self, kCallbackBlockKey);
    if (callbackBlock != nil) {
        return callbackBlock;
    }
    
    return nil;
}

- (void)setCallbackBlock:(KIFRPickerViewCallbackBlock)callbackBlock {
    objc_setAssociatedObject(self, kCallbackBlockKey, callbackBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSArray *)pickerContent {
    return objc_getAssociatedObject(self, kPickerContentKey);
}

- (void)setPickerContent:(NSArray *)pickerContent {
    objc_setAssociatedObject(self, kPickerContentKey, pickerContent, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)contentView {
    return objc_getAssociatedObject(self, kContentViewKey);
}

- (void)setContentView:(UIView *)contentView {
    objc_setAssociatedObject(self, kContentViewKey, contentView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)inputAccessoryView {
    return objc_getAssociatedObject(self, kInputAccessoryViewKey);
}

- (void)setInputAccessoryView:(UIView *)inputAccessoryView {
    objc_setAssociatedObject(self, kInputAccessoryViewKey, inputAccessoryView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - UIPickerView Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return pickerView.pickerContent.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return pickerView.pickerContent[row];
}

#pragma mark - Picker Animations

+ (UIPickerView *)dismiss {
    if (pickerIsVisible) {
        UIWindow *window = [[UIApplication sharedApplication] delegate].window;
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:UIKeyboardWillHideNotification object:pickerInstance.contentView userInfo:@{UIKeyboardAnimationDurationUserInfoKey : @(0.3), UIKeyboardFrameEndUserInfoKey : [NSValue valueWithCGRect:CGRectMake(0, window.kifrHeight, screenWidth, PICKER_HEIGHT + pickerInstance.contentView.kifrHeight)]}];
        
        // Hide the Picker
        [UIView animateWithDuration:0.3 animations:^{
            pickerInstance.contentView.kifrY = window.kifrHeight;
        } completion:^(BOOL finished) {
            [pickerInstance.contentView removeFromSuperview];
            [pickerInstance.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            pickerIsVisible = NO;
        }];
    }
    
    return pickerInstance;
}

+ (UIPickerView *)dismissByPopingViewController:(UIViewController *)viewController {
    if (pickerIsVisible && viewController) {
        CGRect viewConRect = [pickerInstance.contentView.superview convertRect:pickerInstance.contentView.frame toView:viewController.view];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:UIKeyboardWillHideNotification object:pickerInstance.contentView userInfo:@{UIKeyboardAnimationDurationUserInfoKey : @(0.3), UIKeyboardFrameEndUserInfoKey : [NSValue valueWithCGRect:viewConRect]}];
        
        [pickerInstance.contentView removeFromSuperview];
        pickerInstance.contentView.frame = viewConRect;
        [viewController.view addSubview:pickerInstance.contentView];
        
        // Hide the Picker
        // TODO: Find a way to detect when the 'viewController' has disappeared and remove the contentView from it
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [pickerInstance.contentView removeFromSuperview];
            [pickerInstance.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            pickerIsVisible = NO;
        });
    }
    
    return pickerInstance;
}

@end
