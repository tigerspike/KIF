//
//  KIFRViewTestDetailItem.h
//  KIFRecorder
//
//  Created by Morgan Pretty on 26/05/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KIFRController.h"

@class KIFRTest;

@interface KIFRViewTestDetailItem : NSObject <KIFRControllerView>

- (instancetype)initWithTest:(KIFRTest *)test;

@end
