//
//  LocationMapViewController.m
//  wPinpinbox
//
//  Created by Antelis on 2018/11/14.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "LocationMapViewController.h"
#import "MapHelper.h"
#import "wTools.h"

#if(DEBUG)
#define MAPAPIKEY @"AIzaSyBKCVhRB6zjhZ0d0gcXALT8Ts4s8AfxMBk"
#else
#define MAPAPIKEY @"AIzaSyBccGhjCogT8jAtxA9H8wpjL-chOjJI1HE"
#endif
#define mapboxkey @"sk.eyJ1IjoiYW50aHkwMTExIiwiYSI6ImNqb3Fzank4NzA3cDgzcGxoNGt0Z3JiMWYifQ.lpjmNxrbXh5L6WZ4bETD9Q"

@import MapKit;
@import CoreLocation;
//@import GoogleMaps;



@interface LocationMapViewController ()<CLLocationManagerDelegate, UITextFieldDelegate,MKMapViewDelegate>//, GMSMapViewDelegate>
@property (nonatomic) IBOutlet MKMapView *map;
@property (nonatomic) CLLocationManager *locationManager;

@property (nonatomic) IBOutlet LeftPaddingTextfield *locationName;
@property (nonatomic) IBOutlet UIButton *locSearch;
@property (nonatomic) MKPointAnnotation *userTapAnnotation;

//@property (nonatomic) GMSMapView *glMap;
//@property (nonatomic) GMSMarker *curMarker;

@end

@interface MapPresentationController ()
@property (nonatomic) UIVisualEffectView *dimmyView;
@end

@interface MapAnimationTransitioning()
@property (nonatomic) BOOL isPresenting;
- (id)initWithType:(BOOL)isPresenting;
@end


@implementation LeftPaddingTextfield
- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self ) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 16)];
        view.backgroundColor = UIColor.clearColor;
        view.userInteractionEnabled = NO;
        self.leftView = view;
        self.leftViewMode = UITextFieldViewModeAlways;
    }
    
    return self;
}
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
    
    CGFloat destinedHeight = 0;
    if (@available(iOS 11.0, *)) {
        destinedHeight = to.view.safeAreaLayoutGuide.layoutFrame.size.height;
    }
    if (destinedHeight <= 0 )
        destinedHeight = [UIScreen mainScreen].bounds.size.height;
    
    __block BOOL ispresent = self.isPresenting;
    if (!ispresent) {
        to = (LocationMapViewController *) [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        to.view.transform = CGAffineTransformIdentity;
    } else {
        
        to.view.transform = CGAffineTransformMakeTranslation(0, destinedHeight);//);
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
                                to.view.transform = CGAffineTransformMakeTranslation(0, destinedHeight);
                            
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
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    //[GMSServices provideAPIKey:MAPAPIKEY];
    
    //self.placeClient = [[GMSPlacesClient alloc] init];
    
    [self addKeyboardNotification];
    [self addMapTap];
    //[self addDismissTap];
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
    
    self.baseView.transform = CGAffineTransformMakeTranslation(0, -kbSize.height);
    
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    self.baseView.transform = CGAffineTransformIdentity;
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
//  use MKLocalSearch to find a place
- (IBAction)searchViaGeocoder:(id)sender {
    [self.locationName resignFirstResponder];
    
    if (self.locationName.text.length > 1) {
        
        self.locSearch.enabled = NO;
        __block typeof(self) wself = self;
        [MapHelper searchLocation:self.locationName.text CompletionBlock:^(MKMapItem * _Nullable item, NSError * _Nullable error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                wself.locSearch.enabled = YES;
            });
            
            if (!error && item) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [wself loadMapItem:item];
                });
            } else {
                [wself planBForGeocoding];
            }
        }];
    }
}
//  Plan B For Geocoding : Mapbox API
- (void)planBForGeocoding {
    
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
- (IBAction)cancelAndDismiss:(id)sender {
    [self cancelAndDismiss];
}
- (void)cancelAndDismiss {
    [self removeKeyboardNotification];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)addMapTap {
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer  alloc] initWithTarget:self action:@selector(handleMapTap:)];
    [self.map addGestureRecognizer:tap];
    
}
- (void)addDismissTap {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDismissTap:)];
    
    [self.view addGestureRecognizer:tap];
}
- (void)handleMapTap:(UITapGestureRecognizer *)tap {
    
    [wTools ShowMBProgressHUD];
    CGPoint p = [tap locationInView:self.map];
    CLLocationCoordinate2D coord = [self.map convertPoint:p toCoordinateFromView:self.map];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord,1000,1000);
    [self.map setRegion: [self.map regionThatFits: region] animated: YES];
    __block typeof(self) wself = self;
    
    NSURLSession *s = [NSURLSession sharedSession];
    NSString *ss = @"https://api.mapbox.com/geocoding/v5/mapbox.places/%f,%f.json?access_token=%@&language=zh";
    
    NSString *target = [NSString stringWithFormat:ss,coord.longitude,coord.latitude,mapboxkey];
    
    NSURL *u = [NSURL URLWithString:[target stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    
    
    NSURLSessionDataTask *task = [s dataTaskWithURL:u completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
        });
        if (!error && data.length) {
            NSError *err = nil;
            
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
            
            if (!err && result) {
                //NSLog(@"Geocoding result : %@",result);
                NSArray *features = result[@"features"];
                if (features && features.count) {
                    NSDictionary *loc = [features firstObject];
                    NSString *place = loc[@"text"];//[@"place_name"];
                    
                    if (place && place.length) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            wself.locationName.text = place;
                            //MKPlacemark *p = [[MKPlacemark alloc] initWithCoordinate:coord];
                            [wself.map removeAnnotation:wself.userTapAnnotation];
                            wself.userTapAnnotation = [[MKPointAnnotation alloc]init];
                            wself.userTapAnnotation.title = place;
                            wself.userTapAnnotation.coordinate = coord;
                            [wself.map addAnnotation:wself.userTapAnnotation];
                        });
                        
                        return;
                    }
                }
            }
            
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            wself.locationName.text = [NSString stringWithFormat:@"%.3f,%.3f",coord.longitude, coord.latitude];
            [wself.locationName becomeFirstResponder];
        });
    }];
    
    [task resume];
    
    //    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    //    //request.naturalLanguageQuery = @"location address";
    //    request.region = MKCoordinateRegionMakeWithDistance(coord,50,50);
    //    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    //    [search startWithCompletionHandler:^(MKLocalSearchResponse * _Nullable response, NSError * _Nullable error) {
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //            [wTools HideMBProgressHUD];
    //        });
    //        if (!error && response) {
    //            NSArray *res = response.mapItems;
    //            MKMapItem *first = [res firstObject];
    //            dispatch_async(dispatch_get_main_queue(), ^{
    //                [wself loadMapItem:first];
    //                wself.locationName.text = first.name;
    //            });
    //        } else {
    //            NSLog(@"MKLocalSearch Error %@",error);
    //
    //        }
    //    }];
}
- (void)handleDismissTap:(UITapGestureRecognizer *)tap {
    
    CGPoint p = [tap locationInView:self.view];
    CGSize s = UIScreen.mainScreen.bounds.size;
    //if (p.y > 0 && p.y < s.height - 325) {
    //    [self cancelAndDismiss];
    //}
    
}
- (void)loadLocation:(NSString *)l {
    if (l && l.length > 0) {
        self.locationName.text = l;
        [self searchViaGeocoder:self.locSearch];
        [self.locationName becomeFirstResponder];
    }
}

- (void)moveMapWithLatitude:(CLLocationDegrees)la Longitude:(CLLocationDegrees)lo {
    

    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *ans = [NSArray arrayWithArray:self.map.annotations];
        [wself.map removeAnnotations:ans];
        
        CLLocationCoordinate2D l = CLLocationCoordinate2DMake(la, lo);
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(l,1000,1000);
        [wself.map setRegion: [self.map regionThatFits: region] animated: YES];
        wself.userTapAnnotation = [[MKPointAnnotation alloc] init];
        wself.userTapAnnotation.coordinate = l;
        wself.userTapAnnotation.title = @"";
        
        
        [wself.map addAnnotation: self.userTapAnnotation];
    });
    
}
#pragma mark - Add the poi to map
- (void)loadMapItem:(MKMapItem *)item {
    MKPlacemark *mark = item.placemark;
    
    NSArray *ans = [NSArray arrayWithArray:self.map.annotations];
    [self.map removeAnnotations:ans];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(mark.coordinate,1000,1000);
    [self.map setRegion: [self.map regionThatFits: region] animated: YES];
    
    self.userTapAnnotation = [[MKPointAnnotation alloc] init];
    self.userTapAnnotation.coordinate = mark.coordinate;
    self.userTapAnnotation.title = item.name;
    
    
    [self.map addAnnotation: self.userTapAnnotation];
}
- (void)loadPlacemark:(CLPlacemark *)mark {
    
    
    NSArray *ans = [NSArray arrayWithArray:self.map.annotations];
    [self.map removeAnnotations:ans];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(mark.location.coordinate,1000,1000);
    [self.map setRegion: [self.map regionThatFits: region] animated: YES];
    
    self.userTapAnnotation = [[MKPointAnnotation alloc] init];
    self.userTapAnnotation.coordinate = mark.location.coordinate;
    self.userTapAnnotation.title = mark.name;
    
    
    [self.map addAnnotation: self.userTapAnnotation];
}

#pragma mark CLLocationManagerDelegate functions
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (locations.count > 0) {
        CLLocation *l = [locations firstObject];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(l.coordinate,00,1000);
        [self.map setRegion: [self.map regionThatFits: region] animated: YES];
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        point.coordinate = l.coordinate;
        point.title = @"";
        
        NSArray *ans = [NSArray arrayWithArray:self.map.annotations];
        [self.map removeAnnotations:ans];
        [self.map addAnnotation: point];
        
        [self.locationManager stopUpdatingLocation];
        
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
