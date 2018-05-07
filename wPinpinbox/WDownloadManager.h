//
//  WDownloadManager.h
//  WDownloadManager
//
//  Created by Angus on 2015/10/14.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString * const kMZDownloadKeyURL;
extern NSString * const kMZDownloadKeyStartTime;
extern NSString * const kMZDownloadKeyFileName;
extern NSString * const kMZDownloadKeyProgress;
extern NSString * const kMZDownloadKeyTask;
extern NSString * const kMZDownloadKeyStatus;
extern NSString * const kMZDownloadKeyDetails;
extern NSString * const kMZDownloadKeyResumeData;

extern NSString * const RequestStatusDownloading;
extern NSString * const RequestStatusPaused;
extern NSString * const RequestStatusFailed;
@protocol MZDownloadDelegate <NSObject>
@optional
/**A delegate method called each time whenever new download task is start downloading
 */
//下載開始
- (void)downloadRequestStarted:(NSURLSessionDownloadTask *)downloadTask;
/**A delegate method called each time whenever any download task is cancelled by the user
 */
//下載取消
- (void)downloadRequestCanceled:(NSURLSessionDownloadTask *)downloadTask;
/**A delegate method called each time whenever any download task is finished successfully
 */
//下載完成
- (void)downloadRequestFinished:(NSString *)fileName;
//回傳下載進度
- (void)downloadfileName:(NSString *)fileName progress:(float)progress;

//下載失敗
-(void)downloadfail:(NSString *)error;
@end
@protocol MZDownloadDataSource <NSObject>
@optional
-(NSString *)downloadRequestfileName;
@end
@interface WDownloadManager : NSObject<NSURLSessionDelegate, UIActionSheetDelegate>
{
    NSIndexPath *selectedIndexPath;
    
    UIActionSheet *actionSheetRetry;
    UIActionSheet *actionSheetPause;
    UIActionSheet *actionSheetStart;
}

+(WDownloadManager*)getInstance;


/**An array that holds the information about all downloading tasks.
 */
@property(nonatomic, strong) NSMutableArray *downloadingArray;
/**A session manager for background downloading.
 */
@property(nonatomic, strong) NSURLSession *sessionManager;
@property (nonatomic, weak) id<MZDownloadDelegate> delegate;
@property (nonatomic, weak) id<MZDownloadDataSource>dataSoure;

- (NSURLSession *)backgroundSession;
/**A method for adding new download task.
 @param NSString* file name
 @param NSString* file url
 */
- (void)addDownloadTask:(NSString *)fileName fileURL:(NSString *)fileURL;
/**A method for restoring any interrupted download tasks e.g user force quits the app or any network error occurred.
 */
- (void)populateOtherDownloadTasks;


- (void)waddDownloadTask:(NSString *)fileName fileURL:(NSString *)fileURL data:(NSDictionary *)data;

@end
