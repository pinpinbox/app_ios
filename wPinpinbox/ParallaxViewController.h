//
//  ParallaxViewController.h
//  ParralaxDetailView
//
//  Created by apple on 29/04/16.
//  Copyright © 2016 ClickApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ParallaxViewControllerDelegate <NSObject>
- (void)checkYOffset:(CGFloat)yOffset scrollDirection:(NSString *)scrollDirection;
@end

@interface ParallaxViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *snapshotImageView;
@property (weak, nonatomic) IBOutlet UIView *bView;

@property (weak, nonatomic) id <ParallaxViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *likeView;
@property (weak, nonatomic) IBOutlet UILabel *headerLikedNumberLabel;
//@property (weak, nonatomic) IBOutlet UILabel *headerViewedNumberLabel;

@property (weak, nonatomic) IBOutlet UIView *messageView;
@property (weak, nonatomic) IBOutlet UILabel *headerMessageNumberLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTrail;

@property (weak, nonatomic) IBOutlet UIView *sponsorView;
@property (weak, nonatomic) IBOutlet UILabel *sponsorNumberLabel;

@property (weak, nonatomic) IBOutlet UIView *headerBgView;
@property (weak, nonatomic) IBOutlet UIButton *headerImgBtn;
@property (weak, nonatomic) IBOutlet UIView *gradientView;

/**
 @property bottomScroll
 @description UIScrollView place at bottom of View holding labels and text and other controls one want to place on it
 */
@property(nonatomic, weak) IBOutlet UIScrollView *bottomScroll;

/**
 @property topScroll
 @description UIScrollView place at top of View holding post image
 */
@property(nonatomic, weak) IBOutlet UIScrollView *topScroll;


/**
 @property contentViewHeight
 @description height for contentview palced in bottom scroll so that we can make it scrollable by increasing this height value
 */
@property(nonatomic, weak) IBOutlet NSLayoutConstraint *contentViewHeight;


/**
 @property headerImageView
 @description showing header image view for the post
 */
@property(nonatomic, weak) IBOutlet UIImageView *headerImageView;

/**
 @property contentView
 @description view where we add our other controls
 */
@property(nonatomic, weak)  IBOutlet UIView *contentView;

/**
 @property headerImageViewHeight
 @description value for setting header image height
 */
@property(nonatomic, weak)  IBOutlet NSLayoutConstraint *headerImageViewHeight; //default half of screen size


/**
 @method adjustContentViewHeight
 @description this will adjust content view height
 */
- (void)adjustContentViewHeight;
- (IBAction)headerImgBtnPress:(id)sender;

- (void)likeViewTapped:(UITapGestureRecognizer *)gesturerecognizer;
- (void)messageViewTapped:(UITapGestureRecognizer *)gesturerecognizer;
- (void)sponsorViewTapped:(UITapGestureRecognizer *)gesturerecognizer;
@end
