//
//  NSObject+KIFRUtils_Networking.h
//  KIFRecorder
//
//  Created by Morgan Pretty on 21/05/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (KIFRUtils_Networking)

- (void)KIFR_markAsFinished;
- (void)KIFR_connectionDidFinishLoading:(NSURLConnection *)connection;

@end
