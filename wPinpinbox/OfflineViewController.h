//
//  OfflineViewController.h
//  wPinpinbox
//
//  Created by Angus on 2016/5/31.
//  Copyright © 2016年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OfflineViewController : UIViewController{
    __weak IBOutlet UILabel *wtitle;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectioview;
@property (weak, nonatomic) IBOutlet UIButton *btn1;
@property (weak, nonatomic) IBOutlet UIButton *btn2;
@property (weak, nonatomic) IBOutlet UIButton *btn3;
@end
