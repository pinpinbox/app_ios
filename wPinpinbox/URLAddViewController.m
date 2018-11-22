//
//  URLAddViewController.m
//  wPinpinbox
//
//  Created by Antelis on 2018/11/19.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "URLAddViewController.h"

#import "UIView+Toast.h"
#import "UIColor+Extensions.h"

@interface URLAddViewController ()<UITextFieldDelegate>
@property (nonatomic) IBOutlet UITextField *desc1;
@property (nonatomic) IBOutlet UITextField *url1;
@property (nonatomic) IBOutlet UITextField *desc2;
@property (nonatomic) IBOutlet UITextField *url2;


@end

@implementation URLAddViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.url1.delegate = self;
    self.url2.delegate = self;
    self.desc1.delegate = self;
    self.desc2.delegate = self;
    
}
- (void)loadURLs:(NSArray *)urls {
    
    NSDictionary *d1 = [urls firstObject];
    if(d1) {
        self.url1.text = d1[@"url"]? d1[@"url"] :@"";
        self.desc1.text = d1[@"text"]? d1[@"text"]: @"";
    }
    
    if (urls.count > 1) {
        NSDictionary *d2 = [urls objectAtIndex:1];
        if (d2) {
            self.url2.text = d2[@"url"]? d2[@"url"] :@"";
            self.desc2.text = d2[@"text"]? d2[@"text"]: @"";
        }
    }
    
}
- (IBAction)submitURLs:(id)sender {
    __block NSArray *urls = [self getURLArray];
    if (self.urlDelegate && urls && urls.count > 0) {
        __block typeof(self) wself = self;
        [self removeKeyboardNotification];
        [self dismissViewControllerAnimated:YES completion:^{
           [wself.urlDelegate didSetURLs:urls];
        }];
        
    } else if (!urls || urls.count < 1){
        [self showErrorToastWithMessage:@"請至少填上一組連結"];
    } else {
        [self cancelAndDismiss:nil];
    }
    
}
- (void)showErrorToastWithMessage:(NSString *)message {
    CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
    style.messageColor = [UIColor whiteColor];
    style.backgroundColor = [UIColor thirdPink];
    
    [self.view makeToast: message
                 duration: 2.0
                 position: CSToastPositionBottom
                    style: style];
}
- (NSDictionary *)getURLParam:(NSString *)u desc:(NSString *)desc {
    if (u.length > 1) {
        NSString *uu = [u lowercaseString];
        
        if (![uu hasPrefix:@"https"] || ![uu hasPrefix:@"http"]) {
            u = [NSString stringWithFormat:@"https://%@",u];
        }
        u = [u stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        if (desc && desc.length > 0) {
            return @{@"url":u, @"text":desc};
        } else {
            return @{@"url":u};
        }
    }
    return nil;
}
- (NSArray *)getURLArray {
    NSString *u1 = self.url1.text;
    
    NSString *u2 = self.url2.text;
    NSString *d1 = self.desc1.text;
    NSString *d2 = self.desc2.text;
    NSMutableArray *ar = [NSMutableArray array];
    if (u1 || u2) {
        NSDictionary *de1 = [self getURLParam:u1 desc:d1];
        if (de1)
            [ar addObject:de1];
        NSDictionary *de2 = [self getURLParam:u2 desc:d2];
        if (de2)
            [ar addObject:de2];
        
        return ar;
    }
    return nil;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
    
}
@end
