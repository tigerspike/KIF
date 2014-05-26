//
//  KIFRController.h
//  KIFRecorder
//
//  Created by Morgan Pretty on 22/05/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import <UIKit/UIKit.h>

#define KIFR_MENU_CONTROLLER_CONTRACTED_SIZE 50
#define KIFR_MENU_CONTROLLER_CONTRACTED_SIDE_PADDING 2
#define KIFR_MENU_CONTROLLER_EXPANDED_SIDE_PADDING 10
#define KIFR_MENU_CONTROLLER_UNFOCUSSED_ALPHA 0.5

@protocol KIFRControllerItem, KIFRControllerMenu, KIFRControllerView;

@interface KIFRController : UICollectionView

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) id<KIFRControllerItem> rootItem;
@property (nonatomic, strong) id<KIFRControllerItem> topItem;
@property (nonatomic, assign) CGPoint targetPoint;

// Animation Specific
@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, assign) BOOL isPushingItem;
@property (nonatomic, assign) BOOL isPoppingItem;
@property (nonatomic, strong) id<KIFRControllerItem> itemBeingRemoved;

+ (instancetype)sharedInstance;
- (void)pushItem:(id<KIFRControllerItem>)menuItem animated:(BOOL)animated;
- (void)popItemAnimated:(BOOL)animated;
- (void)popToRootItemAnimated:(BOOL)animated;

@end

@protocol KIFRControllerItem <NSObject>

@required
- (NSInteger)numberOfItems;

@end

@protocol KIFRControllerMenu <KIFRControllerItem>

@required
- (NSString *)titleForItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)controller:(KIFRController *)controller didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol KIFRControllerView <KIFRControllerItem>

@required
- (UIView *)contentViewForItemAtIndexPath:(NSIndexPath *)indexPath;

@end
