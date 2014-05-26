//
//  KIFRMenuItemCell.m
//  KIFRecorder
//
//  Created by Morgan Pretty on 23/05/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import "KIFRMenuItemCell.h"

@interface KIFRMenuItemCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation KIFRMenuItemCell

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.numberOfLines = 3;
        [self.contentView addSubview:_titleLabel];
        
        // KIF should ignore touches on this view
        self.recursiveKIFRShouldIgnore = YES;
    }
    
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    _titleLabel.textColor = (highlighted ? [UIColor lightGrayColor] : [UIColor whiteColor]);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleLabel.frame = self.bounds;
}

#pragma mark - Content

- (void)updateWithTitle:(NSString *)title {
    _titleLabel.text = title;
}

+ (CGSize)cellSize {
    return CGSizeMake(100, 100);
}

@end
