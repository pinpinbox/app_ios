//
//  BuyPPointViewController.h
//  wPinpinbox
//
//  Created by David on 5/25/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BuyPPointViewController;
@protocol BuyPPointViewControllerDelegate <NSObject>
- (void)buyPPointViewController: (BuyPPointViewController *)controller;
@end

@interface BuyPPointViewController : UIViewController
@property (nonatomic) NSString *fromVC;
@property (weak) id <BuyPPointViewControllerDelegate> delegate;
@end
