//
//  KIFRecorder.m
//  KIFRecorder
//
//  Created by Morgan Pretty on 14/05/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import "KIFRecorder.h"
#import "UIWindow+KIFRUtils.h"
#import "UIGestureRecognizer+KIFRUtils.h"
#import "UIApplication+KIFRUtils.h"
#import "UIAlertView+KIFRUtils.h"
#import "KIFRTest.h"
#import "KIFRTestStep.h"
#import "UIDatePicker+KIFRUtils.h"
#import "NSObject+KIFRUtils_Networking.h"
#import <objc/runtime.h>

@implementation KIFRecorder

+ (instancetype)sharedInstance {
    static KIFRecorder *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [KIFRecorder new];
    });
    
    return sharedInstance;
}

+ (void)setupRecording {
    [[KIFRecorder sharedInstance] swizzleApp];
}

#pragma mark - Swizzle Methods

static inline void Swizzle(Class c, SEL orig, SEL new) {
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, new);
    if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_exchangeImplementations(origMethod, newMethod);
}

- (void)swizzleApp {
    // We need to swizzle the below methods in order to record the user's actions correctly and stop the recorder for doing things which we don't currently support (ie. flinging)
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Swizzle([UIPinchGestureRecognizer class], @selector(touchesBegan:withEvent:), @selector(KIFR_touchesBegan:withEvent:));
        Swizzle([UIPinchGestureRecognizer class], @selector(velocity), @selector(KIFR_velocity));
        Swizzle([UIPanGestureRecognizer class], @selector(velocityInView:), @selector(KIFR_velocityInView:));
        Swizzle(NSClassFromString(@"UIPickerTableView"), @selector(_scrollingFinished), @selector(KIFR_scrollingFinished));
        
        // We will need to add the recording wrapper to the Window
        Swizzle([UIWindow class], @selector(makeKeyAndVisible), @selector(KIFR_makeKeyAndVisible));
        
        // Intercept HTTP request completion methods - AFURLConnectionOperation's delegate 'connectionDidFinishLoading:' and ASIHTTPRequest's 'markAsFinished'
        Swizzle(NSClassFromString(@"AFURLConnectionOperation"), @selector(connectionDidFinishLoading:), @selector(KIFR_connectionDidFinishLoading:));
        Swizzle(NSClassFromString(@"ASIHTTPRequest"), NSSelectorFromString(@"markAsFinished"), @selector(KIFR_markAsFinished));
        
        // Intercept UIApplication's 'sendEvent:' method
        Swizzle([UIApplication class], @selector(sendEvent:), @selector(KIFR_sendEvent:));
    });
}

#pragma mark - TestEvent Data Management Methods

+ (NSArray *)getSavedTests {
    NSString *docsDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:docsDir error:nil];
    NSArray *kifrTests = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.kifr'"]];
    
    NSMutableArray *existingTestArray = [NSMutableArray arrayWithCapacity:kifrTests.count];
    for (NSString *testFileName in kifrTests) {
        [existingTestArray addObject:[[KIFRTest alloc] initWithFileName:testFileName]];
    }
    
    return existingTestArray;
}

+ (void)exportTests {
    [UIAlertView showWithTitle:@"Export Test" message:@"What would you like to call the test?" cancelButtonTitle:@"Cancel" otherButtonTitles:@[ @"Export" ] style:UIAlertViewStylePlainTextInput andCallback:^(UIAlertView *alertView, NSInteger selectedButtonIndex) {
        if (selectedButtonIndex == 1) {
            UITextField *textField = [alertView textFieldAtIndex:0];
            
            if (textField.text.length == 0) {
                // If there is no test name, throw and error and try again
                [UIAlertView showWithTitle:@"Error" message:@"Please enter a name for the test" cancelButtonTitle:@"OK" otherButtonTitles:nil andCallback:^(UIAlertView *alertView, NSInteger selectedButtonIndex) {
                    [KIFRecorder exportTests];
                }];
            }
            else {
                // Otherwise export the test
                [KIFRecorder exportTestWithName:textField.text canReplaceOldTest:NO];
            }
        }
    }];
}

+ (void)exportTestWithName:(NSString *)testName canReplaceOldTest:(BOOL)canReplaceOldTest {
    // Make the test name acceptable
    NSString *capitalizedFirstCharacter = [[NSString stringWithFormat:@"%c", [testName characterAtIndex:0]] uppercaseString];
    testName = [NSString stringWithFormat:@"%@%@", capitalizedFirstCharacter, [testName substringFromIndex:1]];
    testName = [testName stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // If there is already a test with that name, Throw an alert
    NSString *docsDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    if (!canReplaceOldTest && [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", docsDir, testName]]) {
        [UIAlertView showWithTitle:@"Error" message:@"A test with that name already exists! Please choose another name." cancelButtonTitle:@"OK" otherButtonTitles:nil andCallback:^(UIAlertView *alertView, NSInteger selectedButtonIndex) {
            [KIFRecorder exportTests];
        }];
        
        return;
    }
    
    // Generate the new test method (Note: Method name MUST start with 'test')
    NSMutableString *testString = [NSMutableString new];
    [testString appendString:@"\n\n"];
    if (testName.length >= 4 && ([[testName substringToIndex:4] caseInsensitiveCompare:@"test"] == NSOrderedSame)) {
        [testString appendFormat:@"- (void)test%@ {", [testName substringFromIndex:4]];
    }
    else {
        [testString appendFormat:@"- (void)test%@ {", testName];
    }
    
    for (KIFRTestStep *step in [KIFRTest currentTest].testStepsArray) {
        if (step.stepType == KIFRStepTypeUnknown) {
            NSLog(@"Warning! Attempted to export a recorded action with no export logic!");
            continue;
        }
        
        [testString appendString:step.testString];
    }
    
    [testString appendString:@"\n    [tester waitForTimeInterval:0.5];"];
    [testString appendString:@"\n}\n"];
    
    // Log and save the test to a file
    NSLog(@"%@", testString);
    
    [testString writeToFile:[NSString stringWithFormat:@"%@/%@.kifr", docsDir, testName] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    // Log the number of API requests and save the json files to a folder with the same name as the test
    NSLog(@"%lu requests made during test.", (unsigned long)[KIFRTest currentTest].testRequestsArray.count);
    [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@", docsDir, testName] withIntermediateDirectories:YES attributes:nil error:nil];
    
    for (int i = 0; i < [KIFRTest currentTest].testRequestsArray.count; ++i) {
        NSDictionary *requestDictionary = [KIFRTest currentTest].testRequestsArray[i];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:requestDictionary options:0 error:nil];
        
        [jsonData writeToFile:[NSString stringWithFormat:@"%@/%@/%@Request%lu.json", docsDir, testName, testName, (unsigned long)i] atomically:YES];
    }
    
    // Giev the tester feedback that exporting succeeded
    [UIAlertView showWithTitle:@"Export Successful" message:[NSString stringWithFormat:@"Test saved as '%@'", testName] cancelButtonTitle:@"OK" otherButtonTitles:nil andCallback:nil];
}

@end
