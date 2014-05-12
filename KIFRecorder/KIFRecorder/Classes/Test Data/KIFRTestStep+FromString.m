//
//  KIFRTestStep+FromString.m
//  PTV
//
//  Created by Morgan Pretty on 31/03/2014.
//  Copyright (c) 2014 PTV. All rights reserved.
//

#import "KIFRTestStep+FromString.h"

@implementation KIFRTestStep (FromString)

- (void)generateStepDataFromString:(NSString *)stepString {
    self.stepType = [self stepTypeForString:stepString];
    self.testString = stepString;
    
    switch (self.stepType) {
        case KIFRStepTypeWait: {
            NSString *numberString;
            NSScanner *scanner = [NSScanner scannerWithString:stepString];
            NSCharacterSet *numberSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
            [scanner scanUpToCharactersFromSet:numberSet intoString:nil];
            [scanner scanCharactersFromSet:numberSet intoString:&numberString];
            
            CGFloat waitTime = [numberString floatValue];
            self.readableString = [NSString stringWithFormat:@"Wait for %0.2f seconds.", waitTime];
        } break;
            
        case KIFRStepTypeTap: {
            NSString *identifierString;
            NSScanner *scanner = [NSScanner scannerWithString:stepString];
            NSCharacterSet *atSet = [NSCharacterSet characterSetWithCharactersInString:@"@"];
            NSCharacterSet *closeSet = [NSCharacterSet characterSetWithCharactersInString:@"]"];
            [scanner scanUpToCharactersFromSet:atSet intoString:nil];
            [scanner scanUpToCharactersFromSet:closeSet intoString:&identifierString];
            
            // Remove the '@""' from the string
            identifierString = [identifierString substringWithRange:NSMakeRange(2, identifierString.length - 3)];
            
            self.readableString = [NSString stringWithFormat:@"Tap on view '%@'.", identifierString];
        } break;
            
        case KIFRStepTypeWaitForTableCell:
        case KIFRStepTypeTapTableCell: {
            NSString *rowString;
            NSString *sectonString;
            NSString *identifierString;
            NSScanner *scanner = [NSScanner scannerWithString:stepString];
            NSString *sectionStartString = @" inSection:";
            NSCharacterSet *parameterSet = [NSCharacterSet characterSetWithCharactersInString:@":"];
            NSCharacterSet *closeSet = [NSCharacterSet characterSetWithCharactersInString:@"]"];
            NSCharacterSet *atSet = [NSCharacterSet characterSetWithCharactersInString:@"@"];
            
            // Scan through the string
            [scanner scanUpToCharactersFromSet:parameterSet intoString:nil];
            [scanner scanUpToString:sectionStartString intoString:&rowString];
            [scanner scanUpToCharactersFromSet:parameterSet intoString:nil];
            [scanner scanUpToCharactersFromSet:closeSet intoString:&sectonString];
            [scanner scanUpToCharactersFromSet:atSet intoString:nil];
            [scanner scanUpToCharactersFromSet:closeSet intoString:&identifierString];
            
            NSInteger row = [[rowString stringByReplacingOccurrencesOfString:@":" withString:@""] integerValue];
            NSInteger section = [[sectonString stringByReplacingOccurrencesOfString:@":" withString:@""] integerValue];
            
            // Remove the '@""' from the string
            identifierString = [identifierString substringWithRange:NSMakeRange(2, identifierString.length - 3)];
            
            if (self.stepType == KIFRStepTypeWaitForTableCell) {
                self.readableString = [NSString stringWithFormat:@"Wait for cell at (%li, %li) in the table '%@'.", (long)row, (long)section, identifierString];
            }
            else if (self.stepType == KIFRStepTypeTapTableCell) {
                self.readableString = [NSString stringWithFormat:@"Tap cell at (%li, %li) in the table '%@'.", (long)row, (long)section, identifierString];
            }
        } break;
            
        case KIFRStepTypeScroll: {
            NSString *identifierString;
            NSString *fractionHorizString;
            NSString *fractionVertString;
            NSScanner *scanner = [NSScanner scannerWithString:stepString];
            NSString *fractionHorizStartString = @" byFractionOfSizeHorizontal:";
            NSString *verticalStartString = @" vertical:";
            NSCharacterSet *parameterSet = [NSCharacterSet characterSetWithCharactersInString:@":"];
            NSCharacterSet *closeSet = [NSCharacterSet characterSetWithCharactersInString:@"]"];
            NSCharacterSet *atSet = [NSCharacterSet characterSetWithCharactersInString:@"@"];
            [scanner scanUpToCharactersFromSet:atSet intoString:nil];
            [scanner scanUpToString:fractionHorizStartString intoString:&identifierString];
            [scanner scanUpToCharactersFromSet:parameterSet intoString:nil];
            [scanner scanUpToString:verticalStartString intoString:&fractionHorizString];
            [scanner scanUpToCharactersFromSet:parameterSet intoString:nil];
            [scanner scanUpToCharactersFromSet:closeSet intoString:&fractionVertString];
            
            // Remove the '@""' from the string
            identifierString = [identifierString substringWithRange:NSMakeRange(2, identifierString.length - 3)];
            
            CGFloat fractionHoriz = [[fractionHorizString stringByReplacingOccurrencesOfString:@":" withString:@""] floatValue];
            CGFloat fractionVert = [[fractionVertString stringByReplacingOccurrencesOfString:@":" withString:@""] floatValue];
            self.readableString = [NSString stringWithFormat:@"Scroll view '%@' by %.0f%% width and %.0f%% height.", identifierString, (fractionHoriz * 100), (fractionVert * 100)];
        } break;
            
        case KIFRStepTypeEnterText: {
            NSString *textString;
            NSScanner *scanner = [NSScanner scannerWithString:stepString];
            NSCharacterSet *atSet = [NSCharacterSet characterSetWithCharactersInString:@"@"];
            NSCharacterSet *closeSet = [NSCharacterSet characterSetWithCharactersInString:@"]"];
            [scanner scanUpToCharactersFromSet:atSet intoString:nil];
            [scanner scanUpToCharactersFromSet:closeSet intoString:&textString];
            
            // Remove the '@""' from the string
            textString = [textString substringWithRange:NSMakeRange(2, textString.length - 3)];
            
            self.readableString = [NSString stringWithFormat:@"Enter text '%@' in to selected field.", textString];
        } break;
            
        default:
            self.readableString = @"Unknown Step";
            break;
    }
}

- (KIFRStepType)stepTypeForString:(NSString *)stepString {
    static NSString *stepStartString = @"    [tester ";
    if ([stepString rangeOfString:stepStartString].location != NSNotFound) {
        stepString = [stepString substringFromIndex:stepStartString.length];
    }
    
    if ([stepString rangeOfString:[[self class] waitStepString]].location != NSNotFound) {
        return KIFRStepTypeWait;
    }
    else if ([stepString rangeOfString:[[self class] tapStep]].location != NSNotFound) {
        return KIFRStepTypeTap;
    }
    else if ([stepString rangeOfString:[[self class] waitForTableCellStep]].location != NSNotFound) {
        return KIFRStepTypeWaitForTableCell;
    }
    else if ([stepString rangeOfString:[[self class] tapTableCellStep]].location != NSNotFound) {
        return KIFRStepTypeTapTableCell;
    }
    else if ([stepString rangeOfString:[[self class] scrollStep]].location != NSNotFound) {
        return KIFRStepTypeScroll;
    }
    else if ([stepString rangeOfString:[[self class] enterTextStep]].location != NSNotFound) {
        return KIFRStepTypeEnterText;
    }
    
    return KIFRStepTypeUnknown;
}

- (BOOL)hasExtraLine {
    switch (self.stepType) {
        case KIFRStepTypeTapTableCell:
            return YES;
            
        default:
            return NO;
    }
}

#pragma mark - Step Strings

+ (NSString *)waitStepString {
    return @"waitForTimeInterval:";
}

+ (NSString *)tapStep {
    return @"tapViewWithAccessibilityIdentifier:";
}

+ (NSString *)waitForTableCellStep {
    return @"waitForRowAtIndexPath:";
}

+ (NSString *)tapTableCellStep {
    return @"tapRowAtIndexPath:";
}

+ (NSString *)scrollStep {
    return @"scrollViewWithAccessibilityIdentifier:";
}

+ (NSString *)enterTextStep {
    return @"enterTextIntoCurrentFirstResponder:";
}

@end
