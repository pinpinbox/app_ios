//
//  YoutubePlayerViewController.m
//  wPinpinbox
//
//  Created by David on 2018/8/24.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "YoutubePlayerViewController.h"
#import "GlobalVars.h"
#import "MBProgressHUD.h"
//#import "wTools.h"

@interface YoutubePlayerViewController () {
    MBProgressHUD *hud;
}
@property (weak, nonatomic) IBOutlet UIView *navBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarHeight;
@end

@implementation YoutubePlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"viewDidLoad");
    NSLog(@"YoutubePlayerViewController");
    
    hud = [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    hud.label.text = [NSString stringWithFormat: @"載入影片中"];
    hud.label.font = [UIFont systemFontOfSize: 18.0];
    [hud.button setTitle: @"取消" forState: UIControlStateNormal];
    [hud.button addTarget: self action: @selector(cancelWork:) forControlEvents: UIControlEventTouchUpInside];
    
    self.navBarView.backgroundColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"YoutubePlayerViewController viewWillAppear");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSDictionary *playerVars = @{
                                 @"playsinline" : @1,
                                 @"showinfo" : @1,
                                 };
    NSString *videoID = [self extractYoutubeIdFromLink: self.videoUrlString];
    [self.playerView loadWithVideoId: videoID
                          playerVars: playerVars];
    self.playerView.delegate = self;
    self.playerView.alpha = 0;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSLog(@"YoutubePlayerViewController viewDidDisappear");
    if ([self.delegate respondsToSelector: @selector(youtubePlayerViewControllerDidDisappeared:currentPage:)]) {
        [self.delegate youtubePlayerViewControllerDidDisappeared: self currentPage: self.currentPage];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    NSLog(@"viewWillLayoutSubviews");
}

- (void)viewDidLayoutSubviews {
    NSLog(@"viewDidLayoutSubviews");
    NSLog(@"YoutubePlayerViewController");

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
                self.navBarHeight.constant = navBarHeightConstant;
                break;
            default:
                printf("unknown");
                break;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancelWork:(UIButton *)btn {
    [self backBtnPressed: nil];
}

- (void)playerViewDidBecomeReady:(YTPlayerView *)playerView {
    NSLog(@"playerViewDidBecomeReady");
    [hud hideAnimated: YES];
    self.playerView.alpha = 1;
    [self.playerView playVideo];
}

- (IBAction)backBtnPressed:(id)sender {
    NSLog(@"backBtnPressed");
    NSLog(@"YoutubePlayerViewController");
    [self dismissViewControllerAnimated: YES completion: nil];
//    [self.navigationController popViewControllerAnimated: YES];
}

- (NSString *)extractYoutubeIdFromLink:(NSString *)link {
    NSString *regexString = @"((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)";
    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:regexString
                                                                            options:NSRegularExpressionCaseInsensitive
                                                                              error:nil];
    
    NSArray *array = [regExp matchesInString:link options:0 range:NSMakeRange(0,link.length)];
    if (array.count > 0) {
        NSTextCheckingResult *result = array.firstObject;
        return [link substringWithRange:result.range];
    }
    return nil;
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
