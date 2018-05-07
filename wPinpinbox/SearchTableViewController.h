//
//  SearchTableViewController.h
//  wPinpinbox
//
//  Created by Angus on 2015/11/4.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchTableViewController : UITableViewController

@property(nonatomic)NSString *searchtype;
@property(nonatomic)NSString *textkey;

-(void)isLoading:(BOOL)bo;
-(void)alldata:(NSMutableArray *)arr;
-(void)nextId:(NSInteger)nid;

@end
