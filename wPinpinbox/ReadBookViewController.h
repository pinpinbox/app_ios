//
//  ReadBookViewController.h
//  wPinpinbox
//
//  Created by David on 10/28/16.
//  Copyright © 2016 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReadBookViewController : UIViewController
{
    __weak IBOutlet UILabel *typelabel;
}

@property (nonatomic) BOOL isPresented;

@property (nonatomic, strong) NSString *albumid;
@property (nonatomic, strong) NSString *DirectoryPath;
@property (nonatomic, strong) NSString *eventId;

@property (nonatomic, strong) NSDictionary *dic;

@property (nonatomic) BOOL postMode;
@property (nonatomic) BOOL audioSwitch;
@property (nonatomic) BOOL videoPlay;
@property (nonatomic) BOOL fromPageText;

@property (nonatomic) BOOL isDownloaded;
@property (nonatomic) BOOL isFree;

- (void)playbool: (id)sender;
- (void)playCheck;

@end
