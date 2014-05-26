//
//  CAAnimation+Blocks.h
//  KIFRecorder
//
//  Created by Morgan Pretty on 23/05/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CAAnimation (Blocks)

@property (nonatomic, strong, setter = setCompletionBlock:) void (^completion)(BOOL finished);

@end
