//
//  KIFTester+UI.m
//  KIF
//
//  Created by Brian Nickel on 12/14/12.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import "KIFUITestActor.h"
#import "UIApplication-KIFAdditions.h"
#import "UIWindow-KIFAdditions.h"
#import "UIAccessibilityElement-KIFAdditions.h"
#import "UIView-KIFAdditions.h"
#import "CGGeometry-KIFAdditions.h"
#import "NSError-KIFAdditions.h"
#import "KIFTypist.h"

@implementation KIFUITestActor

- (UIView *)waitForViewWithAccessibilityLabel:(NSString *)label
{
    return [self waitForViewWithAccessibilityLabel:label value:nil traits:UIAccessibilityTraitNone tappable:NO];
}

- (UIView *)waitForViewWithAccessibilityLabel:(NSString *)label traits:(UIAccessibilityTraits)traits
{
    return [self waitForViewWithAccessibilityLabel:label value:nil traits:traits tappable:NO];
}

- (UIView *)waitForViewWithAccessibilityLabel:(NSString *)label value:(NSString *)value traits:(UIAccessibilityTraits)traits
{
    return [self waitForViewWithAccessibilityLabel:label value:value traits:traits tappable:NO];
}

- (UIView *)waitForTappableViewWithAccessibilityLabel:(NSString *)label
{
    return [self waitForViewWithAccessibilityLabel:label value:nil traits:UIAccessibilityTraitNone tappable:YES];
}

- (UIView *)waitForTappableViewWithAccessibilityLabel:(NSString *)label traits:(UIAccessibilityTraits)traits
{
    return [self waitForViewWithAccessibilityLabel:label value:nil traits:traits tappable:YES];
}

- (UIView *)waitForTappableViewWithAccessibilityLabel:(NSString *)label value:(NSString *)value traits:(UIAccessibilityTraits)traits
{
    return [self waitForViewWithAccessibilityLabel:label value:value traits:traits tappable:YES];
}

- (UIView *)waitForViewWithAccessibilityLabel:(NSString *)label value:(NSString *)value traits:(UIAccessibilityTraits)traits tappable:(BOOL)mustBeTappable
{
    UIView *view = nil;
    [self waitForAccessibilityElement:NULL view:&view withLabel:label value:value traits:traits tappable:mustBeTappable];
    return view;
}

- (void)waitForAccessibilityElement:(UIAccessibilityElement **)element view:(out UIView **)view withLabel:(NSString *)label value:(NSString *)value traits:(UIAccessibilityTraits)traits tappable:(BOOL)mustBeTappable
{
    
    [self runBlock:^KIFTestStepResult(NSError **error) {
        return [UIAccessibilityElement accessibilityElement:element view:view withLabel:label value:value traits:traits tappable:mustBeTappable error:error] ? KIFTestStepResultSuccess : KIFTestStepResultWait;
    }];
}

- (void)waitForAccessibilityElement:(UIAccessibilityElement **)element view:(out UIView **)view withIdentifier:(NSString *)identifier tappable:(BOOL)mustBeTappable {
    [self waitForAccessibilityElement:element view:view withIdentifier:identifier value:nil traits:UIAccessibilityTraitNone tappable:mustBeTappable];
}

- (void)waitForAccessibilityElement:(UIAccessibilityElement **)element view:(out UIView **)view withIdentifier:(NSString *)identifier traits:(UIAccessibilityTraits)traits tappable:(BOOL)mustBeTappable {
    [self waitForAccessibilityElement:element view:view withIdentifier:identifier value:nil traits:traits tappable:mustBeTappable];
}

- (void)waitForAccessibilityElement:(UIAccessibilityElement **)element view:(out UIView **)view withIdentifier:(NSString *)identifier value:(NSString *)value traits:(UIAccessibilityTraits)traits tappable:(BOOL)mustBeTappable {
    if (![UIAccessibilityElement instancesRespondToSelector:@selector(accessibilityIdentifier)]) {
        [self failWithError:[NSError KIFErrorWithFormat:@"Running test on platform that does not support accessibilityIdentifier"] stopTest:YES];
    }
    
    [self waitForAccessibilityElement:element view:view withElementMatchingPredicate:[NSPredicate predicateWithFormat:@"accessibilityIdentifier = %@", identifier] tappable:mustBeTappable];
}

- (void)waitForAccessibilityElement:(UIAccessibilityElement **)element view:(out UIView **)view withElementMatchingPredicate:(NSPredicate *)predicate tappable:(BOOL)mustBeTappable
{
    [self runBlock:^KIFTestStepResult(NSError **error) {
        UIAccessibilityElement *foundElement = [[UIApplication sharedApplication] accessibilityElementMatchingBlock:^BOOL(UIAccessibilityElement *element) {
            return [predicate evaluateWithObject:element];
        }];
        
        KIFTestWaitCondition(foundElement, error, @"Could not find view matching: %@", predicate);
        
        UIView *foundView = [UIAccessibilityElement viewContainingAccessibilityElement:foundElement tappable:mustBeTappable error:error];
        if (!foundView) {
            return KIFTestStepResultWait;
        }
        
        if (element) {
            *element = foundElement;
        }
        
        if (view) {
            *view = foundView;
        }
        
        return KIFTestStepResultSuccess;
    }];
}

- (void)waitForAbsenceOfViewWithAccessibilityLabel:(NSString *)label
{
    [self waitForAbsenceOfViewWithAccessibilityLabel:label traits:UIAccessibilityTraitNone];
}

- (void)waitForAbsenceOfViewWithAccessibilityLabel:(NSString *)label traits:(UIAccessibilityTraits)traits
{
    [self waitForAbsenceOfViewWithAccessibilityLabel:label value:nil traits:traits];
}

- (void)waitForAbsenceOfViewWithAccessibilityLabel:(NSString *)label value:(NSString *)value traits:(UIAccessibilityTraits)traits
{
    [self runBlock:^KIFTestStepResult(NSError **error) {
        // If the app is ignoring interaction events, then wait before doing our analysis
        KIFTestWaitCondition(![[UIApplication sharedApplication] isIgnoringInteractionEvents], error, @"Application is ignoring interaction events.");
        
        // If the element can't be found, then we're done
        UIAccessibilityElement *element = [[UIApplication sharedApplication] accessibilityElementWithLabel:label accessibilityValue:value traits:traits];
        if (!element) {
            return KIFTestStepResultSuccess;
        }
        
        UIView *view = [UIAccessibilityElement viewContainingAccessibilityElement:element];
        
        // If we found an element, but it's not associated with a view, then something's wrong. Wait it out and try again.
        KIFTestWaitCondition(view, error, @"Cannot find view containing accessibility element with the label \"%@\"", label);
        
        // Hidden views count as absent
        KIFTestWaitCondition([view isHidden], error, @"Accessibility element with label \"%@\" is visible and not hidden.", label);
        
        return KIFTestStepResultSuccess;
    }];
}

- (void)tapViewWithAccessibilityLabel:(NSString *)label {
    [self tapViewWithAccessibilityLabel:label value:nil traits:UIAccessibilityTraitNone];
}

- (void)tapViewWithAccessibilityIdentifier:(NSString *)identifier {
    [self tapViewWithAccessibilityIdentifier:identifier value:nil traits:UIAccessibilityTraitNone];
}

- (void)tapViewWithAccessibilityLabel:(NSString *)label traits:(UIAccessibilityTraits)traits {
    [self tapViewWithAccessibilityLabel:label value:nil traits:traits];
}

- (void)tapViewWithAccessibilityIdentifier:(NSString *)identifier traits:(UIAccessibilityTraits)traits {
    [self tapViewWithAccessibilityIdentifier:identifier value:nil traits:traits];
}

- (void)tapViewWithAccessibilityLabel:(NSString *)label value:(NSString *)value traits:(UIAccessibilityTraits)traits {
    UIView *view = nil;
    UIAccessibilityElement *element = nil;
    
    [self waitForAccessibilityElement:&element view:&view withLabel:label value:value traits:traits tappable:YES];
    [self tapAccessibilityElement:element inView:view];
}

- (void)tapViewWithAccessibilityIdentifier:(NSString *)identifier value:(NSString *)value traits:(UIAccessibilityTraits)traits {
    UIView *view = nil;
    UIAccessibilityElement *element = nil;
    
    [self waitForAccessibilityElement:&element view:&view withIdentifier:identifier traits:traits tappable:YES];
    [self tapAccessibilityElement:element inView:view];
}

- (void)tapAccessibilityElement:(UIAccessibilityElement *)element inView:(UIView *)view
{
    [self runBlock:^KIFTestStepResult(NSError **error) {
        
        KIFTestWaitCondition(view.isUserInteractionActuallyEnabled, error, @"View is not enabled for interaction");
        
        // If the accessibilityFrame is not set, fallback to the view frame.
        CGRect elementFrame;
        if (CGRectEqualToRect(CGRectZero, element.accessibilityFrame)) {
            elementFrame.origin = CGPointZero;
            elementFrame.size = view.frame.size;
        } else {
            elementFrame = [view.windowOrIdentityWindow convertRect:element.accessibilityFrame toView:view];
        }
        CGPoint tappablePointInElement = [view tappablePointInRect:elementFrame];
        
        // This is mostly redundant of the test in _accessibilityElementWithLabel:
        KIFTestWaitCondition(!isnan(tappablePointInElement.x), error, @"View is not tappable");
        [view tapAtPoint:tappablePointInElement];
        
        KIFTestCondition(![view canBecomeFirstResponder] || [view isDescendantOfFirstResponder], error, @"Failed to make the view into the first responder");
        
        return KIFTestStepResultSuccess;
    }];
    
    // Wait for the view to stabilize.
    [self waitForTimeInterval:0.5];
}

- (void)tapScreenAtPoint:(CGPoint)screenPoint
{
    [self runBlock:^KIFTestStepResult(NSError **error) {
        
        // Try all the windows until we get one back that actually has something in it at the given point
        UIView *view = nil;
        for (UIWindow *window in [[[UIApplication sharedApplication] windowsWithKeyWindow] reverseObjectEnumerator]) {
            CGPoint windowPoint = [window convertPoint:screenPoint fromView:nil];
            view = [window hitTest:windowPoint withEvent:nil];
            
            // If we hit the window itself, then skip it.
            if (view != window && view != nil) {
                break;
            }
        }
        
        KIFTestWaitCondition(view, error, @"No view was found at the point %@", NSStringFromCGPoint(screenPoint));
        
        // This is mostly redundant of the test in _accessibilityElementWithLabel:
        CGPoint viewPoint = [view convertPoint:screenPoint fromView:nil];
        [view tapAtPoint:viewPoint];
        
        return KIFTestStepResultSuccess;
    }];
}

- (void)longPressViewWithAccessibilityLabel:(NSString *)label duration:(NSTimeInterval)duration {
    [self longPressViewWithAccessibilityLabel:label value:nil traits:UIAccessibilityTraitNone duration:duration];
}

- (void)longPressViewWithAccessibilityIdentifier:(NSString *)identifier duration:(NSTimeInterval)duration {
    [self longPressViewWithAccessibilityIdentifier:identifier value:nil traits:UIAccessibilityTraitNone duration:duration];
}

- (void)longPressViewWithAccessibilityLabel:(NSString *)label value:(NSString *)value duration:(NSTimeInterval)duration {
    [self longPressViewWithAccessibilityLabel:label value:value traits:UIAccessibilityTraitNone duration:duration];
}

- (void)longPressViewWithAccessibilityIdentifier:(NSString *)identifier value:(NSString *)value duration:(NSTimeInterval)duration {
    [self longPressViewWithAccessibilityIdentifier:identifier value:nil traits:UIAccessibilityTraitNone duration:duration];
}

- (void)longPressViewWithAccessibilityLabel:(NSString *)label value:(NSString *)value traits:(UIAccessibilityTraits)traits duration:(NSTimeInterval)duration; {
    UIView *view = nil;
    UIAccessibilityElement *element = nil;
    
    [self waitForAccessibilityElement:&element view:&view withLabel:label value:value traits:traits tappable:YES];
    [self longPressAccessibilityElement:element inView:view duration:duration];
}

- (void)longPressViewWithAccessibilityIdentifier:(NSString *)identifier value:(NSString *)value traits:(UIAccessibilityTraits)traits duration:(NSTimeInterval)duration {
    UIView *view = nil;
    UIAccessibilityElement *element = nil;
    
    [self waitForAccessibilityElement:&element view:&view withIdentifier:identifier value:value traits:traits tappable:YES];
    [self longPressAccessibilityElement:element inView:view duration:duration];
}

- (void)longPressAccessibilityElement:(UIAccessibilityElement *)element inView:(UIView *)view duration:(NSTimeInterval)duration;
{
    [self runBlock:^KIFTestStepResult(NSError **error) {
        
        KIFTestWaitCondition(view.isUserInteractionActuallyEnabled, error, @"View is not enabled for interaction");
        
        CGRect elementFrame = [view.windowOrIdentityWindow convertRect:element.accessibilityFrame toView:view];
        CGPoint tappablePointInElement = [view tappablePointInRect:elementFrame];
        
        // This is mostly redundant of the test in _accessibilityElementWithLabel:
        KIFTestWaitCondition(!isnan(tappablePointInElement.x), error, @"View is not tappable");
        [view longPressAtPoint:tappablePointInElement duration:duration];
        
        KIFTestCondition(![view canBecomeFirstResponder] || [view isDescendantOfFirstResponder], error, @"Failed to make the view into the first responder");
        
        return KIFTestStepResultSuccess;
    }];
    
    // Wait for view to settle.
    [self waitForTimeInterval:0.5];
}

- (void)enterTextIntoCurrentFirstResponder:(NSString *)text;
{
    // Wait for the keyboard
    [self waitForTimeInterval:0.5];
    [self enterTextIntoCurrentFirstResponder:text fallbackView:nil];
}

- (void)enterTextIntoCurrentFirstResponder:(NSString *)text fallbackView:(UIView *)fallbackView;
{
    for (NSUInteger characterIndex = 0; characterIndex < [text length]; characterIndex++) {
        NSString *characterString = [text substringWithRange:NSMakeRange(characterIndex, 1)];
        
        if (![KIFTypist enterCharacter:characterString]) {
            // Attempt to cheat if we couldn't find the character
            if (!fallbackView) {
                UIResponder *firstResponder = [[[UIApplication sharedApplication] keyWindow] firstResponder];
                
                if ([firstResponder isKindOfClass:[UIView class]]) {
                    fallbackView = (UIView *)firstResponder;
                }
            }
            
            if ([fallbackView isKindOfClass:[UITextField class]] || [fallbackView isKindOfClass:[UITextView class]]) {
                NSLog(@"KIF: Unable to find keyboard key for %@. Inserting manually.", characterString);
                [(UITextField *)fallbackView setText:[[(UITextField *)fallbackView text] stringByAppendingString:characterString]];
            } else {
                [self failWithError:[NSError KIFErrorWithFormat:@"Failed to find key for character \"%@\"", characterString] stopTest:YES];
            }
        }
    }
}

- (void)enterText:(NSString *)text intoViewWithAccessibilityLabel:(NSString *)label {
    return [self enterText:text intoViewWithAccessibilityLabel:label traits:UIAccessibilityTraitNone expectedResult:nil];
}

- (void)enterText:(NSString *)text intoViewWithAccessibilityIdentifier:(NSString *)identifier {
    return [self enterText:text intoViewWithAccessibilityIdentifier:identifier traits:UIAccessibilityTraitNone expectedResult:nil];
}

- (void)enterText:(NSString *)text intoViewWithAccessibilityLabel:(NSString *)label traits:(UIAccessibilityTraits)traits expectedResult:(NSString *)expectedResult
{
    UIView *view = nil;
    UIAccessibilityElement *element = nil;
    
    [self waitForAccessibilityElement:&element view:&view withLabel:label value:nil traits:traits tappable:YES];
    [self tapAccessibilityElement:element inView:view];
    [self enterTextIntoCurrentFirstResponder:text fallbackView:view];
    [self expectView:view toContainText:expectedResult ?: text];
}

- (void)enterText:(NSString *)text intoViewWithAccessibilityIdentifier:(NSString *)identifier traits:(UIAccessibilityTraits)traits expectedResult:(NSString *)expectedResult {
    UIView *view = nil;
    UIAccessibilityElement *element = nil;
    
    [self waitForAccessibilityElement:&element view:&view withIdentifier:identifier value:nil traits:traits tappable:YES];
    [self tapAccessibilityElement:element inView:view];
    [self enterTextIntoCurrentFirstResponder:text fallbackView:view];
    [self expectView:view toContainText:expectedResult ?: text];
}

- (void)expectView:(UIView *)view toContainText:(NSString *)expectedResult
{
    // We will perform some additional validation if the view is UITextField or UITextView.
    if (![view respondsToSelector:@selector(text)]) {
        return;
    }
    
    UITextView *textView = (UITextView *)view;
    
    // Some slower machines take longer for typing to catch up, so wait for a bit before failing
    [self runBlock:^KIFTestStepResult(NSError **error) {
        // We trim \n and \r because they trigger the return key, so they won't show up in the final product on single-line inputs
        NSString *expected = [expectedResult stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        NSString *actual = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        KIFTestWaitCondition([actual isEqualToString:expected], error, @"Failed to get text \"%@\" in field; instead, it was \"%@\"", expected, actual);
        
        return KIFTestStepResultSuccess;
    } timeout:1.0];
}



- (void)clearTextFromViewWithAccessibilityLabel:(NSString *)label {
    [self clearTextFromViewWithAccessibilityLabel:label traits:UIAccessibilityTraitNone];
}

- (void)clearTextFromViewWithAccessibilityIdentifier:(NSString *)identifier {
    [self clearTextFromViewWithAccessibilityIdentifier:identifier traits:UIAccessibilityTraitNone];
}

- (void)clearTextFromViewWithAccessibilityLabel:(NSString *)label traits:(UIAccessibilityTraits)traits {
    UIView *view = nil;
    UIAccessibilityElement *element = nil;
    
    [self waitForAccessibilityElement:&element view:&view withLabel:label value:nil traits:traits tappable:YES];
    [self clearTextFromElement:element inView:view];
}

- (void)clearTextFromViewWithAccessibilityIdentifier:(NSString *)identifier traits:(UIAccessibilityTraits)traits {
    UIView *view = nil;
    UIAccessibilityElement *element = nil;
    
    [self waitForAccessibilityElement:&element view:&view withIdentifier:identifier value:nil traits:traits tappable:YES];
    [self clearTextFromElement:element inView:view];
}

- (void)clearTextFromElement:(UIAccessibilityElement *)element inView:(UIView *)view {
    NSUInteger numberOfCharacters = [view respondsToSelector:@selector(text)] ? [(UITextField *)view text].length : element.accessibilityValue.length;
    
    [self tapAccessibilityElement:element inView:view];
    
    // Per issue #294, the tap occurs in the center of the text view.  If the text is too long, this means not all text gets cleared.  To address this for most cases, we can check if the selected view conforms to UITextInput and select the whole text range.
    if ([view conformsToProtocol:@protocol(UITextInput)]) {
        id <UITextInput> textInput = (id <UITextInput>)view;
        [textInput setSelectedTextRange:[textInput textRangeFromPosition:textInput.beginningOfDocument toPosition:textInput.endOfDocument]];
        
        [self waitForTimeInterval:0.1];
        [self enterTextIntoCurrentFirstResponder:@"\b" fallbackView:view];
    }
    else {
        
        NSMutableString *text = [NSMutableString string];
        for (NSInteger i = 0; i < numberOfCharacters; i ++) {
            [text appendString:@"\b"];
        }
        
        [self enterTextIntoCurrentFirstResponder:text fallbackView:view];
    }
    
    [self expectView:view toContainText:@""];
}

- (void)clearTextFromAndThenEnterText:(NSString *)text intoViewWithAccessibilityLabel:(NSString *)label {
    [self clearTextFromAndThenEnterText:text intoViewWithAccessibilityLabel:label traits:UIAccessibilityTraitNone expectedResult:nil];
}

- (void)clearTextFromAndThenEnterText:(NSString *)text intoViewWithAccessibilityIdentifier:(NSString *)identifier {
    [self clearTextFromAndThenEnterText:text intoViewWithAccessibilityIdentifier:identifier traits:UIAccessibilityTraitNone expectedResult:nil];
}

- (void)clearTextFromAndThenEnterText:(NSString *)text intoViewWithAccessibilityLabel:(NSString *)label traits:(UIAccessibilityTraits)traits expectedResult:(NSString *)expectedResult {
    [self clearTextFromViewWithAccessibilityLabel:label traits:traits];
    [self enterText:text intoViewWithAccessibilityLabel:label traits:traits expectedResult:expectedResult];
}

- (void)clearTextFromAndThenEnterText:(NSString *)text intoViewWithAccessibilityIdentifier:(NSString *)identifier traits:(UIAccessibilityTraits)traits expectedResult:(NSString *)expectedResult {
    [self clearTextFromViewWithAccessibilityIdentifier:identifier];
    [self enterText:text intoViewWithAccessibilityIdentifier:identifier];
}

- (void)selectPickerViewRowWithTitle:(NSString *)title
{
    [self runBlock:^KIFTestStepResult(NSError **error) {
        // Find the picker view
        UIPickerView *pickerView = [[[[UIApplication sharedApplication] pickerViewWindow] subviewsWithClassNameOrSuperClassNamePrefix:@"UIPickerView"] lastObject];
        KIFTestCondition(pickerView, error, @"No picker view is present");
        
        NSInteger componentCount = [pickerView.dataSource numberOfComponentsInPickerView:pickerView];
        KIFTestCondition(componentCount == 1, error, @"The picker view has multiple columns, which is not supported in testing.");
        
        for (NSInteger componentIndex = 0; componentIndex < componentCount; componentIndex++) {
            NSInteger rowCount = [pickerView.dataSource pickerView:pickerView numberOfRowsInComponent:componentIndex];
            for (NSInteger rowIndex = 0; rowIndex < rowCount; rowIndex++) {
                NSString *rowTitle = nil;
                if ([pickerView.delegate respondsToSelector:@selector(pickerView:titleForRow:forComponent:)]) {
                    rowTitle = [pickerView.delegate pickerView:pickerView titleForRow:rowIndex forComponent:componentIndex];
                } else if ([pickerView.delegate respondsToSelector:@selector(pickerView:viewForRow:forComponent:reusingView:)]) {
                    // This delegate inserts views directly, so try to figure out what the title is by looking for a label
                    UIView *rowView = [pickerView.delegate pickerView:pickerView viewForRow:rowIndex forComponent:componentIndex reusingView:nil];
                    NSArray *labels = [rowView subviewsWithClassNameOrSuperClassNamePrefix:@"UILabel"];
                    UILabel *label = (labels.count > 0 ? labels[0] : nil);
                    rowTitle = label.text;
                }
                
                if ([rowTitle isEqual:title]) {
                    [pickerView selectRow:rowIndex inComponent:componentIndex animated:YES];
                    CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.5, false);
                    
                    // Tap in the middle of the picker view to select the item
                    [pickerView tap];
                    
                    // The combination of selectRow:inComponent:animated: and tap does not consistently result in
                    // pickerView:didSelectRow:inComponent: being called on the delegate. We need to do it explicitly.
                    if ([pickerView.delegate respondsToSelector:@selector(pickerView:didSelectRow:inComponent:)]) {
                        [pickerView.delegate pickerView:pickerView didSelectRow:rowIndex inComponent:componentIndex];
                    }
                    
                    return KIFTestStepResultSuccess;
                }
            }
        }
        
        KIFTestCondition(NO, error, @"Failed to find picker view value with title \"%@\"", title);
        return KIFTestStepResultFailure;
    }];
}

- (void)setOn:(BOOL)switchIsOn forSwitchWithAccessibilityLabel:(NSString *)label {
    UIView *view = nil;
    UIAccessibilityElement *element = nil;
    
    [self waitForAccessibilityElement:&element view:&view withLabel:label value:nil traits:UIAccessibilityTraitButton tappable:YES];
    [self setOn:switchIsOn forElement:element inSwitch:(UISwitch *)view withIdentifier:label];
}

- (void)setOn:(BOOL)switchIsOn forSwitchWithAccessibilityIdentifier:(NSString *)identifier {
    UIView *view = nil;
    UIAccessibilityElement *element = nil;
    
    [self waitForAccessibilityElement:&element view:&view withIdentifier:identifier value:nil traits:UIAccessibilityTraitButton tappable:YES];
    [self setOn:switchIsOn forElement:element inSwitch:(UISwitch *)view withIdentifier:identifier];
}

- (void)setOn:(BOOL)switchIsOn forElement:(UIAccessibilityElement *)element inSwitch:(UISwitch *)switchView withIdentifier:(NSString *)identifier {
    if (![switchView isKindOfClass:[UISwitch class]]) {
        [self failWithError:[NSError KIFErrorWithFormat:@"View with accessibility label \"%@\" is a %@, not a UISwitch", identifier, NSStringFromClass([switchView class])] stopTest:YES];
    }
    
    // No need to switch it if it's already in the correct position
    if (switchView.isOn == switchIsOn) {
        return;
    }
    
    [self tapAccessibilityElement:element inView:switchView];
    
    // If we succeeded, stop the test.
    if (switchView.isOn == switchIsOn) {
        return;
    }
    
    NSLog(@"Faking turning switch %@ with accessibility label %@", switchIsOn ? @"ON" : @"OFF", identifier);
    [switchView setOn:switchIsOn animated:YES];
    [switchView sendActionsForControlEvents:UIControlEventValueChanged];
    [self waitForTimeInterval:0.5];
    
    // We gave it our best shot.  Fail the test.
    if (switchView.isOn != switchIsOn) {
        [self failWithError:[NSError KIFErrorWithFormat:@"Failed to toggle switch to \"%@\"; instead, it was \"%@\"", switchIsOn ? @"ON" : @"OFF", switchView.on ? @"ON" : @"OFF"] stopTest:YES];
    }
}

- (void)setValue:(float)value forSliderWithAccessibilityLabel:(NSString *)label {
    UISlider *slider = nil;
    UIAccessibilityElement *element = nil;
    [self waitForAccessibilityElement:&element view:&slider withLabel:label value:nil traits:UIAccessibilityTraitNone tappable:YES];
    [self setValue:value forElement:element inSlider:slider withIdentifier:label];
}

- (void)setValue:(float)value forSliderWithAccessibilityIdentifier:(NSString *)identifier {
    UISlider *slider = nil;
    UIAccessibilityElement *element = nil;
    [self waitForAccessibilityElement:&element view:&slider withIdentifier:identifier value:nil traits:UIAccessibilityTraitNone tappable:YES];
    [self setValue:value forElement:element inSlider:slider withIdentifier:identifier];
}

- (void)setValue:(float)value forElement:(UIAccessibilityElement *)element inSlider:(UISlider *)sliderView withIdentifier:(NSString *)identifier {
    if (![sliderView isKindOfClass:[UISlider class]]) {
        [self failWithError:[NSError KIFErrorWithFormat:@"View with accessibility label \"%@\" is a %@, not a UISlider", identifier, NSStringFromClass([sliderView class])] stopTest:YES];
    }
    
    if (value < sliderView.minimumValue) {
        [self failWithError:[NSError KIFErrorWithFormat:@"Cannot slide past minimum value of %f", sliderView.minimumValue] stopTest:YES];
    }
    
    if (value > sliderView.maximumValue) {
        [self failWithError:[NSError KIFErrorWithFormat:@"Cannot slide past maximum value of %f", sliderView.maximumValue] stopTest:YES];
    }
    
    CGRect trackRect = [sliderView trackRectForBounds:sliderView.bounds];
    CGPoint currentPosition = CGPointCenteredInRect([sliderView thumbRectForBounds:sliderView.bounds trackRect:trackRect value:sliderView.value]);
    CGPoint finalPosition = CGPointCenteredInRect([sliderView thumbRectForBounds:sliderView.bounds trackRect:trackRect value:value]);
    
    [sliderView dragFromPoint:currentPosition toPoint:finalPosition steps:10];
}

- (void)dismissPopover
{
    const NSTimeInterval tapDelay = 0.05;
    UIWindow *window = [[UIApplication sharedApplication] dimmingViewWindow];
    if (!window) {
        [self failWithError:[NSError KIFErrorWithFormat:@"Failed to find any dimming views in the application"] stopTest:YES];
    }
    UIView *dimmingView = [[window subviewsWithClassNamePrefix:@"UIDimmingView"] lastObject];
    [dimmingView tapAtPoint:CGPointMake(50.0f, 50.0f)];
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, tapDelay, false);
}

- (void)choosePhotoInAlbum:(NSString *)albumName atRow:(NSInteger)row column:(NSInteger)column
{
    [self tapViewWithAccessibilityLabel:@"Choose Photo"];
    
    // This is basically the same as the step to tap with an accessibility label except that the accessibility labels for the albums have the number of photos appended to the end, such as "My Photos (3)." This means that we have to do a prefix match rather than an exact match.
    [self runBlock:^KIFTestStepResult(NSError **error) {
        
        NSString *labelPrefix = [NSString stringWithFormat:@"%@,   (", albumName];
        UIAccessibilityElement *element = [[UIApplication sharedApplication] accessibilityElementMatchingBlock:^(UIAccessibilityElement *element) {
            return [element.accessibilityLabel hasPrefix:labelPrefix];
        }];
        
        KIFTestWaitCondition(element, error, @"Failed to find photo album with name %@", albumName);
        
        UIView *view = [UIAccessibilityElement viewContainingAccessibilityElement:element];
        KIFTestWaitCondition(view, error, @"Failed to find view for photo album with name %@", albumName);
        
        if (![view isUserInteractionActuallyEnabled]) {
            if (error) {
                *error = [NSError KIFErrorWithFormat:@"Album picker is not enabled for interaction"];
            }
            return KIFTestStepResultWait;
        }
        
        CGRect elementFrame = [view.windowOrIdentityWindow convertRect:element.accessibilityFrame toView:view];
        CGPoint tappablePointInElement = [view tappablePointInRect:elementFrame];
        
        [view tapAtPoint:tappablePointInElement];
        
        return KIFTestStepResultSuccess;
    }];
    
    // Wait for media picker view controller to be pushed.
    [self waitForTimeInterval:0.5];
    
    // Tap the desired photo in the grid
    // TODO: This currently only works for the first page of photos. It should scroll appropriately at some point.
    const CGFloat headerHeight = 64.0;
    const CGSize thumbnailSize = CGSizeMake(75.0, 75.0);
    const CGFloat thumbnailMargin = 5.0;
    CGPoint thumbnailCenter;
    thumbnailCenter.x = thumbnailMargin + (MAX(0, column - 1) * (thumbnailSize.width + thumbnailMargin)) + thumbnailSize.width / 2.0;
    thumbnailCenter.y = headerHeight + thumbnailMargin + (MAX(0, row - 1) * (thumbnailSize.height + thumbnailMargin)) + thumbnailSize.height / 2.0;
    [self tapScreenAtPoint:thumbnailCenter];
    
    // Dismiss the resize UI
    [self tapViewWithAccessibilityLabel:@"Choose"];
}

- (void)tapRowAtIndexPath:(NSIndexPath *)indexPath inTableViewWithAccessibilityIdentifier:(NSString *)identifier
{
    UITableView *tableView;
    [self waitForAccessibilityElement:NULL view:&tableView withIdentifier:identifier tappable:NO];
    [self tapRowAtIndexPath:indexPath inTableView:tableView];
}

- (void)tapRowInTableViewWithAccessibilityLabel:(NSString*)tableViewLabel atIndexPath:(NSIndexPath *)indexPath
{
    UITableView *tableView = (UITableView *)[self waitForViewWithAccessibilityLabel:tableViewLabel];
    [self tapRowAtIndexPath:indexPath inTableView:tableView];
}

- (void)tapRowAtIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView
{
    UITableViewCell *cell = [self waitForCellAtIndexPath:indexPath inTableView:tableView];
    CGRect cellFrame = [cell.contentView convertRect:cell.contentView.frame toView:tableView];
    [tableView tapAtPoint:CGPointCenteredInRect(cellFrame)];
}

- (void)tapInternalViewOfClass:(Class)classType inViewWithAccessibilityIdentifier:(NSString *)identifier {
    UIView *view = nil;
    UIAccessibilityElement *element = nil;
    
    [self waitForAccessibilityElement:&element view:&view withIdentifier:identifier traits:nil tappable:YES];
    NSArray *controlArray = [view subviewsWithClassNameOrSuperClassNamePrefix:NSStringFromClass(classType)];
    if (controlArray.count == 1) {
        UIView *targetView = controlArray[0];
        [self tapAccessibilityElement:(UIAccessibilityElement *)targetView inView:targetView];
    }
    else {
        NSString *errorString = (controlArray.count > 0 ? @"Found too many internal views of type \"%@\"" : @"Could not find internal view of type \"%@\"");
        [self failWithError:[NSError KIFErrorWithFormat:errorString, NSStringFromClass(classType)] stopTest:YES];
    }
}

- (void)tapInternalViewOfClass:(Class)classType ofRowAtIndexPath:(NSIndexPath *)indexPath inTableViewWithAccessibilityIdentifier:(NSString *)identifier {
    UITableView *tableView;
    [self waitForAccessibilityElement:NULL view:&tableView withIdentifier:identifier tappable:NO];
    UITableViewCell *cell = [self waitForCellAtIndexPath:indexPath inTableView:tableView];
    NSArray *controlArray = [cell subviewsWithClassNameOrSuperClassNamePrefix:NSStringFromClass(classType)];
    if (controlArray.count == 1) {
        UIView *targetView = controlArray[0];
        CGRect buttonFrame = [targetView convertRect:targetView.frame toView:tableView];
        [tableView tapAtPoint:CGPointCenteredInRect(buttonFrame)];
    }
    else {
        NSString *errorString = (controlArray.count > 0 ? @"Found too many internal views of type \"%@\"" : @"Could not find internal view of type \"%@\"");
        [self failWithError:[NSError KIFErrorWithFormat:errorString, NSStringFromClass(classType)] stopTest:YES];
    }
}

- (void)tapItemAtIndexPath:(NSIndexPath *)indexPath inCollectionViewWithAccessibilityIdentifier:(NSString *)identifier
{
    UICollectionView *collectionView;
    [self waitForAccessibilityElement:NULL view:&collectionView withIdentifier:identifier tappable:NO];
    [self tapItemAtIndexPath:indexPath inCollectionView:collectionView];
}

- (void)tapItemAtIndexPath:(NSIndexPath *)indexPath inCollectionView:(UICollectionView *)collectionView
{
    UICollectionViewCell *cell;
    cell = [self waitForCellAtIndexPath:indexPath inCollectionView:collectionView];
    
    CGRect cellFrame = [cell.contentView convertRect:cell.contentView.frame toView:collectionView];
    [collectionView tapAtPoint:CGPointCenteredInRect(cellFrame)];
}

- (void)swipeViewWithAccessibilityLabel:(NSString *)label inDirection:(KIFSwipeDirection)direction {
    UIView *viewToSwipe = nil;
    UIAccessibilityElement *element = nil;
    
    [self waitForAccessibilityElement:&element view:&viewToSwipe withLabel:label value:nil traits:UIAccessibilityTraitNone tappable:NO];
    
    [self swipeElement:element inView:viewToSwipe inDirection:direction];
}

- (void)swipeViewWithAccessibilityIdentifier:(NSString *)identifier inDirection:(KIFSwipeDirection)direction {
    UIView *viewToSwipe = nil;
    UIAccessibilityElement *element = nil;
    
    [self waitForAccessibilityElement:&element view:&viewToSwipe withIdentifier:identifier value:nil traits:UIAccessibilityTraitNone tappable:NO];
    
    [self swipeElement:element inView:viewToSwipe inDirection:direction];
}

- (void)swipeElement:(UIAccessibilityElement *)element inView:(UIView *)viewToSwipe inDirection:(KIFSwipeDirection)direction {
    const NSUInteger kNumberOfPointsInSwipePath = 20;
    
    // The original version of this came from http://groups.google.com/group/kif-framework/browse_thread/thread/df3f47eff9f5ac8c
    
    // Within this method, all geometry is done in the coordinate system of the view to swipe.
    CGRect elementFrame = [viewToSwipe.windowOrIdentityWindow convertRect:element.accessibilityFrame toView:viewToSwipe];
    CGPoint swipeStart = CGPointCenteredInRect(elementFrame);
    KIFDisplacement swipeDisplacement = KIFDisplacementForSwipingInDirection(direction);
    
    [viewToSwipe dragFromPoint:swipeStart displacement:swipeDisplacement steps:kNumberOfPointsInSwipePath];
}

#pragma mark - Scroll Methods

- (void)scrollViewWithAccessibilityLabel:(NSString *)label byFractionOfSizeHorizontal:(CGFloat)horizontalFraction vertical:(CGFloat)verticalFraction
{
    UIView *viewToScroll;
    UIAccessibilityElement *element;
    [self waitForAccessibilityElement:&element view:&viewToScroll withLabel:label value:nil traits:UIAccessibilityTraitNone tappable:NO];
    [self scrollAccessibilityElement:element inView:viewToScroll byFractionOfSizeHorizontal:horizontalFraction vertical:verticalFraction];
}

- (void)scrollViewWithAccessibilityIdentifier:(NSString *)identifier byFractionOfSizeHorizontal:(CGFloat)horizontalFraction vertical:(CGFloat)verticalFraction
{
    UIView *viewToScroll;
    UIAccessibilityElement *element;
    [self waitForAccessibilityElement:&element view:&viewToScroll withIdentifier:identifier tappable:NO];
    [self scrollAccessibilityElement:element inView:viewToScroll byFractionOfSizeHorizontal:horizontalFraction vertical:verticalFraction];
}

- (void)scrollCellAtIndexPath:(NSIndexPath *)indexPath inTableViewWithAccessibilityIdentifier:(NSString *)identifier byFractionOfSizeHorizontal:(CGFloat)horizontalFraction vertical:(CGFloat)verticalFraction {
    UITableView *tableView;
    [self waitForAccessibilityElement:NULL view:&tableView withIdentifier:identifier tappable:NO];

    // Wait for the cell, convert it to a 'UIAccessibilityElement' and scroll it
    UITableViewCell *cell = [self waitForCellAtIndexPath:indexPath inTableView:tableView];
    UIAccessibilityElement *element = (UIAccessibilityElement *)cell;
    [self scrollAccessibilityElement:element inView:cell byFractionOfSizeHorizontal:horizontalFraction vertical:verticalFraction];
}

- (void)scrollAccessibilityElement:(UIAccessibilityElement *)element inView:(UIView *)viewToScroll byFractionOfSizeHorizontal:(CGFloat)horizontalFraction vertical:(CGFloat)verticalFraction
{
    const NSUInteger kNumberOfPointsInScrollPath = 5;
    
    // Within this method, all geometry is done in the coordinate system of the view to scroll.
    
    CGRect elementFrame = [viewToScroll.windowOrIdentityWindow convertRect:element.accessibilityFrame toView:viewToScroll];
    
    KIFDisplacement scrollDisplacement = CGPointMake(elementFrame.size.width * horizontalFraction, elementFrame.size.height * verticalFraction);
    
    CGPoint scrollStart = CGPointCenteredInRect(elementFrame);
    scrollStart.x -= scrollDisplacement.x / 2;
    scrollStart.y -= scrollDisplacement.y / 2;
    
    [viewToScroll dragFromPoint:scrollStart displacement:scrollDisplacement steps:kNumberOfPointsInScrollPath];
}

- (void)waitForFirstResponderWithAccessibilityLabel:(NSString *)label
{
    [self runBlock:^KIFTestStepResult(NSError **error) {
        UIResponder *firstResponder = [[[UIApplication sharedApplication] keyWindow] firstResponder];
        if ([firstResponder isKindOfClass:NSClassFromString(@"UISearchBarTextField")]) {
            do {
                firstResponder = [(UIView *)firstResponder superview];
            } while (firstResponder && ![firstResponder isKindOfClass:[UISearchBar class]]);
        }
        KIFTestWaitCondition([[firstResponder accessibilityLabel] isEqualToString:label], error, @"Expected accessibility label for first responder to be '%@', got '%@'", label, [firstResponder accessibilityLabel]);
        
        return KIFTestStepResultSuccess;
    }];
}

- (void)waitForFirstResponderWithAccessibilityIdentifier:(NSString *)identifier {
    [self runBlock:^KIFTestStepResult(NSError **error) {
        UIResponder *firstResponder = [[[UIApplication sharedApplication] keyWindow] firstResponder];
        if ([firstResponder isKindOfClass:NSClassFromString(@"UISearchBarTextField")]) {
            do {
                firstResponder = [(UIView *)firstResponder superview];
            } while (firstResponder && ![firstResponder isKindOfClass:[UISearchBar class]]);
        }
        
        if (![firstResponder isKindOfClass:[UIView class]]) {
            [self failWithError:[NSError KIFErrorWithFormat:@"Checking for an accessibilityIdentifier on an object which isn't a UIView (object is a '%@')", [firstResponder class]] stopTest:YES];
            return KIFTestStepResultFailure;
        }
        
        UIView *firstResponderView = (UIView *)firstResponder;
        KIFTestWaitCondition([[firstResponderView accessibilityIdentifier] isEqualToString:identifier], error, @"Expected accessibility label for first responder to be '%@', got '%@'", identifier, [firstResponder accessibilityLabel]);
        
        return KIFTestStepResultSuccess;
    }];
}

- (void)waitForFirstResponderWithAccessibilityLabel:(NSString *)label traits:(UIAccessibilityTraits)traits
{
    [self runBlock:^KIFTestStepResult(NSError **error) {
        UIResponder *firstResponder = [[[UIApplication sharedApplication] keyWindow] firstResponder];
        
        NSString *foundLabel = firstResponder.accessibilityLabel;
        
        // foundLabel == label checks for the case where both are nil.
        KIFTestWaitCondition(foundLabel == label || [foundLabel isEqualToString:label], error, @"Expected accessibility label for first responder to be '%@', got '%@'", label, foundLabel);
        KIFTestWaitCondition(firstResponder.accessibilityTraits & traits, error, @"Found first responder with accessbility label, but not traits.");
        
        return KIFTestStepResultSuccess;
    }];
}

- (void)waitForFirstResponderWithAccessibilityIdentifier:(NSString *)identifier traits:(UIAccessibilityTraits)traits {
    [self runBlock:^KIFTestStepResult(NSError **error) {
        UIResponder *firstResponder = [[[UIApplication sharedApplication] keyWindow] firstResponder];
        
        if (![firstResponder isKindOfClass:[UIView class]]) {
            [self failWithError:[NSError KIFErrorWithFormat:@"Checking for an accessibilityIdentifier on an object which isn't a UIView (object is a '%@')", [firstResponder class]] stopTest:YES];
            return KIFTestStepResultFailure;
        }
        
        UIView *firstResponderView = (UIView *)firstResponder;
        NSString *foundIdentifier = firstResponderView.accessibilityIdentifier;
        
        // foundLabel == label checks for the case where both are nil.
        KIFTestWaitCondition(foundIdentifier == identifier || [foundIdentifier isEqualToString:identifier], error, @"Expected accessibility label for first responder to be '%@', got '%@'", identifier, foundIdentifier);
        KIFTestWaitCondition(firstResponder.accessibilityTraits & traits, error, @"Found first responder with accessbility label, but not traits.");
        
        return KIFTestStepResultSuccess;
    }];
}

- (UITableViewCell *)waitForCellAtIndexPath:(NSIndexPath *)indexPath inTableViewWithAccessibilityIdentifier:(NSString *)identifier
{
    UITableView *tableView;
    [self waitForAccessibilityElement:NULL view:&tableView withIdentifier:identifier tappable:NO];
    return [self waitForCellAtIndexPath:indexPath inTableView:tableView];
}

- (UITableViewCell *)waitForCellAtIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    if (![tableView isKindOfClass:[UITableView class]]) {
        [self failWithError:[NSError KIFErrorWithFormat:@"View is not a table view"] stopTest:YES];
    }
    
    __block UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (!cell) {
        [self runBlock:^KIFTestStepResult(NSError **error) {
            NSIndexPath *localIndexPath = indexPath;    // We want to reset this every time we run this
            
            if (!cell) {
                // If section < 0, search from the end of the table.
                if (localIndexPath.section < 0) {
                    localIndexPath = [NSIndexPath indexPathForRow:localIndexPath.row inSection:tableView.numberOfSections + localIndexPath.section];
                }
                
                // If row < 0, search from the end of the section.
                if (localIndexPath.row < 0) {
                    localIndexPath = [NSIndexPath indexPathForRow:[tableView numberOfRowsInSection:localIndexPath.section] + localIndexPath.row inSection:localIndexPath.section];
                }
                
                if (localIndexPath.section >= tableView.numberOfSections) {
                    return KIFTestStepResultWait;
                }
                
                if (localIndexPath.row >= [tableView numberOfRowsInSection:localIndexPath.section]) {
                    return KIFTestStepResultWait;
                }
                
                [tableView scrollToRowAtIndexPath:localIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                [self waitForTimeInterval:0.5];
                cell = [tableView cellForRowAtIndexPath:localIndexPath];
            }
            
            return (cell ? KIFTestStepResultSuccess : KIFTestStepResultFailure);
        }];
    }
    
    if (!cell) {
        [self failWithError:[NSError KIFErrorWithFormat: @"Table view cell at index path %@ not found", indexPath] stopTest:YES];
    }
    
    return cell;
}

- (UICollectionViewCell *)waitForCellAtIndexPath:(NSIndexPath *)indexPath inCollectionViewWithAccessibilityIdentifier:(NSString *)identifier
{
    UICollectionView *collectionView;
    [self waitForAccessibilityElement:NULL view:&collectionView withIdentifier:identifier tappable:NO];
    return [self waitForCellAtIndexPath:indexPath inCollectionView:collectionView];
}

- (UICollectionViewCell *)waitForCellAtIndexPath:(NSIndexPath *)indexPath inCollectionView:(UICollectionView *)collectionView
{
    if (![collectionView isKindOfClass:[UICollectionView class]]) {
        [self failWithError:[NSError KIFErrorWithFormat:@"View is not a collection view"] stopTest:YES];
    }
    
    NSInteger section = indexPath.section;
    NSInteger item    = indexPath.item;
    
    __block UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    if (!cell) {
        [self runBlock:^KIFTestStepResult(NSError **error) {
            NSIndexPath *localIndexPath = indexPath;    // We want to reset this every time we run this
            
            // If section < 0, search from the end of the table.
            if (localIndexPath.section < 0) {
                localIndexPath = [NSIndexPath indexPathForRow:localIndexPath.row inSection:collectionView.numberOfSections + localIndexPath.section];
            }
            
            // If item < 0, search from the end of the section.
            if (localIndexPath.row < 0) {
                localIndexPath = [NSIndexPath indexPathForRow:[collectionView numberOfItemsInSection:localIndexPath.section] + localIndexPath.row inSection:localIndexPath.section];
            }
            
            if (section >= collectionView.numberOfSections) {
                return KIFTestStepResultWait;
            }
            
            if (item >= [collectionView numberOfItemsInSection:section]) {
                return KIFTestStepResultWait;
            }
            
            [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally | UICollectionViewScrollPositionCenteredVertically animated:YES];
            [self waitForTimeInterval:0.5];
            cell = [collectionView cellForItemAtIndexPath:indexPath];
            
            return (cell ? KIFTestStepResultSuccess : KIFTestStepResultFailure);
        }];
    }
    
    if (!cell) {
        [self failWithError:[NSError KIFErrorWithFormat: @"Collection view cell at index path %@ not found", indexPath] stopTest:YES];
    }
    return cell;
}

- (void)tapStatusBar
{
    [self runBlock:^KIFTestStepResult(NSError **error) {
        KIFTestWaitCondition(![UIApplication sharedApplication].statusBarHidden, error, @"Expected status bar to be visible.");
        return KIFTestStepResultSuccess;
    }];
    
    UIWindow *statusBarWindow = [[UIApplication sharedApplication] statusBarWindow];
    NSArray *statusBars = [statusBarWindow subviewsWithClassNameOrSuperClassNamePrefix:@"UIStatusBar"];
    
    if (statusBars.count == 0) {
        [self failWithError:[NSError KIFErrorWithFormat: @"Could not find the status bar"] stopTest:YES];
    }
    
    [self tapAccessibilityElement:statusBars[0] inView:statusBars[0]];
}

#pragma mark - Multi-tap methods

#define MULTI_TAP_DELAY 0.05

- (void)multiTapViewWithAccessibilityLabel:(NSString *)label andNumberOfTaps:(NSUInteger)numberOfTaps {
    [self multiTapViewWithAccessibilityLabel:label value:nil traits:UIAccessibilityTraitNone andNumberOfTaps:numberOfTaps];
}

- (void)multiTapViewWithAccessibilityIdentifier:(NSString *)identifier andNumberOfTaps:(NSUInteger)numberOfTaps {
    [self multiTapViewWithAccessibilityIdentifier:identifier value:nil traits:UIAccessibilityTraitNone andNumberOfTaps:numberOfTaps];
}

- (void)multiTapViewWithAccessibilityLabel:(NSString *)label traits:(UIAccessibilityTraits)traits andNumberOfTaps:(NSUInteger)numberOfTaps {
    [self multiTapViewWithAccessibilityLabel:label value:nil traits:traits andNumberOfTaps:numberOfTaps];
}

- (void)multiTapViewWithAccessibilityIdentifier:(NSString *)identifier traits:(UIAccessibilityTraits)traits andNumberOfTaps:(NSUInteger)numberOfTaps {
    [self multiTapViewWithAccessibilityIdentifier:identifier value:nil traits:traits andNumberOfTaps:numberOfTaps];
}

- (void)multiTapViewWithAccessibilityLabel:(NSString *)label value:(NSString *)value traits:(UIAccessibilityTraits)traits andNumberOfTaps:(NSUInteger)numberOfTaps {
    UIView *view = nil;
    UIAccessibilityElement *element = nil;
    
    [self waitForAccessibilityElement:&element view:&view withLabel:label value:value traits:traits tappable:YES];
    [self multiTapAccessibilityElement:element inView:view andNumberOfTaps:numberOfTaps];
}

- (void)multiTapViewWithAccessibilityIdentifier:(NSString *)identifier value:(NSString *)value traits:(UIAccessibilityTraits)traits andNumberOfTaps:(NSUInteger)numberOfTaps {
    UIView *view = nil;
    UIAccessibilityElement *element = nil;
    
    [self waitForAccessibilityElement:&element view:&view withIdentifier:identifier value:value traits:traits tappable:YES];
    [self multiTapAccessibilityElement:element inView:view andNumberOfTaps:numberOfTaps];
}

- (void)multiTapAccessibilityElement:(UIAccessibilityElement *)element inView:(UIView *)view andNumberOfTaps:(NSUInteger)numberOfTaps {
    [self runBlock:^KIFTestStepResult(NSError **error) {
        
        KIFTestWaitCondition(view.isUserInteractionActuallyEnabled, error, @"View is not enabled for interaction");
        
        // If the accessibilityFrame is not set, fallback to the view frame.
        CGRect elementFrame;
        if (CGRectEqualToRect(CGRectZero, element.accessibilityFrame)) {
            elementFrame.origin = CGPointZero;
            elementFrame.size = view.frame.size;
        } else {
            elementFrame = [view.windowOrIdentityWindow convertRect:element.accessibilityFrame toView:view];
        }
        CGPoint tappablePointInElement = [view tappablePointInRect:elementFrame];
        
        // This is mostly redundant of the test in _accessibilityElementWithLabel:
        KIFTestWaitCondition(!isnan(tappablePointInElement.x), error, @"View is not tappable");
        
        for (int i = 0; i < numberOfTaps; ++i) {
            [view tapAtPoint:tappablePointInElement];
            
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, MULTI_TAP_DELAY, false);
        }
        
        KIFTestCondition(![view canBecomeFirstResponder] || [view isDescendantOfFirstResponder], error, @"Failed to make the view into the first responder");
        
        return KIFTestStepResultSuccess;
    }];
    
    // Wait for the view to stabilize.
    [self waitForTimeInterval:0.5];
}

#pragma mark - Pinch Methods

- (void)pinchViewWithAccessibilityIdentifier:(NSString *)identifier atRelativeStartPoints:(NSArray *)relativeStartPoints andRelativeEndPoints:(NSArray *)relativeEndPoints {
    UIView *viewToPinch;
    UIAccessibilityElement *element;
    [self waitForAccessibilityElement:&element view:&viewToPinch withIdentifier:identifier tappable:NO];
    [self pinchAccessibilityElement:element inView:viewToPinch atRelativeStartPoints:relativeStartPoints andRelativeEndPoints:relativeEndPoints];
}

- (void)pinchAccessibilityElement:(UIAccessibilityElement *)element inView:(UIView *)viewToPinch atRelativeStartPoints:(NSArray *)relativeStartPoints andRelativeEndPoints:(NSArray *)relativeEndPoints {
    const NSUInteger kNumberOfPointsInPinchPath = 5;
    
    // Within this method, all geometry is done in the coordinate system of the view to pinch.
    CGRect elementFrame = [viewToPinch.windowOrIdentityWindow convertRect:element.accessibilityFrame toView:viewToPinch];
    
    // Get the relative points (UIPinchGestureRecognizer only supports 2 touches on iOS so hard-coding this should be fine)
    CGPoint relativeStartPoint1 = [relativeStartPoints[0] CGPointValue];
    CGPoint relativeStartPoint2 = [relativeStartPoints[1] CGPointValue];
    CGPoint relativeEndPoint1 = [relativeEndPoints[0] CGPointValue];
    CGPoint relativeEndPoint2 = [relativeEndPoints[1] CGPointValue];
    
    // Start at the middle
    CGPoint pinchStart1 = CGPointMake(elementFrame.size.width * relativeStartPoint1.x, elementFrame.size.height * relativeStartPoint1.y);
    CGPoint pinchStart2 = CGPointMake(elementFrame.size.width * relativeStartPoint2.x, elementFrame.size.height * relativeStartPoint2.y);
    
    // End at points displaced by the horizontal and vertical fractions
    CGPoint pinchEnd1 = CGPointMake(elementFrame.size.width * relativeEndPoint1.x, elementFrame.size.height * relativeEndPoint1.y);
    CGPoint pinchEnd2 = CGPointMake(elementFrame.size.width * relativeEndPoint2.x, elementFrame.size.height * relativeEndPoint2.y);
    
    NSArray *startPoints = @[ [NSValue valueWithCGPoint:pinchStart1], [NSValue valueWithCGPoint:pinchStart2] ];
    NSArray *endPoints = @[ [NSValue valueWithCGPoint:pinchEnd1], [NSValue valueWithCGPoint:pinchEnd2] ];
    [viewToPinch pinchFromStartPoints:startPoints toEndPoints:endPoints steps:kNumberOfPointsInPinchPath];
}

#pragma mark - UISegmentedControl Methods

- (void)tapSegmentAtIndex:(NSInteger)segmentIndex inSegmentedControlWithAccessibilityIdentifier:(NSString *)identifier {
    UIView *view = nil;
    UIAccessibilityElement *element = nil;
    
    [self waitForAccessibilityElement:&element view:&view withIdentifier:identifier tappable:YES];
    [self tapSegmentAtIndex:segmentIndex inAccessibilityElement:element inView:view];
}

- (void)tapSegmentAtIndex:(NSInteger)segmentIndex inAccessibilityElement:(UIAccessibilityElement *)element inView:(UIView *)view {
    [self runBlock:^KIFTestStepResult(NSError **error) {
        
        KIFTestWaitCondition(view.isUserInteractionActuallyEnabled, error, @"View is not enabled for interaction");
        
        // I don't like this but it seem like it's the only way to get the index of the segment
        UIView *targetView;
        UISegmentedControl *segmentedControl = (UISegmentedControl *)view;
        for (UIView *subview in segmentedControl.subviews) {
            NSInteger currentIndex = segmentedControl.subviews.count - [segmentedControl.subviews indexOfObject:subview] - 1;
            
            if (currentIndex == segmentIndex) {
                targetView = subview;
                break;
            }
        }
        
        // If the accessibilityFrame is not set, fallback to the view frame.
        CGRect elementFrame = targetView.accessibilityFrame;
        elementFrame.origin = CGPointZero;
        CGPoint tappablePointInElement = [targetView tappablePointInRect:elementFrame];
        
        // This is mostly redundant of the test in _accessibilityElementWithLabel:
        KIFTestWaitCondition(!isnan(tappablePointInElement.x), error, @"View is not tappable");
        [targetView tapAtPoint:tappablePointInElement];
        
        KIFTestCondition(![view canBecomeFirstResponder] || [view isDescendantOfFirstResponder], error, @"Failed to make the view into the first responder");
        
        return KIFTestStepResultSuccess;
    }];
    
    // Wait for the view to stabilize.
    [self waitForTimeInterval:0.5];
}

@end

