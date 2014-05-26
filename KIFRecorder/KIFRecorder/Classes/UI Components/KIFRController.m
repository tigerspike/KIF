//
//  KIFRMenuController.m
//  KIFRecorder
//
//  Created by Morgan Pretty on 22/05/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import "KIFRController.h"
#import "UIWindow+KIFRUtils.h"
#import "KIFRControllerLayout.h"
#import "KIFRMainMenuItem.h"
#import "KIFRMenuItemCell.h"
#import "KIFRDetailItemCell.h"
#import "CAAnimation+Blocks.h"

#define KIFR_MENU_CONTROLLER_OLD_FRAME_KEY @"kKIFRMenuControllerOldMenuFrame"

@interface KIFRController () <UICollectionViewDataSource, UICollectionViewDelegate, UIDynamicItem, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImageView *contractedImageView;
@property (nonatomic, readonly) BOOL hasBackButton;

// Animation Stuff
@property (nonatomic, assign) CGPoint touchOffset;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *controllerPanGestureRecognizer;
@property (nonatomic, strong) UIDynamicAnimator *viewAnimator;
@property (nonatomic, strong) UIAttachmentBehavior *attachmentBehaviour;
@property (nonatomic, strong) UIDynamicItemBehavior *itemBehaviour;
@property (nonatomic, strong) NSTimer *fadeOutTimer;

@end

@implementation KIFRController

+ (instancetype)sharedInstance {
    static KIFRController *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [KIFRController new];
    });
    
    return sharedInstance;
}

- (id)init {
    // Calculate the frame for the controller
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGRect controllerFrame = CGRectMake(screenSize.width - KIFR_MENU_CONTROLLER_CONTRACTED_SIZE - KIFR_MENU_CONTROLLER_CONTRACTED_SIDE_PADDING, ceil((screenSize.height - KIFR_MENU_CONTROLLER_CONTRACTED_SIZE) / 2), KIFR_MENU_CONTROLLER_CONTRACTED_SIZE, KIFR_MENU_CONTROLLER_CONTRACTED_SIZE);
    NSData *rectData = [[NSUserDefaults standardUserDefaults] valueForKey:KIFR_MENU_CONTROLLER_OLD_FRAME_KEY];
    if (rectData) {
        NSValue *oldFrameValue = [NSKeyedUnarchiver unarchiveObjectWithData:rectData];
        self.frame = [oldFrameValue CGRectValue];
    }
    
    if ((self = [super initWithFrame:controllerFrame collectionViewLayout:[KIFRControllerLayout new]])) {
        _items = [NSMutableArray new];
        
        self.delegate = self;
        self.dataSource = self;
        self.backgroundColor = [UIColor darkGrayColor];
        self.layer.cornerRadius = 8;
        self.clipsToBounds = YES;
        self.alpha = KIFR_MENU_CONTROLLER_UNFOCUSSED_ALPHA;
        [self registerClass:[KIFRMenuItemCell class] forCellWithReuseIdentifier:NSStringFromClass([KIFRMenuItemCell class])];
        [self registerClass:[KIFRDetailItemCell class] forCellWithReuseIdentifier:NSStringFromClass([KIFRDetailItemCell class])];
        
        // Animation Stuff
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(controllerTapped:)];
        _tapGestureRecognizer.delegate = self;
        _tapGestureRecognizer.cancelsTouchesInView = NO;
        [self addGestureRecognizer:_tapGestureRecognizer];

        _controllerPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(controllerPanned:)];
        _controllerPanGestureRecognizer.delegate = self;
        [self addGestureRecognizer:_controllerPanGestureRecognizer];

        // UI Dynamics
        _viewAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:[UIWindow kifrWindow]];
        _attachmentBehaviour = [[UIAttachmentBehavior alloc] initWithItem:self attachedToAnchor:CGPointZero];
        _attachmentBehaviour.length = 0;
        _attachmentBehaviour.frequency = 3;
        _itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[ self ]];
        _itemBehaviour.resistance = 25;
        
        // Now that all of the UI Elements are created we can set the KifrShouldIgnore flag
        self.recursiveKIFRShouldIgnore = YES;
    }
    
    return self;
}

#pragma mark - Intercept touches when expanded

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.items.count) {
        return YES;
    }
    
    return [super pointInside:point withEvent:event];
}

#pragma mark - UIControl Handlers

- (void)controllerTapped:(UITapGestureRecognizer *)sender {
    if (self.items.count) {
        // If we clicked outside of our rect then close the menu
        if (!CGRectContainsPoint(self.bounds, [sender locationInView:self])) {
            [self popToRootItemAnimated:YES];
        }
        
        return;
    }
    
    [self pushItem:[KIFRMainMenuItem new] animated:YES];
}

- (void)controllerPanned:(UIPanGestureRecognizer *)sender {
    // Ignore gesture if we are expanded
    if (self.items.count) {
        return;
    }
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self.fadeOutTimer invalidate];
        self.fadeOutTimer = nil;
        
        self.attachmentBehaviour.anchorPoint = [sender locationInView:[UIWindow kifrWindow]];
        [self.viewAnimator addBehavior:self.itemBehaviour];
        [self.viewAnimator addBehavior:self.attachmentBehaviour];
        
        __weak KIFRController *weakSelf = self;
        [UIView animateWithDuration:0.3 delay:0 options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut) animations:^{
            KIFRController *strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            
            strongSelf.alpha = 1;
        } completion:nil];
    }
    
    self.attachmentBehaviour.anchorPoint = [sender locationInView:[UIWindow kifrWindow]];
    [self.viewAnimator updateItemUsingCurrentState:self];
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self.viewAnimator removeBehavior:self.itemBehaviour];
        [self.viewAnimator removeBehavior:self.attachmentBehaviour];
        
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        CGFloat leftDist = self.center.x;
        CGFloat rightDist = screenSize.width - self.center.x;
        CGFloat topDist = self.center.y;
        CGFloat botDist = screenSize.height - self.center.y;
        CGPoint targetPoint = self.center;
        
        // Check if we should even care about the top or bot distances
        if (topDist < 100 || botDist < 100) {
            CGFloat minYDist = MIN(topDist, botDist);
            CGFloat minXDist = MIN(leftDist, rightDist);
            
            if (minYDist < minXDist) {
                CGFloat yPos = (topDist < botDist ? ceil(KIFR_MENU_CONTROLLER_CONTRACTED_SIZE / 2) + KIFR_MENU_CONTROLLER_CONTRACTED_SIDE_PADDING : screenSize.height - ceil(KIFR_MENU_CONTROLLER_CONTRACTED_SIZE / 2) - KIFR_MENU_CONTROLLER_CONTRACTED_SIDE_PADDING);
                targetPoint = CGPointMake(targetPoint.x, yPos);
            }
            else {
                CGFloat xPos = (leftDist < rightDist ? ceil(KIFR_MENU_CONTROLLER_CONTRACTED_SIZE / 2) + KIFR_MENU_CONTROLLER_CONTRACTED_SIDE_PADDING : screenSize.width - ceil(KIFR_MENU_CONTROLLER_CONTRACTED_SIZE / 2) - KIFR_MENU_CONTROLLER_CONTRACTED_SIDE_PADDING);
                targetPoint = CGPointMake(xPos, targetPoint.y);
            }
        }
        else {
            CGFloat xPos = (leftDist < rightDist ? ceil(KIFR_MENU_CONTROLLER_CONTRACTED_SIZE / 2) + KIFR_MENU_CONTROLLER_CONTRACTED_SIDE_PADDING : screenSize.width - ceil(KIFR_MENU_CONTROLLER_CONTRACTED_SIZE / 2) - KIFR_MENU_CONTROLLER_CONTRACTED_SIDE_PADDING);
            targetPoint = CGPointMake(xPos, targetPoint.y);
        }
        
        __weak KIFRController *weakSelf = self;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            KIFRController *strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            
            strongSelf.center = targetPoint;
        } completion:^(BOOL finished) {
            KIFRController *strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            
            strongSelf.fadeOutTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:strongSelf selector:@selector(fadeOutView:) userInfo:nil repeats:NO];
            NSData *rectData = [NSKeyedArchiver archivedDataWithRootObject:[NSValue valueWithCGRect:strongSelf.frame]];
            [[NSUserDefaults standardUserDefaults] setValue:rectData forKey:KIFR_MENU_CONTROLLER_OLD_FRAME_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }];
    }
}

#pragma mark - Item Hierarchy

- (BOOL)hasBackButton {
    return (self.items.count > 1);
}

- (void)pushItem:(id<KIFRControllerMenu>)menuItem animated:(BOOL)animated {
    self.isPushingItem = YES;
    
    [self performBatchUpdates:^{
        [self removeOldItems];
        
        self.topItem = menuItem;
        [self.items addObject:menuItem];
        
        [self addNewItems];
        [self updateViewSizeAnimated:animated];
    } completion:^(BOOL finished) {
        self.isPushingItem = NO;
    }];
}

- (void)popItemAnimated:(BOOL)animated {
    self.isPoppingItem = YES;
    
    [self performBatchUpdates:^{
        // Remove an extra item for the back button
        self.itemBeingRemoved = self.items.lastObject;
        [self removeOldItems];
        
        // Remove the item
        [self.items removeLastObject];
        self.topItem = self.items.lastObject;
        
        [self addNewItems];
        [self updateViewSizeAnimated:animated];
    } completion:^(BOOL finished) {
        self.isPoppingItem = NO;
        self.itemBeingRemoved = nil;
    }];
}

- (void)popToRootItemAnimated:(BOOL)animated {
    self.isPoppingItem = YES;
    
    [self performBatchUpdates:^{
        // Remove an extra item for the back button
        self.itemBeingRemoved = self.items.lastObject;
        [self removeOldItems];
        
        // Remove all items
        [self.items removeAllObjects];
        self.topItem = nil;
        
        [self updateViewSizeAnimated:animated];
    } completion:^(BOOL finished) {
        self.isPoppingItem = NO;
        self.itemBeingRemoved = nil;
    }];
}

- (void)removeOldItems {
    // Remove the old items
    if (self.items.count) {
        // Remove an extra item for the back button
        id<KIFRControllerItem> oldItem = self.items.lastObject;
        NSInteger oldCount = [oldItem numberOfItems] + (self.hasBackButton ? 1 : 0);
        NSMutableArray *oldItemIndexPaths = [NSMutableArray arrayWithCapacity:oldCount];
        for (int i = 0; i < oldCount; ++i) {
            [oldItemIndexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
        }
        
        [self deleteItemsAtIndexPaths:oldItemIndexPaths];
    }
}

- (void)addNewItems {
    // If we still have items then add the new items back
    if (self.topItem) {
        // Add an extra item for the back button
        NSInteger count = [self.topItem numberOfItems] + (self.hasBackButton ? 1 : 0);
        NSMutableArray *newItemIndexPaths = [NSMutableArray arrayWithCapacity:count];
        for (int i = 0; i < count; ++i) {
            [newItemIndexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
        }
        
        [self insertItemsAtIndexPaths:newItemIndexPaths];
    }
}

#pragma mark - Animations

- (void)updateViewSizeAnimated:(BOOL)animated {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    [self.fadeOutTimer invalidate];
    self.fadeOutTimer = nil;
    
    if (self.topItem) {
        CGFloat viewWidth = MIN(screenSize.width, screenSize.height) - (KIFR_MENU_CONTROLLER_EXPANDED_SIDE_PADDING * 2);
        CGFloat viewHeight;
        self.targetPoint = CGPointMake(ceil(self.kifrWidth / 2), ceil(self.kifrHeight / 2));
        
        if ([self.topItem conformsToProtocol:@protocol(KIFRControllerView)]) {
            CGFloat statusBarHeight = ([UIApplication sharedApplication].statusBarHidden ? 0 : [UIApplication sharedApplication].statusBarFrame.size.height);
            viewHeight = screenSize.height - (statusBarHeight * 1.5) - (KIFR_MENU_CONTROLLER_EXPANDED_SIDE_PADDING * 2);
        }
        else {
            viewHeight = MIN(screenSize.width, screenSize.height) - (KIFR_MENU_CONTROLLER_EXPANDED_SIDE_PADDING * 2);
        }
        
        if (!animated) {
            self.frame = CGRectMake(KIFR_MENU_CONTROLLER_EXPANDED_SIDE_PADDING, ceil((screenSize.height - viewHeight) / 2), viewWidth, viewHeight);
            self.alpha = 1;
            [self setNeedsLayout];
            [self layoutIfNeeded];
        }
        else {
            // Note: We need to UI CATransactions because that seems to be what the UICollectionView uses internally when moving things around (if we use UIView animation blocks here it conflicts with the CATransactions built in to the UICollectionView)
            CABasicAnimation *positionAnim = [CABasicAnimation animationWithKeyPath:@"position"];
            positionAnim.fromValue = [NSValue valueWithCGPoint:self.layer.position];
            positionAnim.toValue = [NSValue valueWithCGPoint:CGPointMake(KIFR_MENU_CONTROLLER_EXPANDED_SIDE_PADDING + ceil(viewWidth / 2), ceil(screenSize.height / 2))];
            
            CABasicAnimation *boundsAnim = [CABasicAnimation animationWithKeyPath:@"bounds"];
            boundsAnim.fromValue = [NSValue valueWithCGRect:self.layer.bounds];
            boundsAnim.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, viewWidth, viewHeight)];
            
            CABasicAnimation *alphaAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
            alphaAnim.fromValue = @(self.layer.opacity);
            alphaAnim.toValue = @(1);
            
            CAAnimationGroup *animGroup = [CAAnimationGroup new];
            animGroup.duration = 0.3 * UIAnimationDragCoefficient();
            animGroup.animations = @[ positionAnim, boundsAnim, alphaAnim ];
            animGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            
            [self.layer addAnimation:animGroup forKey:@"expandAnim"];
            self.layer.position = [positionAnim.toValue CGPointValue];
            self.layer.bounds = [boundsAnim.toValue CGRectValue];
            self.layer.opacity = 1;
        }
    }
    else {
        CGFloat sidePadding = 2;
        CGFloat sideSize = KIFR_MENU_CONTROLLER_CONTRACTED_SIZE;
        CGRect oldFrame = CGRectMake(sidePadding, ceil((screenSize.height - sideSize) / 2), sideSize, sideSize);
        NSData *rectData = [[NSUserDefaults standardUserDefaults] valueForKey:KIFR_MENU_CONTROLLER_OLD_FRAME_KEY];
        if (rectData) {
            NSValue *oldFrameValue = [NSKeyedUnarchiver unarchiveObjectWithData:rectData];
            oldFrame = [oldFrameValue CGRectValue];
        }
        
        if (!animated) {
            self.frame = oldFrame;
            [self setNeedsLayout];
            [self layoutIfNeeded];
            
            // Only fade back in if the menu is currently visible
            if (self.alpha > 0) {
                self.fadeOutTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(fadeOutView:) userInfo:nil repeats:NO];
            }
        }
        else {
            // Note: We need to UI CATransactions because that seems to be what the UICollectionView uses internally when moving things around (if we use UIView animation blocks here it conflicts with the CATransactions built in to the UICollectionView)
            CABasicAnimation *positionAnim = [CABasicAnimation animationWithKeyPath:@"position"];
            positionAnim.fromValue = [NSValue valueWithCGPoint:self.layer.position];
            positionAnim.toValue = [NSValue valueWithCGPoint:CGPointMake(oldFrame.origin.x + ceil(sideSize / 2), oldFrame.origin.y + ceil(sideSize / 2))];
            
            CABasicAnimation *boundsAnim = [CABasicAnimation animationWithKeyPath:@"bounds"];
            boundsAnim.fromValue = [NSValue valueWithCGRect:self.layer.bounds];
            boundsAnim.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, sideSize, sideSize)];
            
            CAAnimationGroup *animGroup = [CAAnimationGroup new];
            animGroup.duration = 0.3 * UIAnimationDragCoefficient();
            animGroup.animations = @[ positionAnim, boundsAnim ];
            animGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            
            __weak KIFRController *weakSelf = self;
            [animGroup setCompletionBlock:^(BOOL isFinished) {
                KIFRController *strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                
                strongSelf.fadeOutTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:strongSelf selector:@selector(fadeOutView:) userInfo:nil repeats:NO];
            }];
            
            [self.layer addAnimation:animGroup forKey:@"contractAnim"];
            self.layer.position = [positionAnim.toValue CGPointValue];
            self.layer.bounds = [boundsAnim.toValue CGRectValue];
        }
    }
}

- (void)fadeOutView:(id)sender {
    [self.fadeOutTimer invalidate];
    self.fadeOutTimer = nil;
    
    __weak KIFRController *weakSelf = self;
    [UIView animateWithDuration:0.3 delay:0 options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseInOut) animations:^{
        KIFRController *strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        strongSelf.alpha = KIFR_MENU_CONTROLLER_UNFOCUSSED_ALPHA;
    } completion:nil];
}

#pragma mark - UICollectionView Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    // We need to add an extra 1 for the back button (it will be the last index)
    if (self.topItem) {
        return [self.topItem numberOfItems] + (self.hasBackButton ? 1 : 0);
    }
    
    // Return 0 by default to avoid crashes
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger numberOfItems = [self.topItem numberOfItems];
    
    // Try a detail cell first
    if ([self.topItem conformsToProtocol:@protocol(KIFRControllerView)]) {
        if (!self.hasBackButton || (self.hasBackButton && indexPath.row < numberOfItems)) {
            KIFRDetailItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([KIFRDetailItemCell class]) forIndexPath:indexPath];

            [cell updateWithContentView:[(id<KIFRControllerView>)self.topItem contentViewForItemAtIndexPath:indexPath]];
            
            return cell;
        }
    }
    
    // Otherwise, default to a menu cell
    KIFRMenuItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([KIFRMenuItemCell class]) forIndexPath:indexPath];
    
    if (self.hasBackButton && indexPath.row == numberOfItems) {
        [cell updateWithTitle:@"Back"];
    }
    else {
        [cell updateWithTitle:[(id<KIFRControllerMenu>)self.topItem titleForItemAtIndexPath:indexPath]];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger numberOfItems = [self.topItem numberOfItems];
    
    // Did we press the back button
    if (self.hasBackButton && indexPath.row == numberOfItems) {
        [self popItemAnimated:YES];
    }
    else if (self.topItem && [self.topItem conformsToProtocol:@protocol(KIFRControllerMenu)]) {
        [(id<KIFRControllerMenu>)self.topItem controller:self didSelectItemAtIndexPath:indexPath];
    }
}

@end
