//
//  Taoban1TableViewCell.h
//  wPinpinbox
//
//  Created by Angus on 2015/12/30.
//  Copyright © 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Taoban1TableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UIScrollView *showscrollview;
@property(strong)NSString*sid;

@end
