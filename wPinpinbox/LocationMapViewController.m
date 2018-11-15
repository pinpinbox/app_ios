//
//  LocationMapViewController.m
//  wPinpinbox
//
//  Created by Antelis on 2018/11/14.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "LocationMapViewController.h"
#import <MapKit/MapKit.h>

@interface LocationMapViewController ()<CLLocationManagerDelegate, MKMapViewDelegate>
@property (nonatomic) IBOutlet MKMapView *map;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
- (void)showUpSheet;
- (void)slideSheet;
@end

@interface MapPresentationController ()
@property (nonatomic) UIView *dimmyView;
@end

@interface MapAnimationTransitioning()
@property (nonatomic) BOOL isPresenting;
- (id)initWithType:(BOOL)isPresenting;
@end

@implementation MapPresentationController
@synthesize dimmyView;

- (void)presentationTransitionWillBegin{

    self.dimmyView = [[UIView alloc] initWithFrame:self.containerView.frame];
    self.dimmyView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.55];
    self.dimmyView.alpha = 1;
    [self.containerView addSubview:self.dimmyView];
    
   UIViewController *p = self.presentedViewController;
    [p.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {

        self.dimmyView.alpha = 1;
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {

    }];
}
- (void)dismissalTransitionWillBegin {
    UIViewController *p = self.presentedViewController;
    [p.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.dimmyView.alpha = 0;
    } completion:nil];
}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    }];
}
@end

@implementation MapAnimationTransitioning
- (id)initWithType:(BOOL)isPrensenting {
    self = [super init];
    if (self) {
        
        self.isPresenting = isPrensenting;
    }
    return self;
}
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5;
}
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    LocationMapViewController *to = (LocationMapViewController *) [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    to.view.layer.shadowColor = UIColor.blackColor.CGColor;
    to.view.layer.shadowOffset = CGSizeMake(0.0, -8.0);
    to.view.layer.shadowRadius = 8.0;
    to.view.layer.shadowOpacity = 0.3;
    
    [to setNeedsStatusBarAppearanceUpdate];
    __block BOOL ispresent = self.isPresenting;
    if (!ispresent) {
        to = (LocationMapViewController *) [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        to.view.transform = CGAffineTransformIdentity;
    } else {
        to.view.transform = CGAffineTransformMakeTranslation(0, 325);
        [transitionContext.containerView addSubview:to.view];
    }
    
    [UIView animateWithDuration: [self transitionDuration:transitionContext]
                          delay:0.0
         usingSpringWithDamping:1.0
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveLinear animations:^{
        
        if (ispresent)
            to.view.transform = CGAffineTransformIdentity;
        else
            to.view.transform = CGAffineTransformMakeTranslation(0, 325);

    } completion:^(BOOL finished) {
        [transitionContext completeTransition:finished];
    }];
    
    
}

@end


@implementation LocationMapViewController
- (id)init {
    self = [super init];
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.transitioningDelegate = self;
    //self.modalPresentationCapturesStatusBarAppearance = YES;
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.transitioningDelegate = self;
    //self.modalPresentationCapturesStatusBarAppearance = YES;
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}
- (IBAction) dismissAndAdd:(id)sender {
    
    NSLog(@"%lf,%lf",self.map.region.center.latitude, self.map.region.center.longitude);
    [self.locationManager stopUpdatingLocation];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (locations.count > 0) {
        CLLocation *l = [locations firstObject];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(l.coordinate,2000,2000);
        [self.map setRegion: [self.map regionThatFits: region] animated: YES];
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        point.coordinate = l.coordinate;
        point.title = @"current";
        
        [self.map addAnnotation: point];
    }
    
}
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation];
    }
}
- (void)showUpSheet {
    self.bottomConstraint.constant = 0;
}
- (void)slideSheet {
    self.bottomConstraint.constant = 325;
}
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    
    return [[MapAnimationTransitioning alloc] initWithType:YES];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[MapAnimationTransitioning alloc] initWithType:NO];
}
- (nullable UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(nullable UIViewController *)presenting sourceViewController:(UIViewController *)source {
    
    return [[MapPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}
@end
