//
//  KIFRecorder.h
//  KIFRecorder
//  Version 0.0.15
//
//  Created by Morgan Pretty on 1/04/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KIFRecorder : NSObject 

+ (void)setupRecording;
+ (NSArray *)getSavedTests;
+ (void)exportTests;

@end
