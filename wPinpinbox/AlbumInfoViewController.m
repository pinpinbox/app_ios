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
#import <MapKit/MapKit.h>
#import "AppDelegate.h"
#import "GlobalVars.h"

#import "MapHelper.h"

@interface AlbumInfoViewController () {
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
    } else {
        self.mapView.hidden = NO;
        
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
    //self.mapView.myTopMargin = 8;
    //self.mapView.myLeftMargin = self.mapView.myRightMargin = 0;
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


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
