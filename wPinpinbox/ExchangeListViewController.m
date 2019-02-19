//
//  ExchangeListViewController.m
//  wPinpinbox
//
//  Created by David on 06/03/2018.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "ExchangeListViewController.h"
#import "wTools.h"
#import "UIColor+Extensions.h"
#import "GlobalVars.h"
#import "AppDelegate.h"
#import "LabelAttributeStyle.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "CAPSPageMenu.h"
#import "CheckExchangeViewController.h"

#import "CheckExchangeCollectionViewCell.h"
#import "ExchangeInfoEditViewController.h"
#import "ZOZolaZoomTransition.h"

#import "UIView+Toast.h"

@interface ExchangeListViewController () <CAPSPageMenuDelegate, CheckExchangeViewControllerDelegate, UIViewControllerTransitioningDelegate, ZOZolaZoomTransitionDelegate, UINavigationControllerDelegate, ExchangeInfoEditViewControllerDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIView *navBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarHeight;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic) CAPSPageMenu *pageMenu;
@property (weak, nonatomic) UIImageView *zoomView;

@property (weak, nonatomic) UICollectionView *collectionView;
@property (weak, nonatomic) CheckExchangeCollectionViewCell *selectedCell;

@property (nonatomic) CheckExchangeViewController *checkExchangeVC1;
@property (nonatomic) CheckExchangeViewController *checkExchangeVC2;
@end

@implementation ExchangeListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    for (UIViewController *vc in self.navigationController.viewControllers) {
        NSLog(@"vc: %@", vc);
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.delegate = self;
    
    [self initialValueSetup];
    [self createPageMenu];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.enabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initialValueSetup {
    NSLog(@"initialValueSetup");
    
    self.navigationController.delegate = self;
    
    self.navBarView.backgroundColor = [UIColor barColor];
    self.titleLabel.text = @"兌換清單";
    self.titleLabel.textColor = [UIColor firstGrey];
    self.titleLabel.font = [UIFont boldSystemFontOfSize: 18];
    [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: self.titleLabel content: self.titleLabel.text];
}

- (void)createPageMenu {
    NSLog(@"createPageMenu");
    self.checkExchangeVC1 = [[UIStoryboard storyboardWithName: @"CheckExchangeVC" bundle: nil] instantiateViewControllerWithIdentifier: @"CheckExchangeViewController"];
    self.checkExchangeVC1.title = @"未兌換";
    self.checkExchangeVC1.delegate = self;
    self.checkExchangeVC1.hasExchanged = NO;
    
    self.checkExchangeVC2 = [[UIStoryboard storyboardWithName: @"CheckExchangeVC" bundle: nil] instantiateViewControllerWithIdentifier: @"CheckExchangeViewController"];
    self.checkExchangeVC2.title = @"已完成";
    self.checkExchangeVC2.delegate = self;
    self.checkExchangeVC2.hasExchanged = YES;
    
    NSArray *controllerArray = @[self.checkExchangeVC1, self.checkExchangeVC2];
    NSDictionary *parameters = @{
                                 CAPSPageMenuOptionMenuItemSeparatorWidth: @(4.3),
                                 CAPSPageMenuOptionUseMenuLikeSegmentedControl: @(YES),
                                 CAPSPageMenuOptionMenuItemSeparatorPercentageHeight: @(0.1),
                                 CAPSPageMenuOptionScrollMenuBackgroundColor: [UIColor clearColor],
                                 CAPSPageMenuOptionViewBackgroundColor: [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],
                                 CAPSPageMenuOptionSelectionIndicatorColor: [UIColor clearColor],
                                 CAPSPageMenuOptionBottomMenuHairlineColor: [UIColor clearColor],
                                 CAPSPageMenuOptionMenuItemFont: [UIFont boldSystemFontOfSize: 18.0],
                                 CAPSPageMenuOptionSelectedMenuItemLabelColor: [UIColor firstGrey],
                                 CAPSPageMenuOptionUnselectedMenuItemLabelColor: [UIColor secondGrey],
                                 CAPSPageMenuOptionMenuHeight: @(50.0)
                                 };
    
    CGFloat y = 0;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 1136:
                printf("iPhone 5 or 5S or 5C");
                self.navBarHeight.constant = 48;
                y = 68;
                break;
            case 1334:
                printf("iPhone 6/6S/7/8");
                self.navBarHeight.constant = 48;
                y = 68;
                break;
            case 1920:
                printf("iPhone 6+/6S+/7+/8+");
                self.navBarHeight.constant = 48;
                y = 68;
                break;
            case 2208:
                printf("iPhone 6+/6S+/7+/8+");
                self.navBarHeight.constant = 48;
                y = 68;
                break;
            case 2436:
                printf("iPhone X");
                self.navBarHeight.constant = navBarHeightConstant;
                y = 75;
                break;
            default:
                printf("unknown");
                self.navBarHeight.constant = 48;
                y = 68;
                break;
        }
    }
    
    self.pageMenu = [[CAPSPageMenu alloc] initWithViewControllers:controllerArray frame:CGRectMake(0.0, y, self.view.frame.size.width, self.view.frame.size.height) options:parameters];
    self.pageMenu.delegate = self;
    [self.view addSubview: self.pageMenu.view];
    [self.view bringSubviewToFront: self.navBarView];
}

- (IBAction)backBtnPress:(id)sender {
    NSLog(@"backBtnPress");
    NSLog(@"self.navigationController");
    
    self.navigationController.delegate = nil;
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.myNav popViewControllerAnimated: YES];
}

#pragma mark - CheckExchangeViewControllerDelegate Methods
- (void)didSelectCell:(UICollectionView *)collectionView
                 cell:(CheckExchangeCollectionViewCell *)selectedCell
          exchangeDic:(NSMutableDictionary *)exchangeDic
         hasExchanged:(BOOL)hasExchanged           
{
    NSLog(@"didSelectCell");
//    ExchangeInfoEditViewController *exchangeInfoEditVC = [[ExchangeInfoEditViewController alloc] initWithExchangeStuff: exchangeStuff];
    ExchangeInfoEditViewController *exchangeInfoEditVC = [[ExchangeInfoEditViewController alloc] init];
    exchangeInfoEditVC.exchangeDic = exchangeDic;
    exchangeInfoEditVC.hasExchanged = hasExchanged;
    exchangeInfoEditVC.isExisting = YES;
    exchangeInfoEditVC.delegate = self;
    
    self.selectedCell = selectedCell;
    self.collectionView = collectionView;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.myNav pushViewController: exchangeInfoEditVC animated: YES];
}

#pragma mark - ExchangeInfoEditViewControllerDelegate Methods
- (void)finishExchange:(NSMutableDictionary *)exchangeDic
                   bgV:(UIView *)bgV {
    NSLog(@"finishExchange");
    NSLog(@"exchangeDic: %@", exchangeDic);
    
    [self.checkExchangeVC1 removeDicData: exchangeDic];
    
    double delayInSeconds = 0.7;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.pageMenu moveToPage: 1];
        [self.checkExchangeVC2 addDicData: exchangeDic];
    });        
}

#pragma mark - UINavigationControllerDelegate Methods
- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC {
    // Sanity
    if (fromVC != self && toVC != self) return nil;
    
    // Determine if we're presenting or dismissing
    ZOTransitionType type = (fromVC == self) ? ZOTransitionTypePresenting : ZOTransitionTypeDismissing;
    
    // Create a transition instance with the selected cell's imageView as the target view
    ZOZolaZoomTransition *zoomTransition = [ZOZolaZoomTransition transitionFromView:_selectedCell.imageView
                                                                               type:type
                                                                           duration:0.5
                                                                           delegate:self];
    zoomTransition.fadeColor = self.collectionView.backgroundColor;
    
    return zoomTransition;
}

#pragma mark - ZOZolaZoomTransitionDelegate Methods
- (CGRect)zolaZoomTransition:(ZOZolaZoomTransition *)zoomTransition
        startingFrameForView:(UIView *)targetView
              relativeToView:(UIView *)relativeView
          fromViewController:(UIViewController *)fromViewController
            toViewController:(UIViewController *)toViewController {
    
    if (fromViewController == self) {
        // We're pushing to the detail controller. The starting frame is taken from the selected cell's imageView.
        return [_selectedCell.imageView convertRect:_selectedCell.imageView.bounds toView:relativeView];
    } else if ([fromViewController isKindOfClass:[ExchangeInfoEditViewController class]]) {
        // We're popping back to this master controller. The starting frame is taken from the detailController's imageView.
        ExchangeInfoEditViewController *detailController = (ExchangeInfoEditViewController *)fromViewController;
        return [detailController.imageView convertRect:detailController.imageView.bounds toView:relativeView];
    }
    
    return CGRectZero;
}

- (CGRect)zolaZoomTransition:(ZOZolaZoomTransition *)zoomTransition
       finishingFrameForView:(UIView *)targetView
              relativeToView:(UIView *)relativeView
          fromViewController:(UIViewController *)fromViewController
            toViewController:(UIViewController *)toViewController {
    
    if (fromViewController == self) {
        // We're pushing to the detail controller. The finishing frame is taken from the detailController's imageView.
        ExchangeInfoEditViewController *detailController = (ExchangeInfoEditViewController *)toViewController;
        return [detailController.imageView convertRect:detailController.imageView.bounds toView:relativeView];
    } else if ([fromViewController isKindOfClass:[ExchangeInfoEditViewController class]]) {
        // We're popping back to this master controller. The finishing frame is taken from the selected cell's imageView.
        return [_selectedCell.imageView convertRect:_selectedCell.imageView.bounds toView:relativeView];
    }
    
    return CGRectZero;
}

- (NSArray *)supplementaryViewsForZolaZoomTransition:(ZOZolaZoomTransition *)zoomTransition {
    // Here we're returning all UICollectionViewCells that are clipped by the edge
    // of the screen. These will be used as "supplementary views" so that the clipped
    // cells will be drawn in their entirety rather than appearing cut off during the
    // transition animation.
    
    NSMutableArray *clippedCells = [NSMutableArray arrayWithCapacity:[[self.collectionView visibleCells] count]];
    for (UICollectionViewCell *visibleCell in self.collectionView.visibleCells) {
        CGRect convertedRect = [visibleCell convertRect:visibleCell.bounds toView:self.view];
        if (!CGRectContainsRect(self.view.frame, convertedRect)) {
            [clippedCells addObject:visibleCell];
        }
    }
    return clippedCells;
}

- (CGRect)zolaZoomTransition:(ZOZolaZoomTransition *)zoomTransition
   frameForSupplementaryView:(UIView *)supplementaryView
              relativeToView:(UIView *)relativeView {
    
    return [supplementaryView convertRect:supplementaryView.bounds toView:relativeView];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
