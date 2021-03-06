//
//  UIView+KIFRContent.m
//  KIFRecorder
//
//  Created by Morgan Pretty on 20/05/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import "UIView+KIFRContent.h"

@implementation UIView (KIFRContent)

// Note: This should match the method in 'UIView-KIFAdditions'
- (NSString *)kifrContentString {
    // Different UI types are handled differently, return the respective content for each
    if ([self isKindOfClass:[UILabel class]]) {
        return ((UILabel *)self).text;
    }
    else if ([self isKindOfClass:[UIButton class]]) {
        return [(UIButton *)self titleForState:UIControlStateNormal];
    }
    else if ([self isKindOfClass:[UISearchBar class]]) {
        return ((UISearchBar *)self).placeholder;
    }
    else if ([self respondsToSelector:@selector(annotation)]) {
        id annotation = [self performSelector:@selector(annotation)];
        if ([annotation respondsToSelector:@selector(title)]) {
            return [annotation performSelector:@selector(title)];
        }
    }
                
    return nil;
}

+ (NSArray *)viewClassesToIgnoreWhenRecording {
    return @[ NSClassFromString(@"UILayoutContainerView"),
              NSClassFromString(@"UITransitionView"),
              NSClassFromString(@"UIViewControllerWrapperView"),
              NSClassFromString(@"UILayoutContainerView"),
              NSClassFromString(@"UINavigationTransitionView"),
              NSClassFromString(@"UIViewControllerWrapperView"),
              NSClassFromString(@"UITableViewWrapperView"),
              NSClassFromString(@"UITableViewCellScrollView"),
              NSClassFromString(@"MKBasicMapView"),
              NSClassFromString(@"_MKMapLayerHostingView"),
              NSClassFromString(@"MKScrollContainerView"),
              NSClassFromString(@"MKNewAnnotationContainerView"),
              NSClassFromString(@"_UISearchBarSearchFieldBackgroundView"),
              NSClassFromString(@"UISearchBarBackground"),
              
              // Note: Causes issues when two UISearchBar's have the same placeholder
              NSClassFromString(@"UISearchBarTextField"),
              NSClassFromString(@"UISearchBarTextFieldLabel"),
              ];
}

@end
