//
//  KIFRDetailItemCell.m
//  KIFRecorder
//
//  Created by Morgan Pretty on 23/05/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import "KIFRDetailItemCell.h"

@interface KIFRDetailItemCell ()

@property (nonatomic, strong) UIView *customContentView;

@end

@implementation KIFRDetailItemCell

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.recursiveKIFRShouldIgnore = YES;
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.customContentView.frame = self.contentView.bounds;
}

#pragma mark - Content

- (void)updateWithContentView:(UIView *)contentView {
    if (self.customContentView) {
        [self.customContentView removeFromSuperview];
        self.customContentView = nil;
    }
    
    self.customContentView = contentView;
    [self.contentView addSubview:self.customContentView];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

@end
