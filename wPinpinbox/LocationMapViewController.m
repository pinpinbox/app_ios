//
//  LocationMapViewController.m
//  wPinpinbox
//
//  Created by Antelis on 2018/11/14.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "LocationMapViewController.h"

#if(DEBUG)
#define MAPAPIKEY @"AIzaSyBKCVhRB6zjhZ0d0gcXALT8Ts4s8AfxMBk"
#else
#define MAPAPIKEY @"AIzaSyBccGhjCogT8jAtxA9H8wpjL-chOjJI1HE"
#endif

#define mapboxkey @"sk.eyJ1IjoiYW50aHkwMTExIiwiYSI6ImNqb3Fzank4NzA3cDgzcGxoNGt0Z3JiMWYifQ.lpjmNxrbXh5L6WZ4bETD9Q"

@import MapKit;
@import GoogleMaps;



@interface LocationMapViewController ()<CLLocationManagerDelegate, UITextFieldDelegate, GMSMapViewDelegate>
@property (nonatomic) IBOutlet MKMapView *map;
@property (nonatomic) CLLocationManager *locationManager;

@property (nonatomic) IBOutlet UITextField *locationName;
@property (nonatomic) IBOutlet UIButton *locSearch;
@property (nonatomic) MKPointAnnotation *userTapAnnotation;

@property (nonatomic) GMSMapView *glMap;
@property (nonatomic) GMSMarker *curMarker;

@end

@interface MapPresentationController ()
@property (nonatomic) UIVisualEffectView *dimmyView;
@end

@interface MapAnimationTransitioning()
@property (nonatomic) BOOL isPresenting;
- (id)initWithType:(BOOL)isPresenting;
@end

#pragma mark - Present VC with ActionSheet-like style -
@implementation MapPresentationController
@synthesize dimmyView;

- (void)presentationTransitionWillBegin{
    
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle: UIBlurEffectStyleDark];
    self.dimmyView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];//[[UIView alloc] initWithFrame:
    self.dimmyView.frame = self.containerView.frame;
    [self.containerView addSubview:self.dimmyView];
    
   UIViewController *p = self.presentedViewController;
    [p.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {

        self.dimmyView.alpha = 0.75;
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

#pragma mark - User location info VC -

@implementation LocationMapViewController
- (id)init {
    self = [super init];
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.transitioningDelegate = self;
    self.modalPresentationCapturesStatusBarAppearance = YES;
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.transitioningDelegate = self;
    self.modalPresentationCapturesStatusBarAppearance = YES;
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    self.map.hidden = YES;
    [GMSServices provideAPIKey:MAPAPIKEY];
    //[GMSPlacesClient provideAPIKey:MAPAPIKEY];
    //self.placeClient = [[GMSPlacesClient alloc] init];
    
    [self addKeyboardNotification];
    [self addMapTap];
    [self addDismissTap];
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)addKeyboardNotification {
    self.locationName.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)removeKeyboardNotification {
    NSLog(@"");
    NSLog(@"removeKeyboardNotification");
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIKeyboardDidShowNotification
                                                  object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIKeyboardWillHideNotification
                                                  object: nil];
}
- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey: UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    self.view.transform = CGAffineTransformMakeTranslation(0, -kbSize.height);
    
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    self.view.transform = CGAffineTransformIdentity;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.locationName resignFirstResponder];
    [self searchViaGeocoder:self.locSearch];
    return NO;
}
- (IBAction) dismissAndAdd:(id)sender {
    
    [self.locationManager stopUpdatingLocation];
    [self removeKeyboardNotification];
    __block typeof(self) wself = self;
    __block NSString *pn = self.locationName.text;
    [self dismissViewControllerAnimated:YES completion:^{
        if (sender && wself.locationDelegate) {
            [wself.locationDelegate didSelectLocation:pn];
        }
    }];
}

- (IBAction)searchViaGeocoder:(id)sender {
    [self.locationName resignFirstResponder];
    
    if (self.locationName.text.length > 1) {
        
        self.locSearch.enabled = NO;
        NSURLSession *s = [NSURLSession sharedSession];
        NSString *ss = @"https://api.mapbox.com/geocoding/v5/mapbox.places/%@.json?limit=3&access_token=%@";
        NSString *target = [NSString stringWithFormat:ss,self.locationName.text, mapboxkey];
        NSURL *u = [NSURL URLWithString:[target stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
        
        __block typeof(self) wself = self;
        NSURLSessionDataTask *task = [s dataTaskWithURL:u completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                wself.locSearch.enabled = YES;
            });
            
            if (!error && data.length) {
                NSError *err = nil;
                
                NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
                
                if (!err && result) {
                    //NSLog(@"Geocoding result : %@",result);
                    NSArray *features = result[@"features"];
                    if (features && features.count) {
                        NSDictionary *loc = [features firstObject];
                        NSDictionary *gl =loc[@"geometry"];
                        NSArray *cord = gl[@"coordinates"];
                        if (cord && cord.count == 2) {
                            CLLocationDegrees lo = [cord[0] doubleValue];
                            CLLocationDegrees la = [cord[1] doubleValue];
                            [wself moveMapWithLatitude:la Longitude:lo];
                        }
                    }
                }
                
            } else {
                NSLog(@"Geocoding Error %@",error);
            }
            
        }];
        [task resume];

    }
}
- (IBAction)cancelAndDismiss:(id)sender {
    [self removeKeyboardNotification];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)addMapTap {
    /*
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer  alloc] initWithTarget:self action:@selector(handleMapTap:)];
    [self.map addGestureRecognizer:tap];
     */
}
- (void)addDismissTap {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDismissTap:)];
    
    [self.view addGestureRecognizer:tap];
}
- (void)handleMapTap:(UITapGestureRecognizer *)tap {
    
}
- (void)handleDismissTap:(UITapGestureRecognizer *)tap {
    
    CGPoint p = [tap locationInView:self.view];
    CGSize s = UIScreen.mainScreen.bounds.size;
    if (p.y > 0 && p.y < s.height - 325) {
        [self cancelAndDismiss:nil];
    }
    
}
- (void)loadLocation:(NSString *)l {
    if (l && l.length > 0) {
        self.locationName.text = l;
        [self searchViaGeocoder:self.locSearch];
    }
}
- (void)moveMapWithLatitude:(CLLocationDegrees)la Longitude:(CLLocationDegrees)lo {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:la longitude:lo
                                                                    zoom:15];
        [self.glMap clear];
        [self.glMap animateToCameraPosition:camera];
        
        self.locSearch.enabled = YES;
        
        self.curMarker = [[GMSMarker alloc] init];
        self.curMarker.position = CLLocationCoordinate2DMake(la,lo);
        self.curMarker.title = @"";
        self.curMarker.map = self.glMap;
    });
}
#pragma mark - GMSMapViewDelegate
- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    
    NSURLSession *s = [NSURLSession sharedSession];
    NSString *ss = @"https://api.mapbox.com/geocoding/v5/mapbox.places/%f,%f.json?access_token=%@&reverseMode=score";
    
    NSString *target = [NSString stringWithFormat:ss,coordinate.latitude,coordinate.longitude,mapboxkey];
    
    NSURL *u = [NSURL URLWithString:[target stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    
    __block typeof(self) wself = self;
    NSURLSessionDataTask *task = [s dataTaskWithURL:u completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!error && data.length) {
            NSError *err = nil;
            
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
            
            if (!err && result) {
                //NSLog(@"Geocoding result : %@",result);
                NSArray *features = result[@"features"];
                if (features && features.count) {
                    NSDictionary *loc = [features firstObject];
                    NSString *place = loc[@"place_name"];
                    
                    if (place && place.length) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            wself.locationName.text = place;
                        });
                        
                        return;
                    }
                }
            }
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            wself.locationName.text = [NSString stringWithFormat:@"%.3f,%.3f",coordinate.latitude, coordinate.longitude];
            
        });
    }];
    
    [task resume];
    
    
}
#pragma mark CLLocationManagerDelegate functions
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (locations.count > 0) {
        CLLocation *l = [locations firstObject];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(l.coordinate,200,200);
        [self.map setRegion: [self.map regionThatFits: region] animated: YES];
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        point.coordinate = l.coordinate;
        point.title = @"current";
        
        NSArray *ans = [NSArray arrayWithArray:self.map.annotations];
        [self.map removeAnnotations:ans];
        [self.map addAnnotation: point];
        
        [self.locationManager stopUpdatingLocation];
        
        
        
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:l.coordinate.latitude longitude:l.coordinate.longitude
                                                                     zoom:12];
        self.glMap = [GMSMapView mapWithFrame:CGRectZero camera:camera];
        self.glMap.myLocationEnabled = YES;
        self.glMap.frame = self.map.frame;
        UIView *sv = self.map.superview;
        self.glMap.layer.cornerRadius = 6;
        [sv addSubview:self.glMap];
        [sv bringSubviewToFront:self.glMap];
        self.glMap.delegate = self;
        self.curMarker = [[GMSMarker alloc] init];
        self.curMarker.position = CLLocationCoordinate2DMake(l.coordinate.latitude, l.coordinate.longitude);
        self.curMarker.title = @"";
        self.curMarker.map = self.glMap;

    }
    
}
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation];
    }
}
#pragma mark UIViewControllerTransitioningDelegat functions
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
