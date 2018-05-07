//
//  MemberTextViewTableViewCell.h
//  wPinpinbox
//
//  Created by Angus on 2015/10/20.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MemberTextViewTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UITextView *mytextview;

@end
