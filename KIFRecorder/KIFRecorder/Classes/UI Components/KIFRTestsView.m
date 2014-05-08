//
//  KIFRTestsViewController.m
//  TSSales
//
//  Created by Morgan Pretty on 27/03/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import "KIFRTestsView.h"
#import "KIFRMenuView.h"
#import "UIApplication+KIFRUtils.h"
#import "KIFRTest.h"
#import "UIGestureRecognizer+KIFRUtils.h"
#import "UIAlertView+KIFRUtils.h"
#import "KIFRTestStepCell.h"
#import "KIFRAddStepView.h"
#import "KIFRTestStep.h"
#import "UIPickerView+KIFRUtils.h"

@interface KIFRTestsView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) KIFRMenuView *menuView;

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) UITableView *testListTableView;
@property (nonatomic, strong) UITableView *testTableView;

// Single Test Stuff
@property (nonatomic, assign) BOOL isViewingTest;
@property (nonatomic, strong) KIFRTest *selectedTest;
@property (nonatomic, assign) NSInteger originalStepsCount;
@property (nonatomic, assign) BOOL isReorderingCell;
@property (nonatomic, strong) UIControl *currentReorderControl;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;

// Add Step Stuff
@property (nonatomic, strong) KIFRAddStepView *addStepView;
@property (nonatomic, assign) BOOL isAddingStep;

@end

@implementation KIFRTestsView

- (id)initWithMenuView:(KIFRMenuView *)menuView {
    if ((self = [super init])) {
        _menuView = menuView;
        
        _backButton = [UIButton new];
        _backButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [_backButton setTitle:@"Back" forState:UIControlStateNormal];
        [_backButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [_backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backButton];
        
        _addButton = [UIButton new];
        _addButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [_addButton setTitle:@"Add" forState:UIControlStateNormal];
        [_addButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [_addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        _addButton.alpha = 0;
        [self addSubview:_addButton];
        
// TODO: Remove this line and get the 'Add Step' stuff working
        _addButton.hidden = YES;
        
        _testListTableView = [UITableView new];
        _testListTableView.delegate = self;
        _testListTableView.dataSource = self;
        [self addSubview:_testListTableView];
        
        _testTableView = [UITableView new];
        _testTableView.delegate = self;
        _testTableView.dataSource = self;
        [self addSubview:_testTableView];
        
        _addStepView = [KIFRAddStepView new];
        _addStepView.alpha = 0;
        [self addSubview:_addStepView];
        
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressedCell:)];
        [_testTableView addGestureRecognizer:_longPressGestureRecognizer];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.backButton.frame = CGRectMake(5, 5, 60, 40);
    self.addButton.frame = CGRectMake(self.kifrWidth - 60 - 5, 5, 60, 40);
    
    // ignore the table's sizes if the KIFRMenuView is animating
    if (self.parentIsAnimating) {
        return;
    }
    
    if (!self.isViewingTest) {
        self.testListTableView.frame = CGRectMake(0, 55, self.kifrWidth, self.kifrHeight - 50);
        self.testTableView.frame = CGRectMake(self.kifrWidth, 55, self.kifrWidth, self.kifrHeight - 50);
    }
    else {
        self.testListTableView.frame = CGRectMake(-self.kifrWidth, 55, self.kifrWidth, self.kifrHeight - 50);
        self.testTableView.frame = CGRectMake(0, 55, self.kifrWidth, self.kifrHeight - 50);
    }
    
    self.addStepView.frame = self.testTableView.frame;
}

#pragma mark - UIControl Handlers

- (void)backButtonPressed:(id)sender {
    if (self.isAddingStep) {
        [self endEditing:YES];
        [UIPickerView dismiss];
        
        __weak KIFRTestsView *weakSelf = self;
        [UIView animateWithDuration:0.3 animations:^{
            KIFRTestsView *strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            
            strongSelf.addStepView.alpha = 0;
        } completion:^(BOOL finished) {
            KIFRTestsView *strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            
            [strongSelf.backButton setTitle:@"Back" forState:UIControlStateNormal];
            [strongSelf.addButton setTitle:@"Add" forState:UIControlStateNormal];
            strongSelf.testTableView.userInteractionEnabled = YES;
            strongSelf.isAddingStep = NO;
        }];
    }
    else if (self.isViewingTest) {
        // Determine if anything changed (Currently we can only change the order or delete steps)
        BOOL somethingChanged = (self.originalStepsCount != self.selectedTest.testStepsArray.count);
        
        // If the number of steps hasn't changed, check if the order has changed
        if (!somethingChanged) {
            for (int i = 0; i < self.selectedTest.testStepsArray.count; ++i) {
                KIFRTestStep *step = self.selectedTest.testStepsArray[i];
                if (step.originalIndex != i) {
                    somethingChanged = YES;
                    break;
                }
            }
        }
        
        if (!somethingChanged) {
            self.isViewingTest = NO;
            self.selectedTest = nil;
        }
        else {
            __weak KIFRTestsView *weakSelf = self;
            [UIAlertView showWithTitle:@"" message:@"Would you like to save the changes to this test?" cancelButtonTitle:@"NO" otherButtonTitles:@[ @"YES" ] andCallback:^(UIAlertView *alertView, NSInteger selectedButtonIndex) {
                KIFRTestsView *strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                
                if (selectedButtonIndex == 1) {
                    // They chose Yes, so save the changes
                    [strongSelf.selectedTest saveCurrentState];
                    
                    // Give the tester feedback that saving succeeded
                    [UIAlertView showWithTitle:@"Save Successful" message:@"Changes saved" cancelButtonTitle:@"OK" otherButtonTitles:nil andCallback:nil];
                }
                
                [strongSelf updateTests];
                [strongSelf.testListTableView reloadData];
                strongSelf.isViewingTest = NO;
                strongSelf.selectedTest = nil;
            }];
        }
    }
    else {
        if (self.menuView) {
            // Note: This will hide the 'KIFRTestsView' and go back to the main 'KIFRMenuView'
            [self.menuView setExpanded:YES animated:YES];
        }
    }
}

- (void)addButtonPressed:(id)sender {
    if (!self.isAddingStep) {
        self.testTableView.userInteractionEnabled = NO;
        
        __weak KIFRTestsView *weakSelf = self;
        [UIView animateWithDuration:0.3 animations:^{
            KIFRTestsView *strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            
            strongSelf.addStepView.alpha = 1;
        } completion:^(BOOL finished) {
            KIFRTestsView *strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            
            [strongSelf.backButton setTitle:@"Cancel" forState:UIControlStateNormal];
            [strongSelf.addButton setTitle:@"Confirm" forState:UIControlStateNormal];
            strongSelf.isAddingStep = YES;
        }];
    }
    else {
        // Are we adding a step to the current test?
//        if (self.selectedTest.isCurrentTest) {
//            
//        }
        KIFRTestStep *newStep = [self.addStepView createKIFRStep];
        [self.selectedTest.testStepsArray addObject:newStep];
        [self.testTableView reloadData];
        
        // Now hide the 'AddStepView'
        [self backButtonPressed:nil];
    }
}

- (void)longPressedCell:(UILongPressGestureRecognizer *)sender {
    if (self.currentReorderControl) {
        switch (sender.state) {
            case UIGestureRecognizerStateChanged:
                [self.currentReorderControl continueTrackingWithTouch:sender.kifrTouches[0] withEvent:nil];
                break;
                
            case UIGestureRecognizerStateCancelled:
                self.isReorderingCell = NO;
                self.testTableView.editing = NO;
                [self.currentReorderControl cancelTrackingWithEvent:nil];
                break;
                
            case UIGestureRecognizerStateEnded: {
                [CATransaction begin];
                [CATransaction setCompletionBlock:^{
                    self.isReorderingCell = NO;
                    self.testTableView.editing = NO;
                    [self.testTableView reloadData];
                }];
                [self.currentReorderControl endTrackingWithTouch:sender.kifrTouches[0] withEvent:nil];
                self.currentReorderControl = nil;
                [CATransaction commit];
            } break;
                
            default:
                break;
        }
    }
    else {
        for (UITableViewCell *cell in self.testTableView.visibleCells) {
            CGPoint localPoint = [sender locationInView:cell];
            
            if ([cell pointInside:localPoint withEvent:nil]) {
                self.isReorderingCell = YES;
                self.testTableView.editing = YES;
                
                self.currentReorderControl = (UIControl *)[cell subviewWithClassName:@"UITableViewCellReorderControl"];
                [self.currentReorderControl beginTrackingWithTouch:sender.kifrTouches[0] withEvent:nil];
                break;
            }
        }
    }
}

#pragma mark - Content

- (void)updateTests {
    self.testArray = [UIApplication sharedApplication].getSavedTests;
}

- (void)setTestArray:(NSArray *)testArray {
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastModifiedDate" ascending:YES];
    _testArray = [testArray sortedArrayUsingDescriptors:@[ sortDescriptor ]];
    [self.testListTableView reloadData];
}

- (void)reset {
    self.isViewingTest = NO;
    self.selectedTest = nil;
}

#pragma mark - UITableView Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.testTableView) {
        return self.selectedTest.testStepsArray.count;
    }
    
    // Add one extra for the Current Test
    return self.testArray.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.testListTableView) {
        static NSString *identifier = @"TestCell";
    
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
    
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        KIFRTest *test;
        
        // Row 0 is the Current Test
        if (indexPath.row == 0) {
            cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
            cell.textLabel.text = @"Current Test";
        }
        else {
            NSInteger testIndex = indexPath.row - 1;
            test = self.testArray[testIndex];
            cell.textLabel.text = test.testName;
        }
        
        cell.recursiveKIFRShouldIgnore = YES;
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
        [CATransaction commit];
        
        return cell;
    }
    else {
        KIFRTestStepCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([KIFRTestStepCell class])];
        if (!cell) {
            cell = [[KIFRTestStepCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([KIFRTestStepCell class])];
        }
        
        [cell updateWithStepNumber:indexPath.row andStepString:[self.selectedTest.testStepsArray[indexPath.row] readableString]];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == self.testListTableView) {
        // Row 0 is the Current Test
        if (indexPath.row == 0) {
            self.selectedTest = [[KIFRTest currentTest] copy];
        }
        else {
            self.selectedTest = self.testArray[indexPath.row - 1];
        }
        
        self.originalStepsCount = self.selectedTest.testStepsArray.count;
        [self.testTableView reloadData];
        self.isViewingTest = YES;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.testTableView) {
        return YES;
    }
    
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.testTableView) {
        return YES;
    }
    
    return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    id step = self.selectedTest.testStepsArray[sourceIndexPath.row];
    
    [self.selectedTest.testStepsArray removeObject:step];
    [self.selectedTest.testStepsArray insertObject:step atIndex:destinationIndexPath.row];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isReorderingCell) {
        return UITableViewCellEditingStyleNone;
    }
    
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.selectedTest.testStepsArray removeObjectAtIndex:indexPath.row];
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationNone];
        [tableView endUpdates];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - Animations

- (void)setIsViewingTest:(BOOL)isViewingTest {
    _isViewingTest = isViewingTest;
    
    __weak KIFRTestsView *weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        KIFRTestsView *strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        strongSelf.addButton.alpha = isViewingTest;
        [strongSelf setNeedsLayout];
        [strongSelf layoutIfNeeded];
    }];
}

@end
