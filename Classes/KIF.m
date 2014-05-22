//
//  KIF.m
//  KIF
//
//  Created by Morgan Pretty on 22/05/2014.
//
//

#import "KIF.h"

@implementation KIF

+ (instancetype)sharedInstance {
    static KIF *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [KIF new];
    });
    
    return sharedInstance;
}

@end
