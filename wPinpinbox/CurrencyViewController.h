//
//  CurrencyViewController.h
//  wPinpinbox
//
//  Created by Angus on 2015/8/10.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CurrencyViewController : UIViewController
{
    __weak IBOutlet UIView *pickview;
    
    __weak IBOutlet UILabel *ptitle;
    __weak IBOutlet UILabel *ptext;
    
    __weak IBOutlet UIButton *btn_buy;
}
@end
