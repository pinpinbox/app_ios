//
//  ExchangeInfoEditViewController.h
//  wPinpinbox
//
//  Created by David on 12/03/2018.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ExchangeInfoEditViewController;

@protocol ExchangeInfoEditViewControllerDelegate <NSObject>
//- (void)finishExchange:(NSMutableDictionary *)exchangeDic;
- (void)finishExchange:(NSMutableDictionary *)exchangeDic bgV:(UIView *)bgV;
@end

@interface ExchangeInfoEditViewController : UIViewController

//@property (strong, nonatomic, readwrite) UIImageView *imageView;
@property (nonatomic) BOOL isExisting;
@property (nonatomic) BOOL hasExchanged;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) NSMutableDictionary *exchangeDic;
@property (strong, nonatomic) UIView *backgroundView;
@property (nonatomic) NSInteger photoId;
//- (instancetype)initWithExchangeStuff:(ExchangeStuff *)exchangeStuff;

@property (weak) id <ExchangeInfoEditViewControllerDelegate> delegate;

@end
