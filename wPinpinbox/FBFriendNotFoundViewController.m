//
//  FBFriendNotFoundViewController.m
//  wPinpinbox
//
//  Created by David on 4/19/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "FBFriendNotFoundViewController.h"
#import "UIColor+Extensions.h"
#import "ChooseHobbyViewController.h"
#import "AppDelegate.h"

@interface FBFriendNotFoundViewController ()
@property (weak, nonatomic) IBOutlet UIView *messageContainerView;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@end

@implementation FBFriendNotFoundViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self gradientViewSetup];
    [self viewSetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)gradientViewSetup
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = @[(id)[UIColor FBGradientViewColor].CGColor, (id)[UIColor whiteColor].CGColor];
    
    [self.view.layer insertSublayer: gradient atIndex: 0];
    self.view.alpha = 0.9;
}

- (void)viewSetup
{
    self.messageContainerView.layer.cornerRadius = 16;
    self.nextBtn.layer.cornerRadius = 16;
}

- (IBAction)nextBtnPress:(id)sender {
    ChooseHobbyViewController *chooseHobbyVC = [[UIStoryboard storyboardWithName: @"ChooseHobbyVC" bundle: nil] instantiateViewControllerWithIdentifier: @"ChooseHobbyViewController"];
    //[self.navigationController pushViewController: chooseHobbyVC animated: YES];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav pushViewController: chooseHobbyVC animated: YES];
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
