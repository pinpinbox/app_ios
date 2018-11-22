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

@end
