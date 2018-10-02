//
//  NewCooperationViewController.h
//  wPinpinbox
//
//  Created by David on 2018/9/25.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NewCooperationVCDelegate <NSObject>
- (void)newCoopeartionVCFinished:(NSString *)albumId;
@end

@interface NewCooperationViewController : UIViewController
@property (nonatomic) id<NewCooperationVCDelegate> vDelegate;
@property (strong, nonatomic) NSString *userIdentity;
@property (nonatomic) NSString *albumId;
@end

NS_ASSUME_NONNULL_END
