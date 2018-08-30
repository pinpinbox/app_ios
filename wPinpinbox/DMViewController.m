//
//  DMViewController.m
//  wPinpinbox
//
//  Created by David on 2018/8/29.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "DMViewController.h"
#import "DMPlayerViewController.h"
#import "MBProgressHUD.h"
#import "UIColor+Extensions.h"
#import "GlobalVars.h"

@interface DMViewController () <DMPlayerDelegate> {
    MBProgressHUD *hud;
}
@property (weak, nonatomic) IBOutlet UIView *navBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarHeight;
@end

@implementation DMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navBarView.backgroundColor = [UIColor clearColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
 
    hud = [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    hud.label.text = [NSString stringWithFormat: @"載入影片中"];
    hud.label.font = [UIFont systemFontOfSize: 18.0];
    [hud.button setTitle: @"取消" forState: UIControlStateNormal];
    [hud.button addTarget: self action: @selector(cancelWork:) forControlEvents: UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancelWork:(UIButton *)btn {
    [self backBtnPressed: nil];
}

- (IBAction)backBtnPressed:(id)sender {
    [self.navigationController popViewControllerAnimated: YES];
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString: @"EmbedPlayerSegue"]) {
        DMPlayerViewController *playerViewController = segue.destinationViewController;
        
        // Set its delegate and other parameters (if any)
        playerViewController.delegate = self;
        playerViewController.autoOpenExternalURLs = true;
        
        // Load the video using its ID and some parameters (if any)
        playerViewController.webBaseURLString = self.baseURL;
        [playerViewController loadVideo: self.videoID withParams: self.additionalParameters];
        
        [self.view setNeedsUpdateConstraints];
    }
}

#pragma mark DMPlayerDelegate
- (void)dailymotionPlayer:(DMPlayerViewController *)player
          didReceiveEvent:(NSString *)eventName {
    NSLog(@"didReceiveEvent");
    
    [hud hideAnimated: YES];
    
    // Grab the "apiready" event to trigger an autoplay
    if ([eventName isEqualToString: @"apiready"]) {
        // From here, it's possible to interact with the player API.
        NSLog(@"Received apiready event");                
    }
}

@end
