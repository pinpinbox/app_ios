//
//  PagetextViewController.h
//  wPinpinbox
//
//  Created by Angus on 2015/12/14.
//  Copyright © 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookViewController.h"
#import "UIViewController+CWPopup.h"

@interface PagetextViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    __weak IBOutlet UITableView *mytableview;
}

@property (nonatomic, strong) NSString *albumId;
@property(nonatomic,strong)NSString *type;
@property(nonatomic,strong)NSDictionary *bookdata;
@property(nonatomic,strong)NSDictionary *pagedata;
@property(assign,nonatomic)NSInteger page;
@property(nonatomic,strong)NSString *file;
@property(weak)BookViewController *bookvc;
@property(nonatomic)BOOL isplay;
@property(nonatomic,strong)NSDictionary * localdata;

@property (nonatomic) BOOL fromInfoTxt;

@end
