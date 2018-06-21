//
//  ParallaxViewController.h
//  ParralaxDetailView
//
//  Created by apple on 29/04/16.
//  Copyright © 2016 ClickApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParallaxViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *likeView;
@property (weak, nonatomic) IBOutlet UILabel *headerLikedNumberLabel;
//@property (weak, nonatomic) IBOutlet UILabel *headerViewedNumberLabel;

@property (weak, nonatomic) IBOutlet UIView *messageView;
@property (weak, nonatomic) IBOutlet UILabel *headerMessageNumberLabel;

@property (weak, nonatomic) IBOutlet UIView *sponsorView;
@property (weak, nonatomic) IBOutlet UILabel *sponsorNumberLabel;

@property (weak, nonatomic) IBOutlet UIView *headerBgView;
@property (weak, nonatomic) IBOutlet UIButton *headerImgBtn;
@property (weak, nonatomic) IBOutlet UIView *gradientView;

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
