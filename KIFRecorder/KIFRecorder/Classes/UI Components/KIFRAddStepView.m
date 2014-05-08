//
//  KIFRAddStepView.m
//  PTV
//
//  Created by Morgan Pretty on 31/03/2014.
//  Copyright (c) 2014 PTV. All rights reserved.
//

#import "KIFRAddStepView.h"
#import "UIPickerView+KIFRUtils.h"
#import "KIFRTestStep.h"
#import "KIFRStepTypeCell.h"
#import "KIFRWaitStepCell.h"

@interface KIFRAddStepView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) KIFRStepType stepType;

// Wait Step
@property (nonatomic, assign) CGFloat waitDuration;

@end

@implementation KIFRAddStepView

- (id)init {
    if ((self = [super init])) {
        self.dataSource = self;
        self.delegate = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        _stepType = KIFRStepTypeUnknown;
        
        self.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}

#pragma mark - UITableView Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.stepType == KIFRStepTypeUnknown) {
        return 1;
    }
    
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return [KIFRStepTypeCell cellHeight];
    }
    
    switch (self.stepType) {
        case KIFRStepTypeWait:
            return [KIFRWaitStepCell cellHeight];
            
        default:
            break;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        NSString *cellIdentifier = NSStringFromClass([KIFRStepTypeCell class]);
        
        KIFRStepTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[KIFRStepTypeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        [cell updateWithStepType:self.stepType];
        
        return cell;
    }
    else {
        switch (self.stepType) {
            case KIFRStepTypeWait: {
                NSString *cellIdentifier = NSStringFromClass([KIFRWaitStepCell class]);
                
                KIFRWaitStepCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if (!cell) {
                    cell = [[KIFRWaitStepCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                }
                
                return cell;
            }
                
            default:
                break;
        }
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        NSArray *stepTypeArray = @[ @(KIFRStepTypeUnknown), @(KIFRStepTypeWait) ];
        NSArray *stepTypeStringArray = @[ @"None", @"Wait" ];
        
        __weak KIFRAddStepView *weakSelf = self;
        [UIPickerView showWithContentArray:stepTypeStringArray selectedIndex:0 cancelButtonTitle:@"Cancel" otherButtonTitles:@[ @"Done" ] andCallback:^(UIPickerView *pickerView, NSInteger selectedButtonIndex, NSInteger selectedItemIndex) {
            KIFRAddStepView *strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            
            if (selectedButtonIndex == 1) {
                KIFRStepTypeCell *cell = (KIFRStepTypeCell *)[strongSelf cellForRowAtIndexPath:indexPath];
                
                if (strongSelf.stepType != [stepTypeArray[selectedItemIndex] integerValue]) {
                    strongSelf.stepType = (KIFRStepType)[stepTypeArray[selectedItemIndex] integerValue];
                    [cell updateWithStepType:(KIFRStepType)[stepTypeArray[selectedItemIndex] integerValue]];
                    
                    [strongSelf reloadData];
                }
            }
        }];
    }
}

#pragma mark - Generate a KIFRStep

- (KIFRTestStep *)createKIFRStep {
    KIFRTestStep *step = [KIFRTestStep new];
    step.stepType = self.stepType;
    
    switch (self.stepType) {
        case KIFRStepTypeWait: {
            step.readableString = [NSString stringWithFormat:@"Wait for %0.2f seconds.", self.waitDuration];
        } break;
            
        default:
            break;
    }
    
    return step;
}

@end
