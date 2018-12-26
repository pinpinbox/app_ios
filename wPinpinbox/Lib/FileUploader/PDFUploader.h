//
//  PDFUploader.h
//  wPinpinbox
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PDFUploaderDelegate
- (NSDictionary *)userInfo;
- (NSString *)retrieveSign:(NSDictionary *)param;
- (BOOL)isExporter;
@end

typedef void(^PDFReadProgressBlock)(int currentPage, int totalPage);
typedef void(^PDFReadExportFinishedBlock)(NSError * _Nullable error, NSArray * _Nullable icons, NSArray * _Nullable ids);//(NSError * _Nullable error);
typedef void(^PDFUploaderProgressBlock)(int currentPage, int totalPage, NSString *desc);
typedef void(^PDFUploaderResultBlock)(NSError * _Nullable error);



@interface PDFUploader : NSObject<UIDocumentPickerDelegate>
@property (nonatomic, readonly) NSString *taskId;
- (id) initWithAlbumID:(NSString *)albumID
        availablePages:(int)availablePages
          infoDelegate:(id<PDFUploaderDelegate>)infoDelegate
         progressblock:(PDFReadProgressBlock)progressblock
   exportFinishedblock:(PDFReadExportFinishedBlock)finishedblock
   uploadProgressBlock:(PDFUploaderProgressBlock)uploadblock
     uploadResultBlock:(PDFUploaderResultBlock)resultblock;

- (void)cacenlCurrentWork;
- (void)exportPagesToImages:(NSURL *)pdfURL;
@end

NS_ASSUME_NONNULL_END
