//
//  KIFRVerificationStepCell.m
//  KIFRecorder
//
//  Created by Morgan Pretty on 19/05/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import "KIFRVerificationStepCell.h"
#import "KIFRTargetInfo.h"

@interface KIFRVerificationStepCell ()

@property (nonatomic, strong) UILabel *controlTypeLabel;
@property (nonatomic, strong) UILabel *controlIdentifierLabel;

@property (nonatomic, strong) UILabel *controlParentTypeLabel;
@property (nonatomic, strong) UILabel *controlParentIdentifierLabel;

@property (nonatomic, strong) UILabel *controlNumSubviewsLabel;
@property (nonatomic, strong) UILabel *controlUserInteractionEnabledLabel;
@property (nonatomic, strong) UILabel *controlFrameLabel;

@property (nonatomic, strong) UILabel *controlContentLabel;

@end

@implementation KIFRVerificationStepCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        _controlTypeLabel = [UILabel new];
        _controlTypeLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_controlTypeLabel];
        
        _controlIdentifierLabel = [UILabel new];
        _controlIdentifierLabel.font = [UIFont systemFontOfSize:14];
        _controlIdentifierLabel.minimumScaleFactor = 0.5;
        _controlIdentifierLabel.adjustsFontSizeToFitWidth = YES;
        _controlIdentifierLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_controlIdentifierLabel];
        
        _controlParentTypeLabel = [UILabel new];
        _controlParentTypeLabel.font = [UIFont systemFontOfSize:10];
        [self.contentView addSubview:_controlParentTypeLabel];
        
        _controlParentIdentifierLabel = [UILabel new];
        _controlParentIdentifierLabel.font = [UIFont systemFontOfSize:10];
        _controlParentIdentifierLabel.minimumScaleFactor = 0.5;
        _controlParentIdentifierLabel.adjustsFontSizeToFitWidth = YES;
        _controlParentIdentifierLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_controlParentIdentifierLabel];
        
        _controlNumSubviewsLabel = [UILabel new];
        _controlNumSubviewsLabel.font = [UIFont systemFontOfSize:10];
        [self.contentView addSubview:_controlNumSubviewsLabel];
        
        _controlUserInteractionEnabledLabel = [UILabel new];
        _controlUserInteractionEnabledLabel.font = [UIFont systemFontOfSize:10];
        _controlUserInteractionEnabledLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_controlUserInteractionEnabledLabel];

        _controlFrameLabel = [UILabel new];
        _controlFrameLabel.font = [UIFont systemFontOfSize:10];
        _controlFrameLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_controlFrameLabel];
        
        _controlContentLabel = [UILabel new];
        _controlContentLabel.font = [UIFont systemFontOfSize:10];
        _controlContentLabel.minimumScaleFactor = 0.5;
        _controlContentLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:_controlContentLabel];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.controlTypeLabel.frame = CGRectMake(15, 3, ceil(self.contentView.kifrWidth / 1.5) - (15 * 2), 15);
    self.controlIdentifierLabel.frame = CGRectMake(self.controlTypeLabel.kifrFrameRight + 10, self.controlTypeLabel.kifrY, self.contentView.kifrWidth - self.controlTypeLabel.kifrFrameRight - (10 * 2), self.controlTypeLabel.kifrHeight);
    
    self.controlParentTypeLabel.frame = CGRectMake(15, self.controlTypeLabel.kifrFrameBottom, ceil(self.contentView.kifrWidth / 1.5) - (15 * 2), 15);
    self.controlParentIdentifierLabel.frame = CGRectMake(self.controlTypeLabel.kifrFrameRight + 10, self.controlParentTypeLabel.kifrY, self.contentView.kifrWidth - self.controlParentTypeLabel.kifrFrameRight - (10 * 2), self.controlTypeLabel.kifrHeight);
    
    CGFloat controlNumSubviewsWidth = [self.controlNumSubviewsLabel.text sizeWithAttributes:@{ NSFontAttributeName : self.controlNumSubviewsLabel.font }].width;
    CGFloat controlFrameWidth = [self.controlFrameLabel.text sizeWithAttributes:@{ NSFontAttributeName : self.controlFrameLabel.font }].width;
    self.controlNumSubviewsLabel.frame = CGRectMake(15, self.controlParentTypeLabel.kifrFrameBottom, controlNumSubviewsWidth, self.controlTypeLabel.kifrHeight);
    self.controlFrameLabel.frame = CGRectMake(self.contentView.kifrWidth - controlFrameWidth - 10, self.controlNumSubviewsLabel.kifrY, controlFrameWidth, self.controlTypeLabel.kifrHeight);
    self.controlUserInteractionEnabledLabel.frame = CGRectMake(0, self.controlNumSubviewsLabel.kifrY, self.contentView.kifrWidth, self.controlTypeLabel.kifrHeight);
    
    self.controlContentLabel.frame = CGRectMake(15, self.controlNumSubviewsLabel.kifrFrameBottom, self.contentView.kifrWidth - (15 * 2), self.controlTypeLabel.kifrHeight);
}

#pragma mark - Content

- (void)updateWithTargetInfo:(KIFRTargetInfo *)targetInfo {
    self.controlTypeLabel.text = NSStringFromClass(targetInfo.targetClass);
    self.controlIdentifierLabel.text = [NSString stringWithFormat:@"ID: %@", (targetInfo.accessibilityIdentifier ? targetInfo.accessibilityIdentifier : @"N/A")];
    
    self.controlParentTypeLabel.text = [NSString stringWithFormat:@"Parent Class: %@", NSStringFromClass(targetInfo.firstAccessibleParentClass)];
    self.controlParentIdentifierLabel.text = [NSString stringWithFormat:@"Parent ID: %@", (targetInfo.firstAccessibleParentAccessibilityIdentifier ? targetInfo.firstAccessibleParentAccessibilityIdentifier : @"N/A")];
    
    self.controlNumSubviewsLabel.text = [NSString stringWithFormat:@"Num Subviews: %lu", (unsigned long)targetInfo.numberOfSubviews];
    self.controlUserInteractionEnabledLabel.text = [NSString stringWithFormat:@"Interaction: %@", (targetInfo.interactionEnabled ? @"YES" : @"NO")];
    self.controlFrameLabel.text = NSStringFromCGRect(targetInfo.frame);
    self.controlContentLabel.text = (targetInfo.contentString ? [NSString stringWithFormat:@"Content: '%@'", targetInfo.contentString] : @"");
    
    if (targetInfo.accessibilityIdentifier) {
        
        self.controlIdentifierLabel.textColor = [UIColor blackColor];
    }
    else {
        self.controlIdentifierLabel.text = @"ID: N/A";
        self.controlIdentifierLabel.textColor = (targetInfo.firstAccessibleParentAccessibilityIdentifier ? [UIColor blackColor] : [UIColor redColor]);
    }
    
    if (!targetInfo.accessibilityIdentifier && !targetInfo.firstAccessibleParentAccessibilityIdentifier) {
        self.controlIdentifierLabel.textColor = [UIColor redColor];
        self.controlParentIdentifierLabel.textColor = [UIColor redColor];
        self.controlParentTypeLabel.textColor = [UIColor redColor];
    }
    else {
        self.controlIdentifierLabel.textColor = [UIColor blackColor];
        self.controlParentIdentifierLabel.textColor = [UIColor blackColor];
        self.controlParentTypeLabel.textColor = [UIColor blackColor];
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

+ (CGFloat)cellHeight {
    return 65;
}

@end
