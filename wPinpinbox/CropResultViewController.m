//
//  CropResultViewController.m
//  TKImageViewDemo
//
//  Created by yinyu on 08/01/2017.
//  Copyright © 2017 yinyu. All rights reserved.
//

#import "CropResultViewController.h"

@interface CropResultViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *cropResultImageView;

@end

@implementation CropResultViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.cropResultImageView.image = _cropResultImage;
    NSLog(@"self.cropResultImageView.image: %@", self.cropResultImageView.image);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)cancelBtnPressed:(id)sender {
    [self.navigationController popViewControllerAnimated: YES];
}

@end
