//
//  ActivityDetailViewController.m
//  wPinpinbox
//
//  Created by David on 2017/11/23.
//  Copyright © 2017年 Angus. All rights reserved.
//

#import "ActivityDetailViewController.h"
#import "MyLayout.h"
#import "GlobalVars.h"
#import "LabelAttributeStyle.h"

//#import "ZoomTransitionProtocol.h"

@interface ActivityDetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *topicLabel;
@property (weak, nonatomic) IBOutlet UIButton *dimissBtn;
@end

@implementation ActivityDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent: 0.8];
    //self.imageView.wrapContentHeight = YES;
    [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: self.topicLabel content: self.topicLabel.text];
    [LabelAttributeStyle changeGapStringAndLineSpacingCenterAlignment: self.dimissBtn.titleLabel content: self.dimissBtn.titleLabel.text];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [UIView animateWithDuration: kAnimateActionSheet animations:^{
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle: UIBlurEffectStyleLight];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect: blurEffect];
        blurEffectView.frame = self.view.bounds;
        [self.view addSubview: blurEffectView];
    }];
    
    [self.view bringSubviewToFront: self.topicLabel];
    [self.view bringSubviewToFront: self.imageView];
    [self.view bringSubviewToFront: self.dimissBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dimissBtnPressed:(id)sender {
    NSLog(@"dimissBtnPressed");
    [self dismissViewControllerAnimated: YES completion: nil];
}

#pragma mark - <RMPZoomTransitionAnimating>
- (UIImageView *)transitionSourceImageView {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.imageView.image];
    imageView.contentMode = self.imageView.contentMode;
    imageView.clipsToBounds = YES;
    imageView.userInteractionEnabled = NO;
    imageView.frame = self.imageView.frame;
    return imageView;
}

- (UIColor *)transitionSourceBackgroundColor {
    return self.view.backgroundColor;
}

- (CGRect)transitionDestinationImageViewFrame {
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGRect frame = self.imageView.frame;
    frame.size.width = width;
    return frame;
}

#pragma mark - <RMPZoomTransitionDelegate>
- (void)zoomTransitionAnimator:(RMPZoomTransitionAnimator *)animator
         didCompleteTransition:(BOOL)didComplete
      animatingSourceImageView:(UIImageView *)imageView
{
    self.imageView.image = imageView.image;
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
