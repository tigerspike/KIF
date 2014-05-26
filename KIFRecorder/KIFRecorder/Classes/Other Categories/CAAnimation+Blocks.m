//
//  CAAnimation+Blocks.m
//  KIFRecorder
//
//  Created by Morgan Pretty on 23/05/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import "CAAnimation+Blocks.h"

@interface CAAnimationDelegate : NSObject

@property (nonatomic, copy) void (^completionBlock)(BOOL);
@property (nonatomic, copy) void (^start)(void);

- (void)animationDidStart:(CAAnimation *)anim;
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)isFinished;

@end

@implementation CAAnimationDelegate

- (void)animationDidStart:(CAAnimation *)anim {
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)isFinished {
    if (self.completionBlock != nil) {
        self.completionBlock(isFinished);
    }
}

@end

@implementation CAAnimation (Blocks)

- (void)setCompletionBlock:(void (^)(BOOL isFinished))completion {
    if ([self.delegate isKindOfClass:[CAAnimationDelegate class]]) {
        ((CAAnimationDelegate *)self.delegate).completionBlock = completion;
    }
    else {
        CAAnimationDelegate *delegate = [[CAAnimationDelegate alloc] init];
        delegate.completionBlock = completion;
        self.delegate = delegate;
    }
}

- (void (^)(BOOL))completion {
    if ([self.delegate isKindOfClass:[CAAnimationDelegate class]]) {
        return ((CAAnimationDelegate *)self.delegate).completionBlock;
    }
    
    return nil;
}

@end
