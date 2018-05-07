//
//  BookViewController.h
//  wPinpinbox
//
//  Created by Angus on 2015/11/6.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookViewController : UIViewController
{
    __weak IBOutlet UILabel *typelabel;
}

@property (nonatomic, strong) NSString *albumid;
@property (nonatomic, strong) NSString *DirectoryPath;
@property (nonatomic, strong) NSString *eventId;

@property (nonatomic, strong) NSDictionary *dic;

@property (nonatomic) BOOL postMode;
@property (nonatomic) BOOL fromEventPostVC;

@property (nonatomic) BOOL audioSwitch;
@property (nonatomic) BOOL videoPlay;
@property (nonatomic) BOOL fromPageText;

@property (nonatomic) BOOL isDownloaded;


- (void)playbool: (id)sender;
- (void)playCheck;

@end
