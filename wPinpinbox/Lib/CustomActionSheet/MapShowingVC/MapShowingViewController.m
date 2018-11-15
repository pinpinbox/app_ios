//
//  MapShowingViewController.m
//  wPinpinbox
//
//  Created by David Lee on 2017/8/20.
//  Copyright © 2017年 Angus. All rights reserved.
//

#import "MapShowingViewController.h"
#import "MyLayout.h"
#import <MapKit/MapKit.h>
#import "UIColor+Extensions.h"
//#import "MBProgressHUD.h"
#import "boxAPI.h"
#import "LabelAttributeStyle.h"

@interface MapShowingViewController ()
{
    float lon;
    float lat;
}
@property (weak, nonatomic) IBOutlet MyLinearLayout *actionSheetView;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *dismissBtn;

@end

@implementation MapShowingViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    /*
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(handleTapFromView:)];
    [self.view addGestureRecognizer: tapGestureRecognizer];
    tapGestureRecognizer.delegate = self;
     */
    [self slideIn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Tap Gesture Recognizer Method

- (void) handleTapFromView: (UITapGestureRecognizer *)recognizer
{
    [self slideOut];
}
*/

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"");
    NSLog(@"touchesBegan");
    
    UITouch *touch = [touches anyObject];
    NSLog(@"touch.view: %@", touch.view);
    NSLog(@"touch.view.tag: %d", (int)touch.view.tag);
    
    if (touch.view.tag == 100) {
        [self slideOut];
    }
}

#pragma mark - IBAction Method

- (IBAction)dismissBtnPress:(id)sender {    
    [self slideOut];
}
- (void)processGeoDataResult:(NSDictionary *)locationData {
    
    if (locationData == nil) {
        NSLog(@"locationData == nil");
    } else {
        NSLog(@"locationData != nil");
        
        if (locationData) {
            if (locationData[@"results"]) {
                NSArray *result = locationData[@"results"];
                
                if (result.count > 0) {
                    NSDictionary *dic = result[0];
                    NSDictionary *location = dic[@"geometry"][@"location"];
                    lat = [location[@"lat"] floatValue];
                    lon = [location[@"lng"] floatValue];
                    
                    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(lat, lon), 3000, 3000);
                    [self.mapView setRegion: [self.mapView regionThatFits: region] animated: YES];
                    
                    NSLog(@"formatted_address: %@", dic[@"formatted_address"]);
                    NSString *formattedAddress = dic[@"formatted_address"];
                    
                    // Add an annotation
                    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
                    point.coordinate = CLLocationCoordinate2DMake(lat, lon);
                    point.title = formattedAddress;
                    
                    [self.mapView addAnnotation: point];
                }
            }
        }
    }
}
- (void)slideIn {
    self.view.frame = [[UIScreen mainScreen] bounds];
    
    CGRect frame = self.actionSheetView.frame;
    frame.origin = CGPointMake(0.0, self.view.bounds.size.height - self.actionSheetView.frame.size.height);
    self.actionSheetView.frame = frame;
    
    self.actionSheetView.myLeftMargin = self.actionSheetView.myRightMargin = 0;
    self.actionSheetView.myBottomMargin = 0;
    self.actionSheetView.myCenterXOffset = 0;
    //self.actionSheetView.backgroundColor = [UIColor thirdMain];
    
    self.actionSheetView.gravity = MyMarginGravity_Horz_Center | MyMarginGravity_Vert_Center;
    
    [self.view addSubview: self.actionSheetView];

    //self.locationLabel.backgroundColor = [UIColor redColor];
    self.locationLabel.wrapContentHeight = YES;
    self.locationLabel.wrapContentWidth = YES;
    self.locationLabel.numberOfLines = 3;
    self.locationLabel.text = self.locationStr;
    [LabelAttributeStyle changeGapString: self.locationLabel content: self.locationStr];
    self.locationLabel.textColor = [UIColor whiteColor];
    self.locationLabel.font = [UIFont boldSystemFontOfSize: 24];
    //self.locationLabel.myCenterXOffset = 0;
    self.locationLabel.myTopMargin = 16;
    self.locationLabel.myLeftMargin = self.locationLabel.myRightMargin = 32;
    self.locationLabel.myBottomMargin = 16;
    
    
    //self.mapView.myCenterXOffset = 0;
    self.mapView.myTopMargin = 16;
    self.mapView.myBottomMargin = 4;
    
    //self.dismissBtn.myCenterXOffset = 0;
    self.dismissBtn.myTopMargin = 4;
    self.dismissBtn.myBottomMargin = 32;
    
    // set up an animation for the transition between the views
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.5];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromTop];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    self.view.alpha = 1.0f;
    
    [[self.actionSheetView layer] addAnimation: animation forKey: @"TransitionToActionSheet"];
    
    
    // MapView Data Setting
    if (![self.locationStr isEqualToString:@""]) {
        //[MBProgressHUD showHUDAddedTo: self.view animated: YES];
        __block typeof(self) wself = self;
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            
            NSString *respone=[boxAPI api_GET:[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=false", wself.locationStr] ];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //[MBProgressHUD hideHUDForView: self.view animated: YES];
                
                if (respone != nil) {
                    NSLog(@"response from api_GET: %@",respone);
                    
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    NSDictionary *locationData;
                    locationData = [dic mutableCopy];
                    
                    NSLog(@"locationData: %@", locationData);
                    [wself processGeoDataResult:locationData];
                    
                }
            });
        });
    }
}

#pragma mark - Custom ActionSheet Methods

- (void)slideOut {
    [UIView beginAnimations:@"removeFromSuperviewWithAnimation" context:nil];
    
    // Set delegate and selector to remove from superview when animation completes
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    
    // Move this view to bottom of superview
    CGRect frame = self.actionSheetView.frame;
    frame.origin = CGPointMake(0.0, self.view.bounds.size.height);
    self.actionSheetView.frame = frame;
    
    [UIView commitAnimations];
    
    if ([self.delegate respondsToSelector: @selector(mapShowingActionSheetDidSlideOut:)]) {
        [self.delegate mapShowingActionSheetDidSlideOut: self];
    }
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    if ([animationID isEqualToString:@"removeFromSuperviewWithAnimation"]) {
        [self.view removeFromSuperview];
    }
}
#pragma mark -

- (void)addButtonAction:(NSString *)title target:(id)target action:(SEL)action {
    
    [self.dismissBtn setImage:nil forState:UIControlStateNormal];
    [self.dismissBtn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [self.dismissBtn setTitle:title forState:UIControlStateNormal];
    
}
@end
