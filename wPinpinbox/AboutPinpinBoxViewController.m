//
//  AboutPinpinBoxViewController.m
//  wPinpinbox
//
//  Created by David Lee on 2017/10/1.
//  Copyright © 2017年 Angus. All rights reserved.
//

#import "AboutPinpinBoxViewController.h"
#import "MyLayout.h"
#import "UIColor+Extensions.h"
#import "AppDelegate.h"

@interface AboutPinpinBoxViewController () <UIScrollViewDelegate>
{
    NSArray *imageArray;
    NSArray *topicStrArray;
    NSArray *contentStrArray;
    
    UIScrollView *mySV;
}
@property (weak, nonatomic) IBOutlet UIView *navBarView;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@end

@implementation AboutPinpinBoxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initialValueSetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initialValueSetup
{
    [self dataSourceSetup];
    [self scrollViewSetup];
    [self navBarBtnSetup];
    [self pageControlSetup];
}

- (void)dataSourceSetup
{
    // Image Source
    imageArray = [NSArray arrayWithObjects: @"bg200_guide01", @"bg200_guide02", @"bg200_guide03", nil];
    NSLog(@"imageArray.count: %lu", (unsigned long)imageArray.count);
    
    // Topic Source
    topicStrArray = [NSArray arrayWithObjects: @"多元的數位作品", @"友善的創作生態", @"小額贊助機制", nil];
    
    // Content Source
    NSString *contentStr1 = @"提供多媒體整合，上傳格式多元，讓你輕鬆打造影片集、音樂專輯、有聲圖書、雜誌型錄等數位作品";
    NSString *contentStr2 = @"透過小額贊助支持創作人的原創作品，同樣也為瀏覽人匯集優質內容";
    NSString *contentStr3 = @"創作人每發表一件作品，粉絲即可對作品本身支付小額贊助，使內容價值兌現";
    
    contentStrArray = [NSArray arrayWithObjects: contentStr1, contentStr2, contentStr3, nil];
}

- (void)scrollViewSetup
{
    NSLog(@"scrollViewSetup");
    
    // UIScrollView Setting
    mySV = [[UIScrollView alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    mySV.delegate = self;
    mySV.showsHorizontalScrollIndicator = NO;
    mySV.contentSize = CGSizeMake(self.view.frame.size.width * imageArray.count, self.view.frame.size.height);
    [self.view addSubview: mySV];
    
    mySV.pagingEnabled = YES;
    mySV.alwaysBounceHorizontal = YES;
    mySV.contentSize = CGSizeMake(self.view.frame.size.width * imageArray.count, self.view.frame.size.height - 64);
    
    // Adding data on ScrollView
    for (int i = 0; i < imageArray.count; i++) {
        CGFloat x = i * self.view.bounds.size.width;
        NSLog(@"x: %f", x);
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(x, 0, mySV.bounds.size.width, mySV.bounds.size.height)];
        NSString *imageStr = imageArray[i];
        imageView.image = [UIImage imageNamed: imageStr];
        
        // ContentMode set to UIViewContentModeScaleAspectFit will stop image move
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        NSLog(@"imageView.frame: %@", NSStringFromCGRect(imageView.frame));
        
        MyLinearLayout *vertLayout = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Vert];
        vertLayout.myLeftMargin = 0;
        vertLayout.myRightMargin = 0;
        vertLayout.myBottomMargin = 100;
        vertLayout.wrapContentHeight = YES;
        vertLayout.wrapContentWidth = YES;
        
        UILabel *topicLabel = [UILabel new];
        topicLabel.wrapContentHeight = YES;
        topicLabel.myTopMargin = 4;
        topicLabel.myBottomMargin = 4;
        topicLabel.myRightMargin = 20;
        topicLabel.font = [UIFont boldSystemFontOfSize: 20];
        topicLabel.text = topicStrArray[i];
        topicLabel.textColor = [UIColor firstGrey];
        topicLabel.numberOfLines = 1;
        [topicLabel sizeToFit];
        [vertLayout addSubview: topicLabel];
        
        UILabel *contentLabel = [UILabel new];
        contentLabel.wrapContentWidth = YES;
        contentLabel.wrapContentHeight = YES;
        contentLabel.myTopMargin = 4;
        contentLabel.myLeftMargin = 70;
        contentLabel.myRightMargin = 16;
        contentLabel.myBottomMargin = 0;
        contentLabel.font = [UIFont systemFontOfSize: 16];
        contentLabel.text = contentStrArray[i];
        contentLabel.textColor = [UIColor firstGrey];
        contentLabel.numberOfLines = 0;
        [contentLabel sizeToFit];
        [vertLayout addSubview: contentLabel];
        
        [imageView addSubview: vertLayout];
        [mySV addSubview: imageView];
        
        //[scrollView addSubview: vertLayout];
    }
}

- (void)navBarBtnSetup {
    self.navBarView.backgroundColor = [UIColor clearColor];
    
    UIImage *img = [UIImage imageNamed: @"ic200_arrow_left_light"];
    CGRect rect = CGRectMake(0, 0, 15, 15);
    UIGraphicsBeginImageContext(rect.size);
    [img drawInRect: rect];
    UIImage *navBtnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.backBtn setImage: navBtnImage forState: UIControlStateNormal];
    [self.backBtn setTitleEdgeInsets: UIEdgeInsetsMake(0.0, 15, 0, 0)];
    
    [self.view bringSubviewToFront: self.navBarView];
}

- (void)pageControlSetup
{
    self.pageControl.numberOfPages = imageArray.count;
    self.pageControl.currentPage = 0;
    self.pageControl.pageIndicatorTintColor = [UIColor secondGrey];
    self.pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    self.pageControl.userInteractionEnabled = NO;
}

- (IBAction)backBtnPress:(id)sender {
    //[self.navigationController popViewControllerAnimated: YES];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav popViewControllerAnimated: YES];
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewDidScroll");
    self.pageControl.currentPage = scrollView.contentOffset.x / scrollView.frame.size.width;
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
