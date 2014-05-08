//
//  KIFRMenuView.m
//  TSSales
//
//  Created by Morgan Pretty on 27/03/2014.
//  Copyright (c) 2014 Tigerspike. All rights reserved.
//

#import "KIFRMenuView.h"
#import "UIWindow+KIFRUtils.h"
#import "UIApplication+KIFRUtils.h"
#import "KIFRTestsView.h"

#define OLD_FRAME_KEY @"kOldMenuFrame"
#define CONTRACTED_SIDE_PADDING 2
#define CONTRACTED_SIZE 50
#define EXPANDED_SIDE_PADDING 10
#define UNFOCUSSED_ALPHA 0.5

@interface KIFRMenuView () <UIDynamicItem, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImageView *contractedImageView;
@property (nonatomic, strong) UIButton *viewTestsButton;
@property (nonatomic, strong) UIButton *exportButton;
@property (nonatomic, strong) NSArray *mainMenuUIArray;

@property (nonatomic, strong) KIFRTestsView *testsView;

// Animation Stuff
@property (nonatomic, assign) CGPoint touchOffset;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UIDynamicAnimator *viewAnimator;
@property (nonatomic, strong) UIAttachmentBehavior *attachmentBehaviour;
@property (nonatomic, strong) UIDynamicItemBehavior *itemBehaviour;
@property (nonatomic, strong) NSTimer *fadeOutTimer;

@end

@implementation KIFRMenuView

+ (KIFRMenuView *)sharedInstance {
    static KIFRMenuView *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [KIFRMenuView new];
    });
    
    return sharedInstance;
}

- (id)init {
    if ((self = [super init])) {
        // Style the control
        NSData *rectData = [[NSUserDefaults standardUserDefaults] valueForKey:OLD_FRAME_KEY];
        if (rectData) {
            NSValue *oldFrameValue = [NSKeyedUnarchiver unarchiveObjectWithData:rectData];
            self.frame = [oldFrameValue CGRectValue];
        }
        else {
            CGSize screenSize = [UIScreen mainScreen].bounds.size;
            self.frame = CGRectMake(screenSize.width - CONTRACTED_SIZE - CONTRACTED_SIDE_PADDING, ceil((screenSize.height - CONTRACTED_SIZE) / 2), CONTRACTED_SIZE, CONTRACTED_SIZE);
        }
        
        self.backgroundColor = [UIColor darkGrayColor];
        self.layer.cornerRadius = 8;
        self.clipsToBounds = YES;
        self.alpha = UNFOCUSSED_ALPHA;
        
        NSData *imageData = [[NSData alloc] initWithBase64EncodedString:testIcon options:NSDataBase64DecodingIgnoreUnknownCharacters];
        _contractedImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:imageData]];
        [self addSubview:_contractedImageView];
        
        _viewTestsButton = [UIButton new];
        _viewTestsButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [_viewTestsButton setTitle:@"View Tests" forState:UIControlStateNormal];
        [_viewTestsButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [_viewTestsButton addTarget:self action:@selector(viewTestsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        _viewTestsButton.alpha = 0;
        [self addSubview:_viewTestsButton];
        
        _exportButton = [UIButton new];
        _exportButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [_exportButton setTitle:@"Export" forState:UIControlStateNormal];
        [_exportButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [_exportButton addTarget:self action:@selector(exportButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        _exportButton.alpha = 0;
        [self addSubview:_exportButton];
        
        _testsView = [[KIFRTestsView alloc] initWithMenuView:self];
        _testsView.alpha = 0;
        [self addSubview:_testsView];
        
        // Animation Stuff
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuTapped:)];
        _tapGestureRecognizer.delegate = self;
        [self addGestureRecognizer:_tapGestureRecognizer];
        
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(menuPanned:)];
        _panGestureRecognizer.delegate = self;
        [self addGestureRecognizer:_panGestureRecognizer];
        
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

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Always keep on top, also include a sanity check
    if (self.superview) {
        [self.superview bringSubviewToFront:self];
    }
    
    self.contractedImageView.center = CGPointMake(ceil(self.kifrWidth / 2), ceil(self.contractedImageView.kifrHeight / 2));
    
    if (!self.isExpanded) {
        for (UIView *view in self.mainMenuUIArray) {
            view.center = self.contractedImageView.center;
        }
    }
    else {
        self.viewTestsButton.frame = CGRectMake(5, ceil((self.kifrHeight - 80) / 2), 80, 80);
        self.exportButton.frame = CGRectMake(self.kifrWidth - 60 - 5, ceil((self.kifrHeight - 60) / 2), 60, 60);
    }
    
    self.testsView.frame = self.bounds;
}

#pragma mark - Intercept touches when expanded

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.isExpanded) {
        return YES;
    }
    
    return [super pointInside:point withEvent:event];
}

#pragma mark - UIControl Handlers

- (void)menuTapped:(UITapGestureRecognizer *)sender {
    // If the tests view is visible then we don't want to dismiss the menu if the user tapped inside it
    if (self.testsView.alpha > 0 && [self.testsView pointInside:[sender locationInView:self.testsView] withEvent:nil]) {
        return;
    }
    
    [self setExpanded:!self.isExpanded animated:YES];
}

- (void)viewTestsButtonPressed:(id)sender {
    // Set this here so we don't need to keep polling the HD later
    [self.testsView updateTests];
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat statusBarHeight = ([UIApplication sharedApplication].statusBarHidden ? 0 : [UIApplication sharedApplication].statusBarFrame.size.height);
    
    __weak KIFRMenuView *weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        KIFRMenuView *strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        strongSelf.frame = CGRectMake(EXPANDED_SIDE_PADDING, statusBarHeight + EXPANDED_SIDE_PADDING, screenSize.width - (EXPANDED_SIDE_PADDING * 2), screenSize.height - statusBarHeight - (EXPANDED_SIDE_PADDING * 2));
        strongSelf.alpha = 1;
        [strongSelf.mainMenuUIArray setValue:@(0) forKey:@"alpha"];
        strongSelf.testsView.alpha = 1;
        [strongSelf setNeedsLayout];
        [strongSelf layoutIfNeeded];
    }];

}

- (void)exportButtonPressed:(id)sender {
    [[UIApplication sharedApplication] exportTests];
}

- (void)menuPanned:(UIPanGestureRecognizer *)sender {
    // Ignore gesture if we are expanded
    if (self.isExpanded) {
        return;
    }
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self.fadeOutTimer invalidate];
        self.fadeOutTimer = nil;
        
        self.attachmentBehaviour.anchorPoint = [sender locationInView:[UIWindow kifrWindow]];
        [self.viewAnimator addBehavior:self.itemBehaviour];
        [self.viewAnimator addBehavior:self.attachmentBehaviour];
        
        __weak KIFRMenuView *weakSelf = self;
        [UIView animateWithDuration:0.3 delay:0 options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut) animations:^{
            KIFRMenuView *strongSelf = weakSelf;
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
                CGFloat yPos = (topDist < botDist ? ceil(CONTRACTED_SIZE / 2) + CONTRACTED_SIDE_PADDING : screenSize.height - ceil(CONTRACTED_SIZE / 2) - CONTRACTED_SIDE_PADDING);
                targetPoint = CGPointMake(targetPoint.x, yPos);
            }
            else {
                CGFloat xPos = (leftDist < rightDist ? ceil(CONTRACTED_SIZE / 2) + CONTRACTED_SIDE_PADDING : screenSize.width - ceil(CONTRACTED_SIZE / 2) - CONTRACTED_SIDE_PADDING);
                targetPoint = CGPointMake(xPos, targetPoint.y);
            }
        }
        else {
            CGFloat xPos = (leftDist < rightDist ? ceil(CONTRACTED_SIZE / 2) + CONTRACTED_SIDE_PADDING : screenSize.width - ceil(CONTRACTED_SIZE / 2) - CONTRACTED_SIDE_PADDING);
            targetPoint = CGPointMake(xPos, targetPoint.y);
        }
        
        __weak KIFRMenuView *weakSelf = self;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            KIFRMenuView *strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            strongSelf.center = targetPoint;
        } completion:^(BOOL finished) {
            KIFRMenuView *strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            
            strongSelf.fadeOutTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:strongSelf selector:@selector(fadeOutView:) userInfo:nil repeats:NO];
            NSData *rectData = [NSKeyedArchiver archivedDataWithRootObject:[NSValue valueWithCGRect:strongSelf.frame]];
            [[NSUserDefaults standardUserDefaults] setValue:rectData forKey:OLD_FRAME_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }];
    }
}

- (void)fadeOutView:(id)sender {
    [self.fadeOutTimer invalidate];
    self.fadeOutTimer = nil;
    
    __weak KIFRMenuView *weakSelf = self;
    [UIView animateWithDuration:0.3 delay:0 options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseInOut) animations:^{
        KIFRMenuView *strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        strongSelf.alpha = UNFOCUSSED_ALPHA;
    } completion:nil];
}

#pragma mark - Content

- (NSArray *)mainMenuUIArray {
    if (!_mainMenuUIArray) {
        _mainMenuUIArray = @[ self.exportButton, self.viewTestsButton ];
    }
    
    return _mainMenuUIArray;
}

#pragma mark - Animations

- (void)setExpanded:(BOOL)expanded animated:(BOOL)animated {
    self.isExpanded = expanded;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    [self.fadeOutTimer invalidate];
    self.fadeOutTimer = nil;
    
    if (self.isExpanded) {
        CGFloat sideSize = MIN(screenSize.width, screenSize.height) - (EXPANDED_SIDE_PADDING * 2);
        
        if (!animated) {
            self.frame = CGRectMake(EXPANDED_SIDE_PADDING, ceil((screenSize.height - sideSize) / 2), sideSize, sideSize);
            self.alpha = 1;
            [self.mainMenuUIArray setValue:@(1) forKey:@"alpha"];
            self.testsView.alpha = 0;
            [self setNeedsLayout];
            [self layoutIfNeeded];
        }
        else {
            __weak KIFRMenuView *weakSelf = self;
            [UIView animateWithDuration:0.3 animations:^{
                KIFRMenuView *strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                
                strongSelf.frame = CGRectMake(EXPANDED_SIDE_PADDING, ceil((screenSize.height - sideSize) / 2), sideSize, sideSize);
                strongSelf.alpha = 1;
                [strongSelf.mainMenuUIArray setValue:@(1) forKey:@"alpha"];
                strongSelf.testsView.alpha = 0;
                [strongSelf setNeedsLayout];
                [strongSelf layoutIfNeeded];
            }];
        }
    }
    else {
        CGFloat sidePadding = 2;
        CGFloat sideSize = CONTRACTED_SIZE;
        
        if (!animated) {
            self.frame = CGRectMake(sidePadding, ceil((screenSize.height - sideSize) / 2), sideSize, sideSize);
            [self.mainMenuUIArray setValue:@(0) forKey:@"alpha"];
            self.testsView.alpha = 0;
            [self.testsView reset];
            [self setNeedsLayout];
            [self layoutIfNeeded];
            
            self.fadeOutTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(fadeOutView:) userInfo:nil repeats:NO];
        }
        else {
            CGRect oldFrame = CGRectMake(sidePadding, ceil((screenSize.height - sideSize) / 2), sideSize, sideSize);
            NSData *rectData = [[NSUserDefaults standardUserDefaults] valueForKey:OLD_FRAME_KEY];
            if (rectData) {
                NSValue *oldFrameValue = [NSKeyedUnarchiver unarchiveObjectWithData:rectData];
                oldFrame = [oldFrameValue CGRectValue];
            }
            
            __weak KIFRMenuView *weakSelf = self;
            self.testsView.parentIsAnimating = YES;
            [UIView animateWithDuration:0.3 animations:^{
                KIFRMenuView *strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                
                strongSelf.frame = oldFrame;
                [strongSelf.mainMenuUIArray setValue:@(0) forKey:@"alpha"];
                strongSelf.testsView.alpha = 0;
                [strongSelf setNeedsLayout];
                [strongSelf layoutIfNeeded];
            } completion:^(BOOL finished) {
                KIFRMenuView *strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                
                strongSelf.testsView.parentIsAnimating = NO;
                [strongSelf.testsView reset];
                strongSelf.fadeOutTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:strongSelf selector:@selector(fadeOutView:) userInfo:nil repeats:NO];
            }];
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate Methods

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.testsView.alpha > 0 && [self.testsView pointInside:[gestureRecognizer locationInView:self.testsView] withEvent:nil]) {
        return NO;
    }
    
    return YES;
}

#pragma mark - Base64 Encoded Assets

static NSString *testIcon = @"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";

@end
