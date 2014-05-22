//
//  NSObject+KIFRUtils_Networking.m
//  KIFRecorder
//
//  Created by Morgan Pretty on 21/05/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import "NSObject+KIFRUtils_Networking.h"
#import "KIFRTest.h"

@interface NSObject (KIFRUtils_Networking_Private)

// ASIHTTPRquest Methods
- (NSURL *)url;
- (NSData *)rawResponseData;

// AFNetworking Methods
- (NSData *)responseData;

@end

@implementation NSObject (KIFRUtils_Networking)

// Note: This swizzle is to handle API requests running through the 'ASIHTTPRequest' networking library
- (void)KIFR_markAsFinished {
    NSURL *requestURL;
    NSData *responseData;
    
    // Get the URL
    if ([self respondsToSelector:@selector(url)]) {
        requestURL = [self performSelector:@selector(url)];
    }
    
    // Get the Response Data
    if ([self respondsToSelector:@selector(rawResponseData)]) {
        responseData = [self performSelector:@selector(rawResponseData)];
    }
    
    // If we have both values then add them to the test
    if (requestURL && responseData) {
        [self addResponse:responseData forRequest:requestURL];
    }
    
    [self KIFR_markAsFinished];
}

// Note: This swizzle is to handle API requests running through the 'RestKit' (AFNetworking) networking library
- (void)KIFR_connectionDidFinishLoading:(NSURLConnection *)connection {
    // Call through to the original method first so that the 'responseData' gets populated
    [self KIFR_connectionDidFinishLoading:connection];
    
    // Get the request URL
    NSURL *requestURL = connection.originalRequest.URL;
    NSData *responseData;
    
    // Get the Response Data
    if ([self respondsToSelector:@selector(responseData)]) {
        responseData = [self performSelector:@selector(responseData)];
    }
    
    // If we have both values then add them to the test
    if (requestURL && responseData) {
        [self addResponse:responseData forRequest:requestURL];
    }
}

#pragma mark - Add the requests to the KIFRTest

- (void)addResponse:(NSData *)responseData forRequest:(NSURL *)requestURL {
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    [requestDictionary setObject:[requestURL absoluteString] forKey:kKIFRRequestKey];
    
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
    [requestDictionary setObject:jsonData forKey:kKIFRResponseKey];
    [requestDictionary setObject:@([KIFRTest currentTest].testStepsArray.count) forKey:kKIFRTestStepIndexKey];
    
    [[KIFRTest currentTest].testRequestsArray addObject:requestDictionary];
}

@end
