//
//  DDAUIActionSheetViewController.m
//  CustomActionSheetTest
//
//  Created by David on 7/31/17.
//  Copyright © 2017 vmage. All rights reserved.
//

#import "DDAUIActionSheetViewController.h"
#import "MyLayout.h"
#import "UIColor+Extensions.h"
#import "GlobalVars.h"
//#import "LabelAttributeStyle.h"

@interface DDAUIActionSheetViewController ()
{
    BOOL isTouchDown;        
}
@property (weak, nonatomic) IBOutlet UIView *blackView;
//@property (nonatomic) UIVisualEffectView *effectView;
@property (weak, nonatomic) IBOutlet UIView *actionSheetView;
@property (weak, nonatomic) IBOutlet UILabel *topicLabel;
@property (weak, nonatomic) IBOutlet MyLinearLayout *contentLayout;

@end

@implementation DDAUIActionSheetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"");
    NSLog(@"DDAUIActionSheetViewController");
    NSLog(@"viewWillAppear");
    
    NSLog(@"Before slideIn");
    NSLog(@"self.actionSheetView: %@", self.actionSheetView);
    
    /*
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(handleTapFromView:)];
    [self.view addGestureRecognizer: tapGestureRecognizer];
    tapGestureRecognizer.delegate = self;
    */
    
    [self slideIn];
    
    NSLog(@"After slideIn");
    NSLog(@"self.actionSheetView: %@", self.actionSheetView);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)addSelectButtons:(NSArray *)btnStrs
          identifierStrs:(NSArray *)identifierStrs {
    if (btnStrs.count < 1) return ;
    
    MyLinearLayout *horzLayout = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Horz];
    
    horzLayout.myLeftMargin = horzLayout.myRightMargin = 0;
    horzLayout.myTopMargin = horzLayout.myBottomMargin = 0;
    
    if (@available(iOS 11.0, *)) {
        CGFloat bt = self.view.safeAreaInsets.bottom;
        horzLayout.myHeight = 48 + bt;
    } else {
        // Fallback on earlier versions
        horzLayout.myHeight = 48;
    }
    CGFloat ww = [UIApplication sharedApplication].keyWindow.frame.size.width / btnStrs.count;
    //NSInteger n = btnStrs.count;
    
    for (int i = 0 ; i < btnStrs.count; i++) {
        NSString *s = [btnStrs objectAtIndex:i];
        NSString *is = [identifierStrs objectAtIndex:i];
        
        UIButton *btn = [UIButton buttonWithType: UIButtonTypeCustom];
        btn.myTopMargin = 4;
        btn.wrapContentWidth = YES;
        btn.myLeftMargin = btn.myRightMargin = 8;
//        btn.myCenterYOffset = 0;
        btn.widthDime.min(ww - 16);
        btn.heightDime.min(48);
        btn.layer.cornerRadius = kCornerRadius;
        btn.layer.borderColor = [UIColor firstGrey].CGColor;
        btn.layer.borderWidth = 1.0;
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 4);
        btn.backgroundColor = [UIColor clearColor];
        
        [btn setTitle: s forState: UIControlStateNormal];
        [btn setTitleColor: [UIColor firstGrey] forState: UIControlStateNormal];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize: 18.0];
        [btn sizeToFit];
        btn.accessibilityIdentifier = is;
        btn.tag = i + 1;
        
        [btn addTarget: self action: @selector(buttonHighlight:) forControlEvents: UIControlEventTouchDown];
        [btn addTarget: self action: @selector(buttonNormal:) forControlEvents: UIControlEventTouchUpInside];
        [btn addTarget: self action: @selector(buttonTouchUpOutside:) forControlEvents: UIControlEventTouchUpOutside];
        
        [horzLayout addSubview: btn];
    }
    [self.contentLayout addSubview: horzLayout];
}

- (void)addSelectItem:(NSString *)imgName
                title:(NSString *)title
               btnStr:(NSString *)btnStr
               tagInt:(NSInteger)tagInt
        identifierStr:(NSString *)identifierStr
{
    MyLinearLayout *horzLayout = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Horz];        
    
    horzLayout.myLeftMargin = horzLayout.myRightMargin = 0;
    horzLayout.myTopMargin = horzLayout.myBottomMargin = 0;
    horzLayout.myHeight = 48;
    horzLayout.tag = tagInt;
    horzLayout.accessibilityIdentifier = identifierStr;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(handleTapFromView:)];
    singleTap.numberOfTapsRequired = 1;
    //singleTap.delaysTouchesEnded = YES;
    //singleTap.cancelsTouchesInView = YES;
    [horzLayout addGestureRecognizer: singleTap];
    
    NSLog(@"imgName: %@", imgName);
    NSLog(@"title: %@", title);
    NSLog(@"btnStr: %@", btnStr);
    NSLog(@"tagInt: %ld", (long)tagInt);
    
    if (imgName != nil) {
        NSLog(@"imgName != nil");
        NSLog(@"imgName isEqualToString: %@", imgName);
        
        if (![imgName isEqualToString: @""]) {
            UIImageView *imgView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 20, 20)];
            imgView.image = [UIImage imageNamed: imgName];
            imgView.myLeftMargin = 16;
            imgView.myRightMargin = 8;
            imgView.myCenterYOffset = 0;
            [horzLayout addSubview: imgView];
        }
    } else if (imgName == nil) {
        NSLog(@"imgName == nil");
    }
    
    if (title != nil) {
        NSLog(@"title != nil");
        NSLog(@"title: %@", title);
        
        if (![title isEqualToString: @""]) {
            UILabel *label = [UILabel new];
            
            if ([imgName isEqualToString: @""]) {
                label.myLeftMargin = 16;
            } else {
                label.myLeftMargin = 8;
            }
            
            label.text = title;
            //[LabelAttributeStyle changeGapString: label content: title];
            label.textColor = [UIColor blackColor];
            label.font = [UIFont boldSystemFontOfSize: 18];
            [label sizeToFit];
            label.myCenterYOffset = 0;
            
            [horzLayout addSubview: label];
        }
    } else if (title == nil) {
        NSLog(@"title == nil");
    }
    
    if (btnStr != nil) {
        if (![btnStr isEqualToString: @""]) {
            UIButton *btn = [UIButton buttonWithType: UIButtonTypeCustom];
            btn.wrapContentWidth = YES;
            btn.myLeftMargin = 8;
            btn.myRightMargin = 16;
            btn.myCenterYOffset = 0;
            btn.widthDime.min(112);
            btn.layer.cornerRadius = 8;
            btn.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 4);
            btn.backgroundColor = [UIColor firstMain];
            
            [btn addTarget: self action: @selector(buttonHighlight:) forControlEvents: UIControlEventTouchDown];
            [btn addTarget: self action: @selector(buttonNormal:) forControlEvents: UIControlEventTouchUpInside];
            [btn addTarget: self action: @selector(buttonNormal:) forControlEvents: UIControlEventTouchUpOutside];
            [btn setTitle: btnStr forState: UIControlStateNormal];
            [btn setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
            [btn sizeToFit];
            
            [horzLayout addSubview: btn];
        }
    }
    
    [self.contentLayout addSubview: horzLayout];
}

// Method below only applies to collectView
// If there are any changes below, the method above should also be changed as well.
- (void)addSelectItem:(NSString *)imgName
                title:(NSString *)title
               btnStr:(NSString *)btnStr
               tagInt:(NSInteger)tagInt
        identifierStr:(NSString *)identifierStr
          isCollected:(BOOL)isCollected;
{
    MyLinearLayout *horzLayout = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Horz];
    
    horzLayout.myLeftMargin = horzLayout.myRightMargin = 0;
    horzLayout.myTopMargin = horzLayout.myBottomMargin = 0;
    horzLayout.myHeight = 48;
    horzLayout.tag = tagInt;
    horzLayout.accessibilityIdentifier = identifierStr;
    
    if (isCollected) {
        horzLayout.userInteractionEnabled = NO;
    } else {
        horzLayout.userInteractionEnabled = YES;
    }
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(handleTapFromView:)];
    singleTap.numberOfTapsRequired = 1;
    //singleTap.delaysTouchesEnded = YES;
    //singleTap.cancelsTouchesInView = YES;
    [horzLayout addGestureRecognizer: singleTap];
    
    NSLog(@"imgName: %@", imgName);
    NSLog(@"title: %@", title);
    NSLog(@"btnStr: %@", btnStr);
    NSLog(@"tagInt: %ld", (long)tagInt);
    
    if (imgName != nil) {
        NSLog(@"imgName != nil");
        NSLog(@"imgName isEqualToString: %@", imgName);
        
        if (![imgName isEqualToString: @""]) {
            UIImageView *imgView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 20, 20)];
            imgView.image = [UIImage imageNamed: imgName];
            imgView.myLeftMargin = 16;
            imgView.myRightMargin = 8;
            imgView.myCenterYOffset = 0;
            [horzLayout addSubview: imgView];
        }
    } else if (imgName == nil) {
        NSLog(@"imgName == nil");
    }
    
    if (title != nil) {
        NSLog(@"title != nil");
        NSLog(@"title: %@", title);
        
        if (![title isEqualToString: @""]) {
            UILabel *label = [UILabel new];
            
            if ([imgName isEqualToString: @""]) {
                label.myLeftMargin = 16;
            } else {
                label.myLeftMargin = 8;
            }
            
            label.text = title;
            //[LabelAttributeStyle changeGapString: label content: title];
            
            if (isCollected) {
                label.textColor = [UIColor lightGrayColor];
            } else {
                label.textColor = [UIColor blackColor];
            }
            
            label.font = [UIFont boldSystemFontOfSize: 18];
            [label sizeToFit];
            label.myCenterYOffset = 0;
            
            [horzLayout addSubview: label];
        }
    } else if (title == nil) {
        NSLog(@"title == nil");
    }
    
    if (btnStr != nil) {
        if (![btnStr isEqualToString: @""]) {
            if (!isCollected) {
                UIButton *btn = [UIButton buttonWithType: UIButtonTypeCustom];
                btn.wrapContentWidth = YES;
                btn.myLeftMargin = 8;
                btn.myRightMargin = 16;
                btn.myCenterYOffset = 0;
                btn.widthDime.min(100);
                btn.layer.cornerRadius = 8;
                btn.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 4);
                btn.backgroundColor = [UIColor firstMain];
                
                [btn addTarget: self action: @selector(buttonHighlight:) forControlEvents: UIControlEventTouchDown];
                [btn addTarget: self action: @selector(buttonNormal:) forControlEvents: UIControlEventTouchUpInside];
                [btn addTarget: self action: @selector(buttonNormal:) forControlEvents: UIControlEventTouchUpOutside];
                [btn setTitle: btnStr forState: UIControlStateNormal];
                [btn setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
                [btn sizeToFit];
                
                [horzLayout addSubview: btn];
            }                        
        }
    }
    
    [self.contentLayout addSubview: horzLayout];
}

- (void)addHorizontalLine {
    UIView *horizontalLineView = [UIView new];
    horizontalLineView.backgroundColor = [UIColor thirdGrey];
    horizontalLineView.myHeight = 1;
    horizontalLineView.myLeftMargin = horizontalLineView.myRightMargin = 0;
    horizontalLineView.myTopMargin = horizontalLineView.myBottomMargin = 10;
    [self.contentLayout addSubview: horizontalLineView];
}

#pragma mark - Custom ActionSheet Methods
- (void)slideIn {
    NSLog(@"");
    NSLog(@"sldeIn");
    
    NSLog(@"Before setting self.view.frame");
    NSLog(@"self.view.frame: %@", NSStringFromCGRect(self.view.frame));
    NSLog(@"[[UIScreen mainScreen] bounds]: %@", NSStringFromCGRect([[UIScreen mainScreen] bounds]));
    
    self.view.frame = [[UIScreen mainScreen] bounds];
    
    NSLog(@"");
    NSLog(@"After setting self.view.frame");
    NSLog(@"self.view.frame: %@", NSStringFromCGRect(self.view.frame));
    
    NSLog(@"Before setting bounds");
    NSLog(@"self.actionSheetView: %@", self.actionSheetView);
    
    //[self.actionSheetView setBounds: CGRectMake(0, [[UIScreen mainScreen] bounds].origin.y, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    
    NSLog(@"");
    NSLog(@"Before changing actionSheetView");
    NSLog(@"self.actionSheetView: %@", self.actionSheetView);
    
    // Set initial location at bottom of view
    CGRect frame = self.actionSheetView.frame;
    frame.origin = CGPointMake(0.0, self.view.bounds.size.height - self.actionSheetView.frame.size.height);
    //frame.origin = CGPointMake(0.0, 300);
    self.actionSheetView.frame = frame;
    
    self.actionSheetView.myLeftMargin = self.actionSheetView.myRightMargin = 0;
    self.actionSheetView.myBottomMargin = 0;
    self.actionSheetView.wrapContentHeight = YES;
    
    NSLog(@"");
    NSLog(@"After changing actionSheetView");
    NSLog(@"self.actionSheetView: %@", self.actionSheetView);
    
    // Topic Label Setting
    self.topicLabel.myLeftMargin = 16;
    self.topicLabel.myTopMargin = 4;
    self.topicLabel.myBottomMargin = 16;    
    self.topicLabel.text = self.topicStr;
    //[LabelAttributeStyle changeGapString: self.topicLabel content: self.topicStr];
    self.topicLabel.textColor = [UIColor whiteColor];
    self.topicLabel.font = [UIFont boldSystemFontOfSize: 24];
    [self.topicLabel sizeToFit];        
    
    // ContentLayout Setting
    self.contentLayout.padding = UIEdgeInsetsMake(16, 0, 16, 0);
    self.contentLayout.myLeftMargin = self.contentLayout.myRightMargin = 0;
    self.contentLayout.myTopMargin = 0;
    self.contentLayout.myBottomMargin = 0;
    self.contentLayout.wrapContentHeight = YES;
    
    // Creating Blur Effect
    //self.effectView = [[UIVisualEffectView alloc] initWithEffect: [UIBlurEffect effectWithStyle: UIBlurEffectStyleDark]];
    /*
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle: UIBlurEffectStyleDark];
    self.effectView = [[UIVisualEffectView alloc] initWithEffect: blurEffect];
    self.effectView.frame = self.view.frame;
    self.effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.effectView.myLeftMargin = self.effectView.myRightMargin = 0;
    self.effectView.myTopMargin = self.effectView.myBottomMargin = 0;    
    self.effectView.tag = 100;
    //self.effectView.alpha = 0.5;
    
    [self.view addSubview: self.effectView];
     */
    
    [self.view addSubview: self.actionSheetView];
    
    // Set up an animation for the transition between the views
    CATransition *animation = [CATransition animation];
    [animation setDuration: 0.2];
    [animation setType: kCATransitionPush];
    [animation setSubtype: kCATransitionFromTop];
    [animation setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
    
    //self.view.alpha = 1.0f;
    self.view.backgroundColor = [UIColor clearColor];
    [self.actionSheetView.layer addAnimation: animation forKey: @"TransitionToActionSheet"];
}

- (void)slideOut {
    NSLog(@"");
    NSLog(@"slideOut");
    
    [UIView beginAnimations: @"removeFromSuperviewWithAnimation" context: nil];
    
    // Set delegate and selector to remove from superview when animation completes
    [UIView setAnimationDelegate: self];
    [UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
    
    NSLog(@"");
    NSLog(@"Before setting bounds");
    NSLog(@"self.actionSheetView: %@", self.actionSheetView);
    
    // Move this view to bottom of superview
    CGRect frame = self.actionSheetView.frame;
    frame.origin = CGPointMake(0.0, self.view.bounds.size.height);
    self.actionSheetView.frame = frame;

    NSLog(@"");
    NSLog(@"After setting bounds");
    NSLog(@"self.actionSheetView: %@", self.actionSheetView);
    
    [UIView commitAnimations];
    
    if ([self.delegate respondsToSelector: @selector(actionSheetViewDidSlideOut:)]) {
        [self.delegate actionSheetViewDidSlideOut: self];
    }
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    NSLog(@"");
    NSLog(@"animationDidStop");
    
    if ([animationID isEqualToString: @"removeFromSuperviewWithAnimation"]) {
        [self.view removeFromSuperview];
        
        NSArray *viewsToRemove = self.contentLayout.subviews;
        
        NSLog(@"Before Removing");
        NSLog(@"viewsToRemove: %@", viewsToRemove);
        
        for (UIView *v in viewsToRemove) {
            [v removeFromSuperview];
            NSLog(@"v removeFromSuperview");
        }
        NSLog(@"After Removing");
        NSLog(@"viewsToRemove: %@", viewsToRemove);
    }
}

#pragma mark - UIButton Selector Method
- (void)buttonNormal:(UIButton *)sender {
    NSLog(@"btnPress");
    sender.backgroundColor = [UIColor firstMain];
    
    if (self.customButtonBlock) {
        self.customButtonBlock(sender.selected);
    } else if (self.customButtonTapBlock) {
        [self slideOut];
        self.customButtonTapBlock(sender.tag, sender.accessibilityIdentifier);
    }
}

- (void)buttonHighlight:(UIButton *)sender {
    NSLog(@"buttonHighlight");
    sender.backgroundColor = [UIColor secondMain];
}

- (void)buttonTouchUpOutside:(UIButton *)sender {
    NSLog(@"buttonTouchUpOutside");
    sender.backgroundColor = [UIColor clearColor];
}

#pragma mark - UITapGestureRecognizer Selector Handler Method
// Method below is to achieve the TouchUpInside Behavior
- (void)handleTapFromView: (UITapGestureRecognizer *)sender
{
    NSLog(@"handleTapFromView");
    [self slideOut];
    
    if (self.customViewBlock) {
        self.customViewBlock(sender.view.tag, isTouchDown, sender.view.accessibilityIdentifier);
    }
    
    /*
     if (sender.state == UIGestureRecognizerStateBegan || sender.state == UIGestureRecognizerStateChanged) {
     sender.view.backgroundColor = [UIColor lightGrayColor];
     } else if (sender.state == UIGestureRecognizerStateEnded) {
     sender.view.backgroundColor = [UIColor clearColor];
     }
     */
}

// Methods below are to achieve the selected behavior
// If executing slideOut here, then the TouchUpInside behavior can not be achieved
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"");
    NSLog(@"touchesBegan");
    NSLog(@"");
    
    UITouch *touch = [touches anyObject];
    NSLog(@"touch.view: %@", touch.view);
    NSLog(@"touch.view.tag: %d", (int)touch.view.tag);
    
    isTouchDown = YES;
    
    if (touch.view.tag != 0 && touch.view.tag != 100 && touch.view.tag != 200 && touch.view.tag != 300) {
        touch.view.backgroundColor = [UIColor thirdMain];
    }
    
    if (touch.view.tag == 100) {
        [self slideOut];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"");
    NSLog(@"touchesEnded");
    NSLog(@"");
    
    UITouch *touch = [touches anyObject];
    
    if (touch.view.tag != 0 && touch.view.tag != 100 && touch.view.tag != 200 && touch.view.tag != 300) {
        touch.view.backgroundColor = [UIColor clearColor];                
    }
    
    if (isTouchDown) {
        isTouchDown = NO;
        /*
        if (self.customViewBlock) {
            self.customViewBlock(touch.view.tag, isTouchDown);
        }
         */
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"");
    NSLog(@"touchesCancelled");
    NSLog(@"");
    
    UITouch *touch = [touches anyObject];
    
    if (touch.view.tag != 0 && touch.view.tag != 100 && touch.view.tag != 200 && touch.view.tag != 300) {
        touch.view.backgroundColor = [UIColor clearColor];
    }
    
    if (isTouchDown) {
        isTouchDown = NO;
        
        /*
        if (self.customViewBlock) {
            self.customViewBlock(touch.view.tag, isTouchDown);
        }
         */
    }
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
