//
//  KIFRExistingTestCell.m
//  PTV
//
//  Created by Morgan Pretty on 28/03/2014.
//  Copyright (c) 2014 PTV. All rights reserved.
//

#import "KIFRTestStepCell.h"

@interface KIFRTestStepCell ()

@property (nonatomic, strong) UILabel *testNumberLabel;
@property (nonatomic, strong) UILabel *testDetailLabel;

@end

@implementation KIFRTestStepCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        _testNumberLabel = [UILabel new];
        _testNumberLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:_testNumberLabel];
        
        _testDetailLabel = [UILabel new];
        _testDetailLabel.font = [UIFont systemFontOfSize:16];
        _testDetailLabel.numberOfLines = 2;
        _testDetailLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:_testDetailLabel];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // So the 'UITableViewCellReorderControl' doens't take up any space we need to manually set the width of the contentView
    if (self.isEditing) {
        self.contentView.kifrWidth = self.kifrWidth;
    }
    
    self.testNumberLabel.frame = CGRectMake(self.separatorInset.left, 0, 30, self.contentView.kifrHeight);
    self.testDetailLabel.frame = CGRectMake(self.testNumberLabel.kifrFrameRight + 5, 5, self.contentView.kifrWidth - (self.testNumberLabel.kifrFrameRight + 5), self.contentView.kifrHeight - 10);
}

- (void)addSubview:(UIView *)view {
    if ([view isKindOfClass:NSClassFromString(@"UITableViewCellReorderControl")]) {
        view.frame = CGRectZero;
        view.hidden = YES;
    }
    
    [super addSubview:view];
}

#pragma mark - Content

- (void)updateWithStepNumber:(NSInteger)stepNumber andStepString:(NSString *)stepString {
    self.testNumberLabel.text = [NSString stringWithFormat:@"%li.", (long)stepNumber];
    self.testDetailLabel.text = stepString;
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

@end
