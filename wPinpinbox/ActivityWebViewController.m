//
//  ActivityWebViewController.m
//  wPinpinbox
//
//  Created by David on 07/12/2017.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "ActivityWebViewController.h"
#import "AppDelegate.h"
#import "UIColor+Extensions.h"
#import <WebKit/WebKit.h>
#import "CreaterViewController.h"
#import "LabelAttributeStyle.h"
#import "MyLayout.h"
#import "GlobalVars.h"

@interface ActivityWebViewController () <WKNavigationDelegate>
{
    NSInteger offset;
    NSInteger webViewHeight;
}
@property (strong, nonatomic) WKWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *navBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarHeight;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@end

@implementation ActivityWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initialValueSetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initialValueSetup {
    self.navBarView.backgroundColor = [UIColor barColor];
    self.titleLabel.textColor = [UIColor firstGrey];
    
    [LabelAttributeStyle changeGapString: self.titleLabel content: self.titleLabel.text];
    
    self.webView = [[WKWebView alloc] init];
    self.webView.navigationDelegate = self;
    
    [self.webView evaluateJavaScript: @"navigator.userAgent" completionHandler:^(id _Nullable userAgent, NSError * _Nullable error) {
        NSLog(@"\n\nself.webView evaluateJavaScript");
        NSLog(@"\n\nuserAgent: %@", userAgent);
        
        NSString *customUserAgent;
        
        if (![userAgent containsString: @"com.vmage.pinpinbox"]) {
            customUserAgent = [NSString stringWithFormat: @"%@ %@", userAgent, @"com.vmage.pinpinbox"];
            NSLog(@"\n\ncustomUserAgent: %@", customUserAgent);
        }
        //[[NSUserDefaults standardUserDefaults] registerDefaults: @{@"UserAgent": customUserAgent}];
        
        self.webView.customUserAgent = customUserAgent;
        NSURL *url = [NSURL URLWithString: self.eventURL];
        NSURLRequest *request = [NSURLRequest requestWithURL: url];
        [self.webView loadRequest: request];
        CGRect frame = self.view.frame;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            NSLog(@"UIUserInterfaceIdiomPhone");
            NSLog(@"size height: %f", [[UIScreen mainScreen] nativeBounds].size.height);
            
            switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
                case 1136:
                    printf("iPhone 5 or 5S or 5C");
                    offset = 60;
                    webViewHeight = frame.size.height - 60;
                    break;
                case 1334:
                    printf("iPhone 6/6S/7/8");
                    offset = 60;
                    webViewHeight = frame.size.height - 60;
                    break;
                case 1920:
                    printf("iPhone 6+/6S+/7+/8+");
                    offset = 60;
                    webViewHeight = frame.size.height - 60;
                    break;
                case 2208:
                    printf("iPhone 6+/6S+/7+/8+");
                    offset = 60;
                    webViewHeight = frame.size.height - 60;
                    break;
                case 2436:
                    printf("iPhone X");
                    self.navBarHeight.constant = navBarHeightConstant;
                    offset = 78;
                    webViewHeight = frame.size.height - 110;
                    break;
                default:
                    printf("unknown");
                    offset = 60;
                    webViewHeight = frame.size.height - 60;
                    break;
            }
        }
        
//        self.webView.frame = CGRectMake(frame.origin.x, frame.origin.y + offset, frame.size.width, frame.size.height);
        self.webView.frame = CGRectMake(frame.origin.x, frame.origin.y + offset, frame.size.width, webViewHeight);
        [self.view addSubview: self.webView];
        [self.view bringSubviewToFront: self.navBarView];
        [self.view bringSubviewToFront: self.toolBar];
    }];
}

- (void)viewDidLayoutSubviews {
    NSLog(@"viewDidLayoutSubviews");
    
}

- (IBAction)backBtnPressed:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.myNav popViewControllerAnimated: YES];
}

- (void)webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSLog(@"navigationAction.request.URL: %@", navigationAction.request.URL);
    NSURL *url = navigationAction.request.URL;
    
    NSLog(@"URL received: %@", url);
    NSLog(@"URL scheme: %@", [url scheme]);
    NSLog(@"URL query: %@", [url query]);
    NSLog(@"URL host: %@", [url host]);
    NSLog(@"URL path: %@", [url path]);
    
    if ([url.scheme isEqualToString: @"pinpinbox"]) {
        if (url.query != nil) {
            NSString *query = url.query;
            NSArray *bits = [query componentsSeparatedByString: @"="];
            NSLog(@"bits: %@", bits);
            
            NSString *key = bits[0];
            NSString *value = bits[1];
            NSLog(@"key: %@", key);
            NSLog(@"value: %@", value);
            
            if ([key isEqualToString: @"user_id"]) {
                CreaterViewController *cVC = [[UIStoryboard storyboardWithName: @"CreaterVC" bundle: nil] instantiateViewControllerWithIdentifier: @"CreaterViewController"];
                cVC.userId = value;
                cVC.fromActivityWebVC = YES;
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [appDelegate.myNav pushViewController: cVC animated: YES];
            }
        }
    }
    
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (IBAction)backBarButton:(id)sender {
    [self.webView goBack];
}

- (IBAction)forwardBarButton:(id)sender {
    [self.webView goForward];
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

