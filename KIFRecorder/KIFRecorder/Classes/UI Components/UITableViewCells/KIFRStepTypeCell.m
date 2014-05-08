//
//  StepTypeCell.m
//  PTV
//
//  Created by Morgan Pretty on 31/03/2014.
//  Copyright (c) 2014 PTV. All rights reserved.
//

#import "KIFRStepTypeCell.h"

@interface KIFRStepTypeCell ()

@property (nonatomic, strong) UILabel *stepTypeLabel;
@property (nonatomic, strong) UIButton *stepTypeButton;

@end

@implementation KIFRStepTypeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        _stepTypeLabel = [UILabel new];
        _stepTypeLabel.text = @"Step Type:";
        _stepTypeLabel.font = [UIFont boldSystemFontOfSize:16];
        [self.contentView addSubview:_stepTypeLabel];
        
        _stepTypeButton = [UIButton new];
        _stepTypeButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [_stepTypeButton setTitle:@"None" forState:UIControlStateNormal];
        [_stepTypeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        _stepTypeButton.layer.cornerRadius = 4;
        _stepTypeButton.backgroundColor = [UIColor darkGrayColor];
        _stepTypeButton.userInteractionEnabled = NO;
        [self.contentView addSubview:_stepTypeButton];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.stepTypeLabel.frame = CGRectMake(10, 10, self.contentView.kifrWidth - (10 * 2), 20);
    self.stepTypeButton.frame = CGRectMake(10, self.stepTypeLabel.kifrFrameBottom + 5, self.contentView.kifrWidth - (10 * 2), 40);
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    [self.stepTypeButton setHighlighted:highlighted];
}

#pragma mark - Content

- (void)updateWithStepType:(KIFRStepType)stepType {
    switch (stepType) {
        case KIFRStepTypeUnknown:
            [_stepTypeButton setTitle:@"None" forState:UIControlStateNormal];
            break;
            
        case KIFRStepTypeWait:
            [_stepTypeButton setTitle:@"Wait" forState:UIControlStateNormal];
            break;
            
        default:
            [_stepTypeButton setTitle:@"Haven't added Step" forState:UIControlStateNormal];
            break;
    }
}

+ (CGFloat)cellHeight {
    return 80;
}

@end
