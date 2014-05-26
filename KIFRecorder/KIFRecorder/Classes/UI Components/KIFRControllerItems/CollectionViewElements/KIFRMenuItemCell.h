//
//  KIFRMenuItemCell.h
//  KIFRecorder
//
//  Created by Morgan Pretty on 23/05/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KIFRMenuItemCell : UICollectionViewCell

- (void)updateWithTitle:(NSString *)title;
+ (CGSize)cellSize;

@end
