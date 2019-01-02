//
//  EditNewAlbumViewController.m
//  PinpinboxShareExtension
//
//  Created by Antelis on 2018/12/28.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "EditNewAlbumViewController.h"

@interface EditNewAlbumViewController ()

@end

@implementation EditNewAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)cancelAndDismiss:(id)sender {
    //[self.navigationController pop ]
    [self.navigationController popViewControllerAnimated:YES];
}

@end
