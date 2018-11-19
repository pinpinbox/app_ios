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
    self.url1.delegate = self;
    self.url2.delegate = self;
    self.desc1.delegate = self;
    self.desc2.delegate = self;
    [self addDismissTap];
    [self addKeyboardNotification];
}
- (BOOL)prefersStatusBarHidden {
    return YES;
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
- (IBAction)cancelAndDismiss:(id)sender {
    [self removeKeyboardNotification];
    [self dismissViewControllerAnimated:YES completion:nil];
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
- (void)addDismissTap {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDismissTap:)];
    
    [self.view addGestureRecognizer:tap];
}
- (void)handleDismissTap:(UITapGestureRecognizer *)tap {
    
    CGPoint p = [tap locationInView:self.view];
    CGSize s = UIScreen.mainScreen.bounds.size;
    if (p.y > 0 && p.y < s.height - 325) {
        [self cancelAndDismiss:nil];
    }
    
}
#pragma mark -
- (void)addKeyboardNotification {
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
    return YES;
    
}

#pragma mark -
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
