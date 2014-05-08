//
//  KIFRecordingApplication.h
//  TSSales
//
//  Created by Morgan Pretty on 24/03/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (KIFRUtils)

- (void)setupRecording;

- (NSArray *)getSavedTests;
- (void)exportTests;

@end
