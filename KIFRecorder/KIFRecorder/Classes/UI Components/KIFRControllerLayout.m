//
//  KIFRControllerLayout.m
//  KIFRecorder
//
//  Created by Morgan Pretty on 22/05/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import "KIFRControllerLayout.h"
#import "KIFRController.h"
#import "KIFRMenuItemCell.h"
#import "KIFRMenuControllerDecorationView.h"
#import "UICollectionViewLayoutAttributes+KIFRUtils.h"

#define KIFRControllerLayout_DEG_TO_RAD(__degrees) (__degrees * (M_PI / 180.0f))

@interface KIFRControllerLayout()

@property (nonatomic, strong) NSArray *decorationAttributes;
@property (nonatomic, strong) NSArray *itemAttributes;
@property (nonatomic, strong) NSArray *oldItemAttributes;
@property (nonatomic, assign) BOOL hasBackButton;
@property (nonatomic, assign) NSInteger numberOfItems;

@end

@implementation KIFRControllerLayout

- (id)init {
    if ((self = [super init])) {
        [self registerClass:[KIFRMenuControllerDecorationView class] forDecorationViewOfKind:NSStringFromClass([KIFRMenuControllerDecorationView class])];
    }
    
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    KIFRController *controller = (KIFRController *)self.collectionView;
    NSMutableArray *mutableDecorationAttributes = [NSMutableArray new];
    NSMutableArray *mutableItemAttributes = [NSMutableArray new];
    CGSize contentSize = [self collectionViewContentSize];
    CGSize itemSize = [KIFRMenuItemCell cellSize];
    
    // Note: If we have a back button we will be returning an extra cell
    self.hasBackButton = (controller.items.count > 1);
    self.numberOfItems = [controller numberOfItemsInSection:0] - (self.hasBackButton ? 1 : 0);
    
    // Decoration View Attributes (Centre at the top when there are less the 3 items - be invisible if there are any more)
    UICollectionViewLayoutAttributes *decorationAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:NSStringFromClass([KIFRMenuControllerDecorationView class]) withIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    if (self.numberOfItems <= 3) {
        decorationAttributes.zIndex = 1000;
        decorationAttributes.frame = CGRectMake(ceil((contentSize.width - KIFR_MENU_CONTROLLER_CONTRACTED_SIZE) / 2), 0, KIFR_MENU_CONTROLLER_CONTRACTED_SIZE, KIFR_MENU_CONTROLLER_CONTRACTED_SIZE);
    }
    [mutableDecorationAttributes addObject:decorationAttributes];
    self.decorationAttributes = mutableDecorationAttributes;
    
    // Contents
    if ([controller.topItem conformsToProtocol:@protocol(KIFRControllerMenu)]) {
        // Menu Item Attributes
        for (NSUInteger i = 0; i < self.numberOfItems; ++i) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            
            if (self.numberOfItems >= 3) {
                // Minimum angle of 90 degrees between items
                CGFloat angleBetweenItems = MIN(90, (360.0 / self.numberOfItems));
                CGPoint preRotatedPoint = CGPointMake(0, -ceil((contentSize.height - itemSize.height) / 2));
                CGFloat targetAngle = (360.0 - (angleBetweenItems * (i + 1)));
                CGFloat cosA = cos(KIFRControllerLayout_DEG_TO_RAD(targetAngle));
                CGFloat sinA = sin(KIFRControllerLayout_DEG_TO_RAD(targetAngle));
                
                CGFloat rotX = preRotatedPoint.x * cosA - preRotatedPoint.y * sinA;
                CGFloat rotY = preRotatedPoint.x * sinA + preRotatedPoint.y * cosA;
                CGPoint finalPos = CGPointMake(rotX + ceil((contentSize.width - itemSize.width) / 2), rotY + ceil((contentSize.height - itemSize.height) / 2));
                
                attributes.frame = CGRectMake(finalPos.x, finalPos.y, itemSize.width, itemSize.height);
            }
            else if (self.numberOfItems == 2) {
                // Two items should be centered vertically can hug both sides of the menu
                attributes.frame = CGRectMake((contentSize.width - itemSize.width) * i, ceil((contentSize.height - itemSize.height) / 2), itemSize.width, itemSize.height);
            }
            else if (self.numberOfItems == 1) {
                // A single item should be centered along the bottom of the menu
                attributes.frame = CGRectMake(ceil((contentSize.width - itemSize.width) / 2), contentSize.height - itemSize.height, itemSize.width, itemSize.height);
            }
            
            [mutableItemAttributes addObject:attributes];
        }
        
        // If we have a back button it should be added to the array (in the last position)
        if (self.hasBackButton) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.numberOfItems inSection:0];
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            attributes.isBackButton = YES;
            attributes.zIndex = 999;
            attributes.frame = CGRectMake(ceil((contentSize.width - itemSize.width) / 2), ceil((contentSize.height - itemSize.height) / 2), itemSize.width, itemSize.height);
            [mutableItemAttributes addObject:attributes];
        }
    }
    else if ([controller.topItem conformsToProtocol:@protocol(KIFRControllerView)]) {
        // View Item Attributes
        for (NSUInteger i = 0; i < self.numberOfItems; ++i) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            attributes.frame = CGRectMake(0, ceil(KIFR_MENU_CONTROLLER_CONTRACTED_SIZE * 1.5), contentSize.width, contentSize.height - ceil(KIFR_MENU_CONTROLLER_CONTRACTED_SIZE * 1.5));
            [mutableItemAttributes addObject:attributes];
        }
        
        // If we have a back button it should be added to the array (in the last position)
        if (self.hasBackButton) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.numberOfItems inSection:0];
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            attributes.isBackButton = YES;
            attributes.zIndex = 999;
            attributes.frame = CGRectMake(0, 0, itemSize.width, KIFR_MENU_CONTROLLER_CONTRACTED_SIZE);
            [mutableItemAttributes addObject:attributes];
        }
    }
    
    self.oldItemAttributes = self.itemAttributes;
    self.itemAttributes = mutableItemAttributes;
}

- (CGSize)collectionViewContentSize {
    return self.collectionView.kifrSize;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

#pragma mark - Layout Methods

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *combinedArray = [self.decorationAttributes arrayByAddingObjectsFromArray:self.itemAttributes];
    
    return [combinedArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *attributes, NSDictionary *bindings) {
        return CGRectIntersectsRect(rect, [attributes frame]);
    }]];
}

#pragma mark - Decoration View Layout Methods

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath {
    return self.decorationAttributes[indexPath.row];
}

#pragma mark - Item Layout Methods

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)indexPath {
    KIFRController *controller = (KIFRController *)self.collectionView;
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
    id<KIFRControllerItem> prevItem = (controller.itemBeingRemoved ? controller.itemBeingRemoved : (controller.items.count > 1 ? controller.items[controller.items.count - 2] : nil));
    BOOL previousIsDetail = (prevItem && [prevItem conformsToProtocol:@protocol(KIFRControllerView)]);
    
    if (attributes.isBackButton) {
        attributes.alpha = 0;
    }
    else if (previousIsDetail && [controller.topItem conformsToProtocol:@protocol(KIFRControllerView)]) {
        attributes.alpha = 1;
        attributes.frame = CGRectMake(attributes.frame.size.width * (controller.isPushingItem ? 1 : -1), ceil(KIFR_MENU_CONTROLLER_CONTRACTED_SIZE * 1.5), attributes.frame.size.width, attributes.frame.size.height);
    }
    else if (!CGPointEqualToPoint(((KIFRController *)self.collectionView).targetPoint, CGPointZero)) {
        CGPoint targetPoint = ((KIFRController *)self.collectionView).targetPoint;
        attributes.alpha = 0;
        attributes.frame = CGRectMake(targetPoint.x - ceil(attributes.frame.size.width / 2), targetPoint.y - ceil(attributes.frame.size.height / 2), attributes.frame.size.width, attributes.frame.size.height);
    }
    
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = self.itemAttributes[indexPath.row];
    attributes.alpha = 1;
    return attributes;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.oldItemAttributes.count) {
        KIFRController *controller = (KIFRController *)self.collectionView;
        UICollectionViewLayoutAttributes *attributes = self.oldItemAttributes[indexPath.row];
        id<KIFRControllerItem> prevItem = (controller.itemBeingRemoved ? controller.itemBeingRemoved : (controller.items.count > 1 ? controller.items[controller.items.count - 2] : nil));
        BOOL previousIsDetail = (prevItem && [prevItem conformsToProtocol:@protocol(KIFRControllerView)]);
        
        if (attributes.isBackButton) {
            attributes.alpha = 0;
        }
        else if (previousIsDetail && [controller.topItem conformsToProtocol:@protocol(KIFRControllerView)]) {
            attributes.alpha = 1;
            attributes.frame = CGRectMake(attributes.frame.size.width * (controller.isPoppingItem ? 1 : -1), ceil(KIFR_MENU_CONTROLLER_CONTRACTED_SIZE * 1.5), attributes.frame.size.width, attributes.frame.size.height);
        }
        else if (!CGPointEqualToPoint(((KIFRController *)self.collectionView).targetPoint, CGPointZero)) {
            CGPoint targetPoint = ((KIFRController *)self.collectionView).targetPoint;
            attributes.alpha = 0;
            attributes.frame = CGRectMake(targetPoint.x - ceil(attributes.frame.size.width / 2), targetPoint.y - ceil(attributes.frame.size.height / 2), attributes.frame.size.width, attributes.frame.size.height);
        }
        
        return attributes;
    }
    
    return nil;
}

@end
