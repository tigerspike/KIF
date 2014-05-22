//
//  NSObject+KIFRUtils_Networking.h
//  KIFRecorder
//
//  Created by Morgan Pretty on 21/05/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import <Foundation/Foundation.h>

static const NSString *kKIFRRequestKey = @"request";
static const NSString *kKIFRResponseKey = @"response";
static const NSString *kKIFRTestStepIndexKey = @"testStepIndex";

@interface NSObject (KIFRUtils_Networking)

- (void)KIFR_markAsFinished;
- (void)KIFR_connectionDidFinishLoading:(NSURLConnection *)connection;

@end
