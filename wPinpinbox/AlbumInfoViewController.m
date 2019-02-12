//
//  AlbumInfoViewController.m
//  wPinpinbox
//
//  Created by David on 2018/8/7.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "AlbumInfoViewController.h"
#import "UIColor+Extensions.h"
#import "MyLinearLayout.h"
#import "AppDelegate.h"
#import "GlobalVars.h"
#import "wTools.h"
#import "MapHelper.h"
#import "LabelAttributeStyle.h"
#import "CustomIOSAlertView.h"
#import "UIViewController+ErrorAlert.h"

@import MapKit;
@import CoreLocation;

@interface AlbumInfoViewController ()<CLLocationManagerDelegate> {
    float lon;
    float lat;
}
@property (weak, nonatomic) IBOutlet MyLinearLayout *navBarView;
@property (weak, nonatomic) IBOutlet UIButton *dismissBtn;

@property (weak, nonatomic) IBOutlet MyLinearLayout *bgLayout;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet MyLinearLayout *contentVertLayout;
@property (weak, nonatomic) IBOutlet UILabel *topicLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet MyLinearLayout *creatorInfoHorzLayout;
@property (weak, nonatomic) IBOutlet UIImageView *nameImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *routeButton;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLLocation *current;
@end

@implementation AlbumInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initialValueSetup];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"AlbumInfoViewController viewWillDisappear");
    
    if ([self.delegate respondsToSelector: @selector(albumInfoViewControllerDisappear:)]) {
        [self.delegate albumInfoViewControllerDisappear: self];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    CGRect r1 = [self.view convertRect:self.mapView.frame fromView:self.mapView.superview];
    self.routeButton.frame = CGRectMake(r1.origin.x+r1.size.width-72, r1.origin.y+8, 64, 64);
    
}
- (void)viewWillLayoutSubviews {
    NSLog(@"----------------------");
    NSLog(@"AlbumInfoViewController");
    NSLog(@"viewWillLayoutSubviews");
    [self checkDeviceOrientation];
    
    /*
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 1136:
                printf("iPhone 5 or 5S or 5C");
                break;
            case 1334:
                printf("iPhone 6/6S/7/8");
                break;
            case 1920:
                printf("iPhone 6+/6S+/7+/8+");
                break;
            case 2208:
                printf("iPhone 6+/6S+/7+/8+");
                break;
            case 2436:
                printf("iPhone X");
                
                break;
            default:
                printf("unknown");
                break;
        }
    }
     */
}

- (void)checkDeviceOrientation {
    NSLog(@"----------------------");
    NSLog(@"checkDeviceOrientation");
    
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
        NSLog(@"UIDeviceOrientationIsPortrait");
        self.bgLayout.orientation = 0;
        self.navBarView.myRightMargin = 0;
        self.dismissBtn.myTopMargin = 32;
        self.dismissBtn.myLeftMargin = 16;
        self.contentVertLayout.padding = UIEdgeInsetsMake(0, 16, 5, 16);
    }
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
        NSLog(@"UIDeviceOrientationIsLandscape");
        self.bgLayout.orientation = 1;
        self.dismissBtn.myTopMargin = 16;
        self.dismissBtn.myLeftMargin = 32;
        self.navBarView.myRightMargin = [UIScreen mainScreen].bounds.size.width * 0.3;
        self.contentVertLayout.padding = UIEdgeInsetsMake(0, 32, 5, 16);
    }
}

/*
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"viewWillTransitionToSize");
    [super viewWillTransitionToSize: size withTransitionCoordinator: coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (orientation == 1) {
            NSLog(@"Portrait Mode");
            
        } else {
            NSLog(@"Landscape Mode");
            
        }
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        NSLog(@"completions");
    }];
}
*/

#pragma mark -
- (void)initialValueSetup {
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    self.navBarView.backgroundColor = [UIColor barColor];
    self.navBarView.myTopMargin = 0;
    self.navBarView.myLeftMargin = self.navBarView.myRightMargin = 0;
    
    self.dismissBtn.myTopMargin = 32;
    self.dismissBtn.myLeftMargin = 16;
    
    //self.bgLayout.backgroundColor = [UIColor yellowColor];
    self.bgLayout.myLeftMargin = self.bgLayout.myRightMargin = 0;
    self.bgLayout.myTopMargin = self.bgLayout.myBottomMargin = 0;
    
    self.contentVertLayout.myLeftMargin = self.contentVertLayout.myRightMargin = 0;
    self.contentVertLayout.padding = UIEdgeInsetsMake(0, 16, 5, 16);
    //self.contetVertLayout.backgroundColor = [UIColor greenColor];
    
    if ([wTools objectExists: self.data[@"album"][@"name"]]) {
        self.topicLabel.text = self.data[@"album"][@"name"];
        NSLog(@"self.topicLabel.text: %@", self.topicLabel.text);
    }
    self.topicLabel.textColor = [UIColor firstGrey];
    self.topicLabel.font = [UIFont boldSystemFontOfSize: 28];
    self.topicLabel.numberOfLines = 0;
    [self.topicLabel sizeToFit];
    self.topicLabel.myTopMargin = 16;
    //    self.topicLabel.myLeftMargin = 16;
    //    self.topicLabel.myRightMargin = 16;
    self.topicLabel.wrapContentHeight = YES;
    [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: self.topicLabel content: self.topicLabel.text];
    
    if ([wTools objectExists: self.data[@"album"][@"description"]]) {
        self.descriptionLabel.text = self.data[@"album"][@"description"];
        NSLog(@"self.descriptionLabel.text: %@", self.descriptionLabel.text);
    }
    
    self.descriptionLabel.textColor = [UIColor firstGrey];
    self.descriptionLabel.font = [UIFont systemFontOfSize: 18];
    self.descriptionLabel.numberOfLines = 0;
    self.descriptionLabel.myTopMargin = 16;
    //    self.descriptionLabel.myLeftMargin = 16;
    //    self.descriptionLabel.myRightMargin = 16;
    self.descriptionLabel.wrapContentHeight = YES;
    [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: self.descriptionLabel content: self.descriptionLabel.text];
    
    //self.creatorInfoHorzLayout.backgroundColor = [UIColor blueColor];
    self.creatorInfoHorzLayout.myTopMargin = 16;
    self.creatorInfoHorzLayout.myBottomMargin = 16;
    self.creatorInfoHorzLayout.myLeftMargin = self.creatorInfoHorzLayout.myRightMargin = 0;
    self.creatorInfoHorzLayout.myLeftMargin = 0;
    self.creatorInfoHorzLayout.padding = UIEdgeInsetsMake(0, 0, 0, 0);
    self.creatorInfoHorzLayout.wrapContentHeight = YES;
    
    self.nameImgView.image = [UIImage imageNamed: @"MeTab"];
    self.nameImgView.myLeftMargin = 0;
    self.nameImgView.myRightMargin = 5;
    self.nameImgView.myWidth = 20;
    self.nameImgView.myHeight = 20;
    
    if ([wTools objectExists: self.data[@"user"][@"name"]]) {
        self.nameLabel.text = self.data[@"user"][@"name"];
        NSLog(@"self.nameLabel.text: %@", self.nameLabel.text);
    }
    
    self.nameLabel.textColor = [UIColor secondGrey];
    self.nameLabel.font = [UIFont systemFontOfSize: 16];
    [self.nameLabel sizeToFit];
    self.nameLabel.numberOfLines = 0;
    self.nameLabel.myLeftMargin = 5;
    //    self.nameLabel.myRightMargin = 16;
    self.nameLabel.weight = 1.0;
    self.nameLabel.wrapContentHeight = YES;
    [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: self.nameLabel content: self.nameLabel.text];
    
    self.scrollView.weight = 0.7;
    // Set the four sides to 0 for display correctly when change orietnation
    self.scrollView.myTopMargin = self.scrollView.myBottomMargin = 0;
    self.scrollView.myLeftMargin = self.scrollView.myRightMargin = 0;
    
    self.scrollView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
    
    NSLog(@"self.localData: %@", self.localData);
    
    self.mapView.weight = 0.3;
    // Set the four sides to 0 for display correctly when change orietnation
    self.mapView.myTopMargin = self.mapView.myBottomMargin = 0;
    self.mapView.myLeftMargin = self.mapView.myRightMargin = 0;
    
    if (self.localData == nil) {
        NSLog(@"self.localData == nil");
        self.mapView.hidden = YES;
        self.routeButton.hidden = YES;
    } else {
        self.mapView.hidden = NO;
        self.routeButton.hidden = NO;
        if (self.localData) {
            MKMapItem *item = self.localData[@"mapitem"];
            if (item) {
                MKPlacemark *mark = item.placemark;
                CLLocationCoordinate2D result = mark.coordinate;
            
                MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(result, 3000, 3000);
                [self.mapView setRegion: [self.mapView regionThatFits: region] animated: YES];

                // Add an annotation
                MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
                point.coordinate = result;

                point.title = item.name;
                
                [self.mapView addAnnotation: point];
    
            }
        }
    }

}

- (IBAction)dimissVC:(id)sender {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromBottom;
    [self.navigationController.view.layer addAnimation: transition forKey: kCATransition];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav popViewControllerAnimated: NO];
}
- (IBAction)showRoute:(id)sender {
    
    if (self.localData) {
        
        MKMapItem *item = self.localData[@"mapitem"];
        MKMapItem *current = [MKMapItem mapItemForCurrentLocation];
        if (item && current && self.current) {
            
            NSString* url = [NSString stringWithFormat: @"http://maps.apple.com/maps?saddr=%f,%f&daddr=%f,%f",self.current.coordinate.latitude,self.current.coordinate.longitude,item.placemark.location.coordinate.latitude,item.placemark.location.coordinate.longitude];
            
            CustomIOSAlertView *alertPostView = [[CustomIOSAlertView alloc] init];
            [alertPostView setContentViewWithMsg:@"即將開啟地圖" contentBackgroundColor:[UIColor firstMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
            [alertPostView setButtonTitles: [NSMutableArray arrayWithObjects: @"取消", @"確定", nil]];
            alertPostView.arrangeStyle = @"Horizontal";
            [alertPostView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor whiteColor],[UIColor whiteColor], nil]];
            [alertPostView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstGrey], nil]];
                
            
            __weak CustomIOSAlertView *weakAlertPostView = alertPostView;
            [alertPostView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertAlbumView, int buttonIndex) {
                //NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertAlbumView tag]);
                
                [weakAlertPostView close];
                
                if (buttonIndex == 1) {
                    //  open map app
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:^(BOOL success) {
                        //  try google map if failed
                        if (!success) {
                            NSString *gs = @"comgooglemaps://?saddr=%f,%f&daddr=%f,%f";
                            NSString *u = [NSString stringWithFormat:gs, self.current.coordinate.latitude,self.current.coordinate.longitude,item.placemark.location.coordinate.latitude,item.placemark.location.coordinate.longitude];
                            NSURL *url = [NSURL URLWithString:u];
                            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                            } else {
                                NSString *gs = @"https://maps.google.com?saddr=%f,%f&daddr=%f,%f";
                                NSString *u = [NSString stringWithFormat:gs, self.current.coordinate.latitude,self.current.coordinate.longitude,item.placemark.location.coordinate.latitude,item.placemark.location.coordinate.longitude];
                                NSURL *url = [NSURL URLWithString:u];
                                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                            }
                        }
                    }];
                }
                
            }];
            [alertPostView setUseMotionEffects: YES];
            [alertPostView show];
            
            
        } else {
            [UIViewController showCustomErrorAlertWithMessage:@"請先開啟定位服務，再查詢路線。" onButtonTouchUpBlock:^(CustomIOSAlertView * _Nonnull customAlertView, int buttonIndex) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                });
                [customAlertView close];
            }];
        }
    }
}
#pragma mark CLLocationManagerDelegate functions
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (locations.count > 0) {
        CLLocation *l = [locations firstObject];
        self.current = [[CLLocation alloc] initWithLatitude:l.coordinate.latitude longitude:l.coordinate.longitude];
        //[self.locationManager stopUpdatingLocation];
        
    }
    
}
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation];
    } else {
        self.current = nil;
    }
}

@end
