//
//  NewReadBookViewController.m
//  wPinpinbox
//
//  Created by David on 6/25/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "NewReadBookViewController.h"
#import "MBProgressHUD.h"
#import "boxAPI.h"
#import "wTools.h"

@interface NewReadBookViewController ()
@property (nonatomic, strong) NSMutableDictionary *data;

@property (weak, nonatomic) IBOutlet UIView *navBarView;

@end

@implementation NewReadBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isPresented = YES;
    self.isAddingSubView = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //[self retrieveAlbum];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.isPresented = NO;
}

- (void)retrieveAlbum
{
    [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *response = [boxAPI retrievealbump: self.albumId uid: [wTools getUserID] token: [wTools getUserToken]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView: self.view animated: YES];
            
            if (response != nil) {
                NSLog(@"response from retrievealbump: %@", response);
                
                NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                
                if ([dic[@"result"] boolValue]) {
                    NSLog(@"result bool value is YES");
                    NSLog(@"dic: %@", dic);
                    
                    
                }
            }
        });
    });
}

- (IBAction)back:(id)sender {
    NSLog(@"NewReadBookViewController");
    NSLog(@"back");
    
    [self.navigationController popViewControllerAnimated: YES];
}

/*
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    NSLog(@"supportedInterfaceOrientations");
    return UIInterfaceOrientationMaskPortrait;
}
*/
 
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
