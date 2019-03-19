//
//  wTools.m
//  wPinpinbox
//
//  Created by Angus on 2015/8/10.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "wTools.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "boxAPI.h"
//
#import "CustomIOSAlertView.h"
#import "UIColor+Extensions.h"
#import "ContentCheckingViewController.h"

#import "GlobalVars.h"

#import <GoogleAnalytics/GAI.h>
#import <GoogleAnalytics/GAIDictionaryBuilder.h>
#import <GoogleAnalytics/GAIFields.h>

#import "UIViewController+ErrorAlert.h"

#import "UserInfo.h"

static wTools *instance =nil;

@implementation wTools

- (id)init
{
    self = [super init];
    if (self) {
                        
    }
    return self;
}

+(void)showAlertTile:(NSString *)title Message:(NSString *)message ButtonTitle:(NSString *)buttonTitle;
{
    NSString *btil = buttonTitle;
    if ( buttonTitle == nil )
    {
        btil = @"確定";
    }
    
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:btil otherButtonTitles: nil];
//
//    [alertView show];    
}

+(void)releaseInstance
{
    //[instance release];
    instance = nil;
}
+(wTools * _Nonnull )getInstance
{
    if( instance == nil )
    {
        instance = [[wTools alloc] init];
        
    }
    return instance;
}
//圖片按鈕
+(UIButton *)W_Button:(id)sender frame:(CGRect)frame imgname:(NSString *)imgname SELL:(SEL)sel tag:(int)tag
{
    // NSString *fullpath = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:imgname];
    UIImage *jImage = [UIImage imageNamed:imgname];
    UIButton *Wbut = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [Wbut setFrame:frame];
    [Wbut setImage:jImage forState:UIControlStateNormal];
    [Wbut addTarget:sender action:sel forControlEvents:UIControlEventTouchUpInside];
    [Wbut setTag:tag];
    
    return Wbut;
}
+(void)ShowMBProgressHUD{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [MBProgressHUD showHUDAddedTo:app.window animated:YES];
}

+(void)HideMBProgressHUD{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [MBProgressHUD hideHUDForView:app.window animated:YES];
}

+(void)ImageViewRadius:(UIImageView *)imgv borderWidth:(float)borderWidth{
    
    imgv.clipsToBounds=YES;
    imgv.layer.cornerRadius=imgv.frame.size.width/2.0;
    imgv.layer.borderWidth=borderWidth;
    imgv.layer.borderColor=[[UIColor whiteColor]CGColor];
    
}
+(void)myMenu{
//        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//        [app.menu showMenu];
}

+(UINavigationController *)myNavigationController{
     AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return app.myNav;
}

//id
+(NSString *)getUserID{
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    if ([userPrefs objectForKey:@"id"]) {
        return [userPrefs objectForKey:@"id"];
    }
    return @"";
}
//token
+(NSString *)getUserToken{
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    if ([userPrefs objectForKey:@"token"]) {
        return [userPrefs objectForKey:@"token"];
    }

    return @"";
}
//UUID
+(NSString *)getUUID{
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    if ([userPrefs objectForKey:@"APNSID"]) {
        return [userPrefs objectForKey:@"APNSID"];
    }
    
    return nil;
}

//切換書本說明頁

+(void)ToRetrievealbumpViewControlleralbumid:(NSString *)albumid {
    NSLog(@"ToRetrievealbumpViewControlleralbumid");
    
    [wTools ShowMBProgressHUD];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *response = [boxAPI retrievealbump: @"qwert"
                                                uid: [wTools getUserID]
                                              token: [wTools getUserToken]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"check response");
                NSLog(@"response: %@", response);
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"wTools");
                    NSLog(@"ToRetrievealbumpViewControlleralbumid");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"ToRetrievealbumpViewControlleralbumid"
                                         albumId: albumid
                                        userbook: @""
                                         eventId: @""
                                        postMode: NO];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
//                    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        NSLog(@"result bool value is YES");
                        
                        NSLog(@"dic data photo: %@", dic[@"data"][@"photo"]);
                        NSLog(@"dic data user name: %@", dic[@"data"][@"user"][@"name"]);
                        
//                        RetrievealbumpViewController *rev=[[RetrievealbumpViewController alloc]initWithNibName:@"RetrievealbumpViewController" bundle:nil];
//                        rev.data=[dic[@"data"] mutableCopy];
//                        
//                        NSLog(@"rev.data: %@", rev.data);
//                        
//                        rev.albumid=albumid;
//                        [app.myNav pushViewController:rev animated:YES];
                    } else if ([dic[@"result"] intValue] == 0) {
                        NSLog(@"失敗：%@",dic[@"message"]);
                        [self showCustomErrorAlert: dic[@"message"]];
                    } else {
                        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                    }
                }
            }
        });
    });
}

+(NSString *)stringisnull:(id )str{
    if ([str isKindOfClass:[NSNull class]]) {
        return @"";
    }
    if ([str isKindOfClass:[NSNumber class]]) {
        return [str stringValue];
    }
    return str;
}

+ (BOOL)objectExists:(id)object {
    if (object != nil) {
        //NSLog(@"object is not nil");
        
        if (![object isEqual: [NSNull null]]) {
            //NSLog(@"object does not equal to null");
            return YES;
        } else {
            //NSLog(@"object does equal to null");
            return NO;
        }
    } else {
        //NSLog(@"object is nil");
        return NO;
    }
}

//Ｐ不足
+(void)InsufficientP{
//    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    CurrencyViewController *cvc=[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"CurrencyViewController"];
//
//    [app.myNav pushViewController:cvc animated:YES];
}

//作者介紹
+(void)showCreativeViewController:(NSString *)albumid{
    NSLog(@"showCreativeViewController");
    NSLog(@"albumid: %@", albumid);
    
//    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    CreativeViewController *cvc=[[UIStoryboard storyboardWithName:@"Creative" bundle:nil]instantiateViewControllerWithIdentifier:@"CreativeViewController"];
//    //CreativeViewController *cvc = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"CreativeViewController"];
//    cvc.albumid=albumid;
//    [app.myNav pushViewController:cvc animated:YES];

}

//作者介紹 依據作者ID 是否關注
+(void)showCreativeViewuserid:(NSString *)userid  isfollow:(BOOL)follow{
    NSLog(@"showCreativeViewuserid");
//    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    CreativeViewController *cvc=[[UIStoryboard storyboardWithName:@"Creative" bundle:nil]instantiateViewControllerWithIdentifier:@"CreativeViewController"];
//    cvc.userid=userid;
//    cvc.follow=follow;
//    [app.myNav pushViewController:cvc animated:YES];
}

//分享
+(void)Activitymessage:(NSString *)message {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:[NSArray arrayWithObjects:message, nil] applicationActivities:nil];

    [app.myNav presentViewController:activityVC animated:YES completion:nil];
}

//留言板
+(void)messageboard:(NSString *)alid
{
//    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    MessageboardViewController *mv=[[MessageboardViewController alloc]initWithNibName:@" MessageboardViewController" bundle:nil];
//    mv.alid=alid;
//    MessageboardViewController *messagev=[[MessageboardViewController alloc]initWithNibName:@"MessageboardViewController" bundle:nil];
//    messagev.title=@"留言板";
//    messagev.alid=alid;
//    [app.myNav pushViewController:messagev animated:YES];
}

//快件相本
+(void)FastBook:(NSString *)alid{
//    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
//    FastViewController *fvc=[[UIStoryboard storyboardWithName:@"Fast" bundle:nil]instantiateViewControllerWithIdentifier:@"FastViewController"];
//    fvc.selectrow=[wTools userbook];
//    fvc.albumid=alid;
//    fvc.booktype=1000;
//    [app.myNav pushViewController:fvc animated:YES];
}

+(void)FastBook:(NSString *)alid choice: (NSString *)choice {
//    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
//    FastViewController *fvc = [[UIStoryboard storyboardWithName:@"Fast" bundle:nil]instantiateViewControllerWithIdentifier:@"FastViewController"];
//    fvc.selectrow = [wTools userbook];
//    fvc.albumid = alid;
//    fvc.booktype = 1000;
//    fvc.choice = choice;
//    [app.myNav pushViewController:fvc animated:YES];
}

// Check Album Sample
+ (void)readSampleBook:(NSString *)albumId dictionary: (NSDictionary *)data isFree: (BOOL)isFree {
//    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    ReadBookViewController *readBookVC = [[ReadBookViewController alloc] initWithNibName: @"ReadBookViewController" bundle: nil];
//    readBookVC.dic = data;
//
//    //NSLog(@"data: %@", data);
//
//    readBookVC.isDownloaded = NO;
//    readBookVC.albumid = albumId;
//    readBookVC.isFree = isFree;
//
//    [app.myNav pushViewController: readBookVC animated: YES];
}

//預覽本地書本
+(void)ReadTestBookalbumid: (NSString *)albumId
                  userbook: (NSString *)userbook
                   eventId: (NSString *)eventId
                  postMode: (BOOL)postMode
           fromEventPostVC: (BOOL)fromEventPostVC
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [wTools ShowMBProgressHUD];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *response = [boxAPI retrievealbump: albumId
                                                uid: [wTools getUserID]
                                              token: [wTools getUserToken]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"response from retrievealbump");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"wTools");
                    NSLog(@"ReadTestBookalbumid");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"ReadTestBookalbumid"
                                         albumId: albumId
                                        userbook: userbook
                                         eventId: eventId
                                        postMode: postMode];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        NSLog(@"result bool value is YES");
                        
                        
                        NSLog(@"dic data photo: %@", dic[@"data"][@"photo"]);
                        NSLog(@"dic data user name: %@", dic[@"data"][@"user"][@"name"]);
                        
                        ContentCheckingViewController *contentCheckingVC = [[UIStoryboard storyboardWithName: @"ContentCheckingVC" bundle: nil] instantiateViewControllerWithIdentifier: @"ContentCheckingViewController"];
                        contentCheckingVC.albumId = albumId;
                        contentCheckingVC.postMode = postMode;
                        
                        [app.myNav pushViewController: contentCheckingVC animated: YES];
                    } else if ([dic[@"result"] intValue] == 0) {
                        NSLog(@"失敗：%@",dic[@"message"]);
                        [self showCustomErrorAlert: dic[@"message"]];
                    } else {
                        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                    }
                }
            }
        });
    });
}

+(void)ReadBookalbumid:(NSString *)albumid
              userbook:(NSString *)userbook
               eventId: (NSString *)eventId
              postMode: (BOOL)postMode
       fromEventPostVC:(BOOL)fromEventPostVC
{
    //AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    //檢查本地...
    NSString *name=[NSString stringWithFormat:@"%@%@",[wTools getUserID],albumid];
    NSLog(@"name: %@", name);
    
    NSString *docDirectoryPath = [filepinpinboxDest stringByAppendingPathComponent:name];
    NSLog(@"docDirectoryPath: %@", docDirectoryPath);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //檢查資料夾是否存在
    if ([fileManager fileExistsAtPath:docDirectoryPath]) {
        NSLog(@"存在%@",albumid);
        
        //判斷是否需要更新
        NSFileManager *fm=[NSFileManager defaultManager];
        NSString *infoPath=[docDirectoryPath stringByAppendingPathComponent:@"info.txt"];
        
          if ([fm fileExistsAtPath:infoPath]) {
              NSString *str=[NSString stringWithContentsOfFile:infoPath encoding:NSUTF8StringEncoding error:nil];
              NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding]  options:NSJSONReadingMutableContainers error:nil];
              NSString *unixt= dic[@"modifytime"];
              
              NSLog(@"unixt:%@",unixt);
              
              [wTools ShowMBProgressHUD];
              dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                  
                  NSString *respone=[boxAPI checkalbumzip:[wTools getUserID] token:[wTools getUserToken] album_id:albumid];
                  
                  dispatch_async(dispatch_get_main_queue(), ^{
                      
                      [wTools HideMBProgressHUD];
                      
                      if (respone!=nil) {
                          NSLog(@"%@",respone);
                          NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                          
                          if ([dic[@"result"]boolValue]) {
                              
                              if (![unixt isEqualToString:[dic[@"data"][@"modifytime"] stringValue]]) {
                                  //已過期 下載新檔案
//                                  PreviewbookViewController *rv=[[PreviewbookViewController alloc]initWithNibName:@"PreviewbookViewController" bundle:nil];
//                                  rv.albumid=albumid;
//                                  rv.userbook=userbook;
//                                  [app.myNav pushViewController:rv animated:YES];
                                  
                                  return;
                              }
                              
//                              BookViewController *bv=[[BookViewController alloc]initWithNibName:@"BookViewController" bundle:nil];
//                              bv.albumid=albumid;
//                              bv.DirectoryPath=docDirectoryPath;
//                              bv.postMode = postMode;
//                              bv.eventId = eventId;
//                              bv.fromEventPostVC = fromEventPostVC;
//                              [app.myNav pushViewController:bv animated:YES];
                              
                          }else{
                              
//                              BookViewController *bv=[[BookViewController alloc]initWithNibName:@"BookViewController" bundle:nil];
//                              bv.albumid=albumid;
//                              bv.DirectoryPath=docDirectoryPath;
//                              bv.postMode = postMode;
//                              bv.eventId = eventId;
//                              bv.fromEventPostVC = fromEventPostVC;
//                              [app.myNav pushViewController:bv animated:YES];
                          }
                          
                      }else{
                          
//                          BookViewController *bv=[[BookViewController alloc]initWithNibName:@"BookViewController" bundle:nil];
//                          bv.albumid=albumid;
//                          bv.DirectoryPath=docDirectoryPath;
//                          bv.postMode = postMode;
//                          bv.eventId = eventId;
//                          bv.fromEventPostVC = fromEventPostVC;
//                          [app.myNav pushViewController:bv animated:YES];
                      }
                  });
                  
              });
              
          } else {
              NSLog(@"沒有info");
              //Remind *rv=[[Remind alloc]initWithFrame:app.menu.view.bounds];
//              Remind *rv=[[Remind alloc]initWithFrame: app.window.bounds];
//              [rv addtitletext:[NSString stringWithFormat:@"404 沒有檔案錯誤(%@)",albumid]];
//              [rv addBackTouch];
//              //[rv showView:app.menu.view];
//              [rv showView: app.window];
              NSString *err404 = [NSString stringWithFormat:@"404 沒有檔案錯誤(%@)",albumid];
              [UIViewController showCustomErrorAlertWithMessage:err404 onButtonTouchUpBlock:^(CustomIOSAlertView * _Nonnull customAlertView, int buttonIndex) {
                  [customAlertView close];
              }];
              
//              PreviewbookViewController *rv=[[PreviewbookViewController alloc]initWithNibName:@"PreviewbookViewController" bundle:nil];
//              rv.albumid=albumid;
//              [app.myNav pushViewController:rv animated:YES];
          }
    } else {
      //檢查下載
//        PreviewbookViewController *rv=[[PreviewbookViewController alloc]initWithNibName:@"PreviewbookViewController" bundle:nil];
//        rv.albumid=albumid;
//        rv.userbook=userbook;
//        [app.myNav pushViewController:rv animated:YES];
    }

}

//相本可編輯數量
+(int)userbook{
    
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *profile=nil;
    if ([userPrefs objectForKey:@"profile"]) {
        profile=[userPrefs objectForKey:@"profile"];
    }else{
        return 0;
    }

    if ([profile[@"usergrade"] isEqualToString:@"free"]) {
        return 22;
    }
    if ([profile[@"usergrade"] isEqualToString:@"plus"]) {
        return 80;
    }
    if ([profile[@"usergrade"] isEqualToString:@"profession"]) {
        return 100;
    }
    return 0;
    
}


+(void)editphotoinfo:(NSString *)albumid templateid:(NSString *)templateid eventId: (NSString *)eventId postMode: (BOOL)postMode {
    
//    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    BookdetViewController *bdv = [[BookdetViewController alloc]initWithNibName:@"BookdetViewController" bundle:nil];
//    //bdv.data=[dic[@"data"] mutableCopy];
//    bdv.album_id = albumid;
//    bdv.templateid = templateid;
//    bdv.postMode = postMode;
//    bdv.eventId = eventId;
//    
//    [app.myNav pushViewController:bdv animated:YES];
    
    /*
    [wTools ShowMBProgressHUD];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *respone=[boxAPI getalbumsettings:[wTools getUserID] token:[wTools getUserToken] album_id:albumid];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            if (respone!=nil) {
                NSLog(@"%@",respone);
                NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
                if ([dic[@"result"]boolValue]) {
                    NSLog(@"getalbumsettings");
                    NSLog(@"dic data: %@", dic);
                    
                    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    BookdetViewController *bdv=[[BookdetViewController alloc]initWithNibName:@"BookdetViewController" bundle:nil];
                    bdv.data=[dic[@"data"] mutableCopy];
                    bdv.album_id=albumid;
                    bdv.templateid=templateid;
                    bdv.postMode = postMode;
                    bdv.eventId = eventId;
                    [app.myNav pushViewController:bdv animated:YES];
                    
                }else{
                    NSLog(@"失敗：%@",dic[@"message"]);
                }
                
            }
        });
        
    });
     */
 
}
+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}
+(NSString *)localstring{
    NSString *language=[NSString stringWithFormat:@"%@",[[[NSUserDefaults standardUserDefaults]objectForKey:@"AppleLanguages"]objectAtIndex:0]];
    
    /*
    if ([language isEqualToString:@"zh-Hant"] ||[language isEqualToString:@"zh-TW"]) {
        language=@"zh-TW";
    }else{
        language=@"en";
    }
     */
    
    language=@"zh-TW";
    
    return language;
}
+(UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize

{
    if (image.size.width>1000 ||image.size.height>1000) {
        UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
        [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height *scaleSize)];
        
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        return scaledImage;
    }
    
    
    return image;
    
    
  }


+(BOOL)pwd:(NSString *)resultString{
    //數字條件
    NSRegularExpression *tNumRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[0-9]" options:NSRegularExpressionCaseInsensitive error:nil];
    
    //符合數字條件的有幾個字元
    int tNumMatchCount = (int)[tNumRegularExpression numberOfMatchesInString:resultString                                                                     options:NSMatchingReportProgress
                                                                  range:NSMakeRange(0, resultString.length)];
    if (tNumMatchCount==0) {
        return NO;
    }
    
    //英文字條件
    NSRegularExpression *tLetterRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[A-Za-z]" options:NSRegularExpressionCaseInsensitive error:nil];
    
    //符合英文字條件的有幾個字元
    int tLetterMatchCount = (int)[tLetterRegularExpression numberOfMatchesInString:resultString options:NSMatchingReportProgress range:NSMakeRange(0, resultString.length)];
    if (tLetterMatchCount==0) {
        return NO;
    }
    
    return YES;
}

+ (void)logOut {
    NSLog(@"logOut");
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName: appDomain];
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSLog(@"app.myNav.viewControllers: %@", app.myNav.viewControllers);
    
    for (UIViewController *controller in app.myNav.viewControllers) {
        if ([controller isKindOfClass: [ViewController class]]) {
            NSLog(@"controller.view.subviews: %@", controller.view.subviews);
            
            for (UIView *v in controller.view.subviews) {
                if ([v isKindOfClass: [UIImageView class]]) {
                    NSLog(@"v.accessibilityIdentifier: %@", v.accessibilityIdentifier);
                }
            }
            [app.myNav popToViewController: controller animated: NO];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject: [NSNumber numberWithBool: YES] forKey: @"logOutFromSetting"];
            [defaults synchronize];
            [UserInfo resetUserInfo];
            break;
        }
    }
    
}

+ (void)deleteAllCoreData {
    NSLog(@"deleteAllCoreData");
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    
    if ([delegate performSelector: @selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    
    NSFetchRequest *fetchAllObjects1 = [[NSFetchRequest alloc] init];
    [fetchAllObjects1 setEntity: [NSEntityDescription entityForName: @"Slot" inManagedObjectContext: context]];
    //only fetch the managedObjectID
    [fetchAllObjects1 setIncludesPropertyValues: NO];
    
    NSFetchRequest *fetchAllObjects2 = [[NSFetchRequest alloc] init];
    [fetchAllObjects2 setEntity: [NSEntityDescription entityForName: @"Browse" inManagedObjectContext: context]];
    //only fetch the managedObjectID
    [fetchAllObjects2 setIncludesPropertyValues: NO];
    
    NSError *error = nil;
    NSArray *allObjects1 = [context executeFetchRequest: fetchAllObjects1
                                                  error: &error];
    NSArray *allObjects2 = [context executeFetchRequest: fetchAllObjects2
                                                  error: &error];
    
    if (error) {
        NSLog(@"Has Error for fetching all objects");
    }
    
    for (NSManagedObject *object in allObjects1) {
        [context deleteObject: object];
    }
    for (NSManagedObject *object in allObjects2) {
        [context deleteObject: object];
    }
    
    NSError *saveError = nil;
    
    if (![context save: &saveError]) {
        NSLog(@"save error");
    }
    NSLog(@"saveError: %@", saveError);
}

+ (void)setStatusBarBackgroundColor:(UIColor *)color {
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey: @"statusBarWindow"] valueForKey: @"statusBar"];
    
    if ([statusBar respondsToSelector: @selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}

+ (NSString *)remainingTimeCalculation:(NSString *)timeStr {
    NSLog(@"remainingTimeCalculation");
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *endDate = [dateFormatter dateFromString: timeStr];
    NSLog(@"endDate: %@", endDate);
    
    NSDate *currentDate = [NSDate date];
    NSLog(@"currentDate: %@", currentDate);
    
    NSTimeInterval time = [endDate timeIntervalSinceDate: currentDate];
    NSLog(@"time: %f", time);
    
    int days = ((int)time) / (3600 * 24);
    int hours = ((int)time) % (3600 * 24) / 3600;
    int minutes = ((int)time) % (3600 * 24) % 3600 / 60;
    
    NSString *dateContent = [[NSString alloc] initWithFormat:@"剩餘時間:%i天%i小時%i分",days,hours,minutes];
    return dateContent;        
}

+ (NSInteger)remainingTimeCalculationOnlyMinute:(NSString *)timeStr {
    NSLog(@"remainingTimeCalculationOnlyMinute");
    //  parameter is not NSString or nil  //
    if ([timeStr isKindOfClass:[NSNull class]] || !timeStr ) return 0;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *endDate = [dateFormatter dateFromString: timeStr];
    NSLog(@"endDate: %@", endDate);
    
    NSDate *currentDate = [NSDate date];
    NSLog(@"currentDate: %@", currentDate);
    
    NSTimeInterval time = [endDate timeIntervalSinceDate: currentDate];
    NSLog(@"time: %f", time);
    
    NSInteger minutes = ((int)time) % (3600 * 24) % 3600 / 60;
    NSLog(@"minutes: %ld", (long)minutes);
    
    return minutes;
}

+ (NSInteger)timeCalculation:(NSString *)timeStr {
    NSLog(@"timeCalculation");
    if ([timeStr isKindOfClass:[NSNull class]] || !timeStr ) return 0;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *endDate = [dateFormatter dateFromString: timeStr];
    NSLog(@"endDate: %@", endDate);
    
    NSDate *currentDate = [NSDate date];
    NSLog(@"currentDate: %@", currentDate);
    
    NSTimeInterval time = [endDate timeIntervalSinceDate: currentDate];
    NSLog(@"time: %f", time);
    
    NSInteger timeInt = (int)time;
    
    return timeInt;
}

+ (UIImage *)normalSnapshotImage:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return snapshotImage;
}

#pragma mark - Custom Error Alert Method
+ (void)showCustomErrorAlert: (NSString *)msg {
    [UIViewController showCustomErrorAlertWithMessage:msg onButtonTouchUpBlock:^(CustomIOSAlertView *customAlertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[customAlertView tag]);
        //[weakErrorAlertView close];
        [customAlertView close];
    }];
}

#pragma mark - Custom Method for TimeOut
+ (void)showCustomTimeOutAlert: (NSString *)msg
                  protocolName: (NSString *)protocolName
                       albumId: (NSString *)albumId
                      userbook: (NSString *)userbook
                       eventId: (NSString *)eventId
                      postMode: (BOOL)postMode
{
    CustomIOSAlertView *alertTimeOutView = [[CustomIOSAlertView alloc] init];
    //[alertTimeOutView setContainerView: [self createTimeOutContainerView: msg]];
    [alertTimeOutView setContentViewWithMsg:msg contentBackgroundColor:[UIColor darkMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertTimeOutView.arrangeStyle = @"Horizontal";
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    alertTimeOutView.parentView = app.window;
    [alertTimeOutView setButtonTitles: [NSMutableArray arrayWithObjects: NSLocalizedString(@"TimeOut-CancelBtnTitle", @""), NSLocalizedString(@"TimeOut-OKBtnTitle", @""), nil]];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    [alertTimeOutView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor clearColor], [UIColor clearColor],nil]];
    [alertTimeOutView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstGrey], nil]];
    [alertTimeOutView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    //alertView.arrangeStyle = @"Vertical";
    
    __weak typeof(self) weakSelf = self;
    __weak CustomIOSAlertView *weakAlertTimeOutView = alertTimeOutView;
    [alertTimeOutView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertTimeOutView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertTimeOutView tag]);
        
        if (buttonIndex == 0) {
            [weakAlertTimeOutView close];
        } else {
            [weakAlertTimeOutView close];
            
            if ([protocolName isEqualToString: @"ToRetrievealbumpViewControlleralbumid"]) {
                [weakSelf ToRetrievealbumpViewControlleralbumid: albumId];
            } else if ([protocolName isEqualToString: @"ReadTestBookalbumid"]) {
                [weakSelf ReadTestBookalbumid: albumId
                                     userbook: userbook
                                      eventId: eventId
                                     postMode: postMode
                              fromEventPostVC: NO];
            }
        }
    }];
    [alertTimeOutView setUseMotionEffects: YES];
    [alertTimeOutView show];
}

+ (UIView *)createTimeOutContainerView: (NSString *)msg
{
    // TextView Setting
    UITextView *textView = [[UITextView alloc] initWithFrame: CGRectMake(10, 30, 280, 20)];
    textView.text = msg;
    textView.backgroundColor = [UIColor clearColor];
    textView.textColor = [UIColor whiteColor];
    textView.font = [UIFont systemFontOfSize: 16];
    textView.editable = NO;
    
    // Adjust textView frame size for the content
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [textView sizeThatFits: CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textView.frame;
    
    NSLog(@"newSize.height: %f", newSize.height);
    
    // Set the maximum value for newSize.height less than 400, otherwise, users can see the content by scrolling
    if (newSize.height > 300) {
        newSize.height = 300;
    }
    
    // Adjust textView frame size when the content height reach its maximum
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    textView.frame = newFrame;
    
    CGFloat textViewY = textView.frame.origin.y;
    NSLog(@"textViewY: %f", textViewY);
    
    CGFloat textViewHeight = textView.frame.size.height;
    NSLog(@"textViewHeight: %f", textViewHeight);
    NSLog(@"textViewY + textViewHeight: %f", textViewY + textViewHeight);
    
    
    // ImageView Setting
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(200, -8, 128, 128)];
    [imageView setImage:[UIImage imageNamed:@"icon_2_0_0_dialog_pinpin.png"]];
    
    CGFloat viewHeight;
    
    if ((textViewY + textViewHeight) > 96) {
        if ((textViewY + textViewHeight) > 450) {
            viewHeight = 450;
        } else {
            viewHeight = textViewY + textViewHeight;
        }
    } else {
        viewHeight = 96;
    }
    NSLog(@"demoHeight: %f", viewHeight);
    
    
    // ContentView Setting
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, viewHeight)];
    //contentView.backgroundColor = [UIColor firstPink];
    contentView.backgroundColor = [UIColor firstMain];
    
    // Set up corner radius for only upper right and upper left corner
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect: contentView.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(13.0, 13.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    maskLayer.frame = app.window.bounds;
    maskLayer.path  = maskPath.CGPath;
    contentView.layer.mask = maskLayer;
    
    // Add imageView and textView
    [contentView addSubview: imageView];
    [contentView addSubview: textView];
    
    NSLog(@"");
    NSLog(@"contentView: %@", NSStringFromCGRect(contentView.frame));
    NSLog(@"");
    
    return contentView;
}

// GAI Screen
+ (void)sendScreenTrackingWithScreenName:(NSString *)scrnName {
    if (scrnName && scrnName.length > 0) {
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        NSString *uid = [wTools getUserID];
        [tracker set:kGAIUserId value:uid];
        [tracker set:kGAIScreenName value:scrnName];
        [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    }
}
// GAI Event/Action
+ (void)sendActionTrackingWithCategoryName:(NSString *)categoryName action:(NSString *)action label:(NSString *)label value:( NSNumber * _Nullable )value {
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    NSString *uid = [wTools getUserID];
    [tracker set:kGAIUserId value:uid];
    
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:categoryName action:action label:label value:value] build]];
    
}

//  處理awssns
+(void)processAWSResponse:(NSString *)res {
    
    if (res != nil) {
        if (![res isEqualToString:timeOutErrorCode]) {
            NSDictionary *d = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [res dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableLeaves error: nil];
            //  setawssns is successfull
            if ([d[@"result"] intValue] == 1) {
                NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
                [userPrefs setObject:@"ok" forKey:@"awssns"];
            }
            
        }
        
    }
}

+(BOOL)isRegisterAWSNeeded {
    
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    if ([userPrefs objectForKey:@"awssns"]) {
        return false;
    }
    return true;
}


+(BOOL) checkAlbumId:(NSString *)albumId {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSArray *array = [defaults objectForKey: @"albumIdArray"];
    
    
    // Get the albumIdArray from Device
    if (array != nil) {
        
        NSMutableArray *albumIdArray  = [NSMutableArray arrayWithArray: array];
        
        if ([albumIdArray containsObject: albumId]) {
            return NO;
        } else {
            
            [albumIdArray addObject: albumId];
            
            return YES;
            
            [defaults setObject: albumIdArray forKey: @"albumIdArray"];
            [defaults synchronize];
        }
    } else {
        
        NSMutableArray *albumIdArray = [NSMutableArray new];
        [albumIdArray addObject: albumId];
        
        
        [defaults setObject: albumIdArray forKey: @"albumIdArray"];
        [defaults synchronize];
        
        return YES;
    }
}

@end
