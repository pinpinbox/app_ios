//
//  SetupTableViewController.h
//  wPinpinbox
//
//  Created by Angus on 2015/11/4.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SetupTableViewControllerDelegate <NSObject>
- (void)passTemplateIdForPushing: (NSString *)templateId;
@end

@interface SetupTableViewController : UITableViewController
@property(nonatomic)NSInteger type;
@property(nonatomic,strong)NSArray *classlist;
@property(nonatomic)NSString *rank;

@property (weak) id <SetupTableViewControllerDelegate> delegate;

@end
