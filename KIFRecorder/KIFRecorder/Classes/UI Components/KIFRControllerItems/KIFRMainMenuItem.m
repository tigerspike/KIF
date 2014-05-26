//
//  KIFRMainMenuItem.m
//  KIFRecorder
//
//  Created by Morgan Pretty on 22/05/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import "KIFRMainMenuItem.h"
#import "KIFRViewTestsItem.h"
#import "KIFRecorder.h"
#import "KIFRAddVerificationStepUI.h"

typedef enum {
    MainMenuItemViewTests = 0,
    MainMenuItemAddVerificationStep,
    MainMenuItemExport
} MainMenuItem;

@interface KIFRMainMenuItem ()

@property (nonatomic, strong) NSArray *menuTitles;

@end

@implementation KIFRMainMenuItem

- (id)init {
    if ((self = [super init])) {
        _menuTitles = @[
                        @"View Tests",
                        @"Add Verification Step",
                        @"Export",
                        ];
    }
    
    return self;
}

#pragma mark - KIFRControllerMenu

- (NSInteger)numberOfItems {
    return self.menuTitles.count;
}

- (NSString *)titleForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.menuTitles[indexPath.row];
}

- (void)controller:(KIFRController *)controller didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case MainMenuItemViewTests: {
            [[KIFRController sharedInstance] pushItem:[[KIFRViewTestsItem alloc] initWithTestArray:[KIFRecorder getSavedTests]] animated:YES];
        } break;
            
        case MainMenuItemAddVerificationStep: {
            // Add the verification step UI
            [[KIFRAddVerificationStepUI sharedInstance] show];
            
            [UIView animateWithDuration:0.3 animations:^{
                [KIFRController sharedInstance].alpha = 0;
            } completion:^(BOOL finished) {
                [[KIFRController sharedInstance] popToRootItemAnimated:NO];
                [KIFRController sharedInstance].alpha = 0;
            }];
        } break;
            
        case MainMenuItemExport: {
            [KIFRecorder exportTests];
        } break;
    }
}

@end
