//
//  TestReadBookViewController.h
//  wPinpinbox
//
//  Created by David on 6/13/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TestReadBookViewController;
@protocol TestReadBookViewControllerDelegate <NSObject>
- (void)testReadBookViewControllerViewWillDisappear:(TestReadBookViewController *)controller likeNumber:(NSUInteger)likeNumber isLike:(BOOL)isLike;
@end

//messageNumber:(NSUInteger)messageNumber likesNumber:(NSUInteger)likesNumber isLike:(BOOL)isLike;

@interface TestReadBookViewController : UIViewController
{
    __weak IBOutlet UILabel *typelabel;
}

@property (weak) id <TestReadBookViewControllerDelegate> delegate;

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

@property (nonatomic) BOOL isPresented;
@property (nonatomic) BOOL isAddingBuyPointVC;

@property (nonatomic) BOOL isLikes;
@property (nonatomic) NSUInteger likeNumber;

@property (nonatomic, strong) NSString *eventJoin;
@property (nonatomic) NSString *specialUrl;

- (void)playbool: (id)sender;
- (void)playCheck;

@end
