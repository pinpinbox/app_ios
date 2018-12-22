//
//  PhotoDescriptionAddViewController.m
//  wPinpinbox
//
//  Created by Antelis on 2018/11/22.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "PhotoDescriptionAddViewController.h"


@interface PhotoDescriptionAddViewController ()
@property(nonatomic) IBOutlet UITextView *itemDesc;
@property(nonatomic) DescSubmitBlock submitBlock;
@end

@implementation PhotoDescriptionAddViewController

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
    [self addDismissTap];
    [self addKeyboardNotification];
}

- (void)addDesc:(NSString *)desc submitBlock:(DescSubmitBlock)submitBlock {
    self.itemDesc.text = desc;
    self.submitBlock = submitBlock;
}
- (IBAction)submitDesc:(id)sender {
    
    __block NSString *desc = self.itemDesc.text;
    __block typeof(self) wself = self;
    [self dismissViewControllerAnimated:YES completion:^{
        if (wself.submitBlock) {
            wself.submitBlock(desc);
        }
    }];
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}
- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey: UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    self.view.transform = CGAffineTransformMakeTranslation(0, -kbSize.height);
    
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    self.view.transform = CGAffineTransformIdentity;
}

@end
