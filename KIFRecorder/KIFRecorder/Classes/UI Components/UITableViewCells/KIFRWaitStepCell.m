//
//  KIFRWaitStepCell.m
//  PTV
//
//  Created by Morgan Pretty on 31/03/2014.
//  Copyright (c) 2014 PTV. All rights reserved.
//

#import "KIFRWaitStepCell.h"

@interface KIFRWaitStepCell ()

@property (nonatomic, strong) UILabel *waitTimeLabel;
@property (nonatomic, strong) UITextField *waitTimeTextField;

@end

@implementation KIFRWaitStepCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        _waitTimeLabel = [UILabel new];
        _waitTimeLabel.text = @"Wait Time (Seconds):";
        _waitTimeLabel.font = [UIFont boldSystemFontOfSize:16];
        [self.contentView addSubview:_waitTimeLabel];
        
        _waitTimeTextField = [UITextField new];
        _waitTimeTextField.borderStyle = UITextBorderStyleRoundedRect;
        _waitTimeTextField.keyboardType = UIKeyboardTypeDecimalPad;
        [self.contentView addSubview:_waitTimeTextField];
        
        _waitTimeTextField.inputAccessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
        _waitTimeTextField.inputAccessoryView.backgroundColor = [UIColor darkGrayColor];
        
        UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(_waitTimeTextField.inputAccessoryView.kifrWidth - 60 - 10, 0, 60, _waitTimeTextField.inputAccessoryView.kifrHeight)];
        doneButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [doneButton setTitle:@"Done" forState:UIControlStateNormal];
        [doneButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [doneButton addTarget:self action:@selector(doneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_waitTimeTextField.inputAccessoryView addSubview:doneButton];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.waitTimeLabel.frame = CGRectMake(10, 10, self.contentView.kifrWidth - (10 * 2), 20);
    self.waitTimeTextField.frame = CGRectMake(10, self.waitTimeLabel.kifrFrameBottom + 5, self.contentView.kifrWidth - (10 * 2), 40);
}

#pragma mark - UIControl Handlers

- (void)doneButtonPressed:(id)sender {
    [self endEditing:YES];
}

#pragma mark - Content

- (void)updateWithWaitTime:(CGFloat)waitTime {
    self.waitTimeTextField.text = [NSString stringWithFormat:@"%.2f", waitTime];
}

+ (CGFloat)cellHeight {
    return 80;
}

@end
