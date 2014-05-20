//
//  KIFRAddVerificationStepUI.m
//  KIFRecorder
//
//  Created by Morgan Pretty on 19/05/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import "KIFRAddVerificationStepUI.h"
#import "KIFRTestEvent.h"
#import "KIFRVerificationStepCell.h"
#import "KIFRMenuView.h"
#import "KIFRTest.h"

@interface KIFRAddVerificationStepUI () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIWindow *contentWindow;
@property (nonatomic, strong) UILabel *instructionLabel;
@property (nonatomic, strong) UITableView *selectControlTableView;

@property (nonatomic, strong) KIFRTestEvent *eventData;
@property (nonatomic, strong) KIFRTargetInfo *selectedTargetInfo;

@end

@implementation KIFRAddVerificationStepUI

+ (instancetype)sharedInstance {
    static KIFRAddVerificationStepUI *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [KIFRAddVerificationStepUI new];
    });
    
    return sharedInstance;
}

- (id)init {
    if ((self = [super init])) {
        _contentWindow = [UIWindow new];
        _contentWindow.windowLevel = UIWindowLevelStatusBar;
        _contentWindow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
        _contentWindow.alpha = 0;
        
        _instructionLabel = [UILabel new];
        _instructionLabel.font = [UIFont boldSystemFontOfSize:16];
        _instructionLabel.text = @"Select control to verify";
        _instructionLabel.textColor = [UIColor redColor];
        _instructionLabel.textAlignment = NSTextAlignmentCenter;
        [_contentWindow addSubview:_instructionLabel];
        
        _selectControlTableView = [UITableView new];
        _selectControlTableView.dataSource = self;
        _selectControlTableView.delegate = self;
        _selectControlTableView.rowHeight = [KIFRVerificationStepCell cellHeight];
        [_contentWindow addSubview:_selectControlTableView];
    }
    
    return self;
}

#pragma mark - Display

- (void)show {
    [self layout];
    
    self.isAddingStep = YES;
    self.eventData = nil;
    self.contentWindow.hidden = NO;
    
    __weak KIFRAddVerificationStepUI *weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        KIFRAddVerificationStepUI *strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
       strongSelf.contentWindow.alpha = 1;
    } completion:^(BOOL finished) {
        KIFRAddVerificationStepUI *strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        [strongSelf.contentWindow makeKeyAndVisible];
    }];
}

- (void)hideIfNeededForTouches:(NSArray *)touches {
    BOOL shouldHide = YES;
    for (UITouch *touch in touches) {
        CGPoint localPoint = [touch locationInView:self.selectControlTableView];
        if ([self.selectControlTableView pointInside:localPoint withEvent:nil]) {
            shouldHide = NO;
        }
    }
    
    if (shouldHide) {
        [self hide];
    }
}

- (void)hide {
    __weak KIFRAddVerificationStepUI *weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        KIFRAddVerificationStepUI *strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        strongSelf.contentWindow.alpha = 0;
    } completion:^(BOOL finished) {
        KIFRAddVerificationStepUI *strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        // This will animate the menu view back in
        strongSelf.eventData = nil;
        strongSelf.isAddingStep = NO;
        strongSelf.isProcessingStep = NO;
        strongSelf.selectedTargetInfo = nil;
        strongSelf.contentWindow.hidden = YES;
        [[KIFRMenuView sharedInstance] fadeOutView:nil];
    }];
}

- (void)layout {
    self.contentWindow.frame = [UIScreen mainScreen].bounds;
    self.instructionLabel.frame = CGRectMake(0, 0, self.contentWindow.bounds.size.width, 20);
    self.selectControlTableView.frame = CGRectMake(0, self.contentWindow.bounds.size.height, self.contentWindow.bounds.size.width, ceil(self.contentWindow.bounds.size.height / 2));
}

#pragma mark - Process data

- (void)addVerificationStepWithEvent:(KIFRTestEvent *)event {
    self.isProcessingStep = YES;
    self.eventData = event;
    [self.selectControlTableView reloadData];
    
    __weak KIFRAddVerificationStepUI *weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        KIFRAddVerificationStepUI *strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        strongSelf.selectControlTableView.kifrFrameBottom = strongSelf.contentWindow.kifrHeight;
    }];
}

- (NSString *)stringForVerificationType:(KIFRVerificationType)type {
    switch (type) {
        case KIFRVerificationTypeVisible:
            return @"Verify element is visible";
            
        case KIFRVerificationTypeNotVisible:
            return @"Verify element is not visible";
            
        case KIFRVerificationTypeContentEqual:
            return @"Verify element content is equal to: ";
            
        default:
            break;
    }
    
    return @"Unknown Type";
}

#pragma mark - UITableView Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.selectedTargetInfo) {
        // If we don't have the content then don't offer it as an option
        return (self.selectedTargetInfo.contentString ? KIFRVerificationTypeCount : KIFRVerificationTypeCount - 1);
    }
    
    return (self.eventData ? self.eventData.touchedViewsInfo.count : 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedTargetInfo) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([UITableViewCell class])];
        }
        
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 2;
        cell.textLabel.text = [self stringForVerificationType:(KIFRVerificationType)indexPath.row];
        
        if (indexPath.row == KIFRVerificationTypeContentEqual) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@ '%@'", [self stringForVerificationType:(KIFRVerificationType)indexPath.row], self.selectedTargetInfo.contentString];
        }
        
        return cell;
    }
    
    // Default to the 'KIFRVerificationStepCell'
    KIFRVerificationStepCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([KIFRVerificationStepCell class])];
    if (!cell) {
        cell = [[KIFRVerificationStepCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([KIFRVerificationStepCell class])];
    }
    
    KIFRTargetInfo *targetInfo = self.eventData.touchedViewsInfo[indexPath.row];
    [cell updateWithTargetInfo:targetInfo];
                                                                                                    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!self.selectedTargetInfo) {
        KIFRTargetInfo *targetInfo = self.eventData.touchedViewsInfo[indexPath.row];
        
        // At this point we need an 'accessibilityIdentifier' or a 'firstAccessibleParentAccessibilityIdentifier' to be able to add a verification step
        if (targetInfo.accessibilityIdentifier || targetInfo.firstAccessibleParentAccessibilityIdentifier) {
            self.selectedTargetInfo = targetInfo;
            [tableView reloadData];
        }
    }
    else {
        [[KIFRTest currentTest] addVerificationStep:(KIFRVerificationType)indexPath.row forTargetInfo:self.selectedTargetInfo];
        [self hide];
    }
}

@end
