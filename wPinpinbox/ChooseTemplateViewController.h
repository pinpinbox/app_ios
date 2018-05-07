//
//  ChooseTemplateViewController.h
//  wPinpinbox
//
//  Created by David Lee on 2017/9/27.
//  Copyright © 2017年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseTemplateViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic) NSString *rank;
@property (nonatomic) NSString *style_id;
@property (nonatomic) NSString *event_id;
@property (nonatomic) BOOL postMode;
@end
