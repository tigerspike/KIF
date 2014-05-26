//
//  KIFRViewTestsItem.m
//  KIFRecorder
//
//  Created by Morgan Pretty on 23/05/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import "KIFRViewTestsItem.h"
#import "KIFRTest.h"
#import "KIFRViewTestDetailItem.h"

@interface KIFRViewTestsItem () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *testArray;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation KIFRViewTestsItem

- (instancetype)initWithTestArray:(NSArray *)testArray {
    if ((self = [super init])) {
        _testArray = testArray;
        
        _tableView = [UITableView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    
    return self;
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
    // Add one extra for the Current Test
    return self.testArray.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Row 0 is the Current Test
    KIFRTest *selectedTest;
    if (indexPath.row == 0) {
        selectedTest = [[KIFRTest currentTest] copy];
    }
    else {
        selectedTest = self.testArray[indexPath.row - 1];
    }
    
    [[KIFRController sharedInstance] pushItem:[[KIFRViewTestDetailItem alloc] initWithTest:selectedTest] animated:YES];
}

@end
