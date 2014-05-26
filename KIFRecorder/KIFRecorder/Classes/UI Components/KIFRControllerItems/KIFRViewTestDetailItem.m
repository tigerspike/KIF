//
//  KIFRViewTestDetailItem.m
//  KIFRecorder
//
//  Created by Morgan Pretty on 26/05/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import "KIFRViewTestDetailItem.h"
#import "KIFRTest.h"
#import "KIFRTestStepCell.h"
#import "UIGestureRecognizer+KIFRUtils.h"

@interface KIFRViewTestDetailItem () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) KIFRTest *test;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;

@property (nonatomic, assign) BOOL isReorderingCell;
@property (nonatomic, strong) UIControl *currentReorderControl;

@end

@implementation KIFRViewTestDetailItem

- (instancetype)initWithTest:(KIFRTest *)test {
    if ((self = [super init])) {
        _test = test;
        
        _tableView = [UITableView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressedCell:)];
        [_tableView addGestureRecognizer:_longPressGestureRecognizer];
    }
    
    return self;
}

#pragma mark - UIControl Handlers

- (void)longPressedCell:(UILongPressGestureRecognizer *)sender {
    if (self.currentReorderControl) {
        switch (sender.state) {
            case UIGestureRecognizerStateChanged:
                [self.currentReorderControl continueTrackingWithTouch:sender.kifrTouches[0] withEvent:nil];
                break;
                
            case UIGestureRecognizerStateCancelled:
                self.isReorderingCell = NO;
                self.tableView.editing = NO;
                [self.currentReorderControl cancelTrackingWithEvent:nil];
                break;
                
            case UIGestureRecognizerStateEnded: {
                [CATransaction begin];
                [CATransaction setCompletionBlock:^{
                    self.isReorderingCell = NO;
                    self.tableView.editing = NO;
                    [self.tableView reloadData];
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
        for (UITableViewCell *cell in self.tableView.visibleCells) {
            CGPoint localPoint = [sender locationInView:cell];
            
            if ([cell pointInside:localPoint withEvent:nil]) {
                self.isReorderingCell = YES;
                self.tableView.editing = YES;
                
                self.currentReorderControl = (UIControl *)[cell subviewWithClassName:@"UITableViewCellReorderControl"];
                [self.currentReorderControl beginTrackingWithTouch:sender.kifrTouches[0] withEvent:nil];
                break;
            }
        }
    }
}

#pragma mark - KIFRControllerView

- (NSInteger)numberOfItems {
    return 1;
}

- (UIView *)contentViewForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.tableView;
}

#pragma mark - UITableView Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.test.testStepsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KIFRTestStepCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([KIFRTestStepCell class])];
    if (!cell) {
        cell = [[KIFRTestStepCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([KIFRTestStepCell class])];
    }
    
    [cell updateWithStepNumber:indexPath.row andStepString:[self.test.testStepsArray[indexPath.row] readableString]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    id step = self.test.testStepsArray[sourceIndexPath.row];
    
    [self.test.testStepsArray removeObject:step];
    [self.test.testStepsArray insertObject:step atIndex:destinationIndexPath.row];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isReorderingCell) {
        return UITableViewCellEditingStyleNone;
    }
    
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.test.testStepsArray removeObjectAtIndex:indexPath.row];
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationNone];
        [tableView endUpdates];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

@end
