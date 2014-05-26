//
//  KIFRViewTestsItem.h
//  KIFRecorder
//
//  Created by Morgan Pretty on 23/05/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KIFRController.h"

@interface KIFRViewTestsItem : NSObject <KIFRControllerView>

- (instancetype)initWithTestArray:(NSArray *)testArray;

@end
