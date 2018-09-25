//
//  InAppPurchaseManager.m
//  bigNature
//
//  Created by James on 12/2/28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "InAppPurchaseManager.h"
#import "wTools.h"
#import "Remind.h"
#import "AppDelegate.h"
#import "CustomIOSAlertView.h"
#import "UIColor+Extensions.h"

#import "UIViewController+ErrorAlert.h"

#define kIAP_AppleSandbox @"https://sandbox.itunes.apple.com/verifyReceipt"
#define kIAP_AppleStoreVerify @"https://buy.itunes.apple.com/verfyReceipt"
static InAppPurchaseManager *instance =nil;

@implementation InAppPurchaseManager
@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}
+(void)releaseInstance
{
    //[instance release];
    instance = nil;
}
+(InAppPurchaseManager*)getInstance
{
    if( instance == nil )
    {
        instance = [[InAppPurchaseManager alloc] init];
    }
    return instance;
}


// InAppPurchaseManager.m
- (void)requestProUpgradeProductData //檢查並取得以下商品apple資訊
{
    NSLog(@"requestProUpgradeProductData");
    
    //[[WTools getInstance]playMBProgress:NSLocalizedString(@"StoreMsg_1", @"讀取商品列表")];
    
    [wTools ShowMBProgressHUD];
    NSSet *productIdentifiers = [NSSet setWithArray:self.priceid];
    
    //    NSSet *productIdentifiers = [NSSet setWithObjects:
    //                                 @"com.test.item1", nil];
    
    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
    
    // we will release the request object in the delegate callback
}

#pragma mark -
#pragma mark SKProductsRequestDelegate methods

//收到的產品訊息
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"----------- DidReceive Products info --------------");
    
    NSArray *products = response.products;
    proUpgradeProduct = [products count] == 1 ? [products firstObject] : nil;
    
    //取得來自Apple的商品Info
    NSMutableDictionary *proInfoDic = [NSMutableDictionary new];
    
    if (proUpgradeProduct) //購買服務處理
    {
        NSLog(@"商品 ID:%@",response.invalidProductIdentifiers);
        NSLog(@"商品名稱: %@" , proUpgradeProduct.localizedTitle);
        NSLog(@"商品說明: %@" , proUpgradeProduct.localizedDescription);
        NSLog(@"價格: %@" , proUpgradeProduct.price);
        
        // 這邊就必須把商品列出來 並設定可以購買的按鈕 依照自己的需求設計UI
        
        //製作訂單需求 queue..
        SKPayment *payment = [SKPayment paymentWithProduct:proUpgradeProduct];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        
    }
    else //取得商品列表處理
    {
        
        NSMutableArray *tpArray = [[NSMutableArray alloc] init];
        for (SKProduct *item in products)
        {
            
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
            [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            [numberFormatter setLocale:item.priceLocale];
            NSString *Price = [numberFormatter stringFromNumber:item.price];
            
            NSLog(@"商品名稱:%@ <售價:%@> (ID:%@)" ,Price,item.localizedTitle, item.productIdentifier);
            
            [proInfoDic setObject:Price forKey: item.productIdentifier];
            NSLog(@"商品說明: %@" , item.localizedDescription);
            if (item.localizedDescription==nil) {
                [tpArray addObject:@""];
            }else{
                [tpArray addObject:item.localizedTitle];
            }
        }
        
        [self showLoading:NO withTitle:@"讀取商品列表"];
        //[delegate giveMeStoreList:[[NSArray alloc] initWithArray:tpArray]];
        [delegate giveMeItemInfo:proInfoDic];
    }
    
    if ([response.invalidProductIdentifiers count]>0)
    {
        for (NSString *invalidProductId in response.invalidProductIdentifiers)
        {
            NSLog(@"Invalid product id:%@" , invalidProductId);
        }
        [self showLoading:NO withTitle:@"讀取商品列表"];
        
        
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        Remind *rv=[[Remind alloc]initWithFrame:app.window.bounds];
        [rv addtitletext:@"查無資料，請重新嘗試"];
        [rv addBackTouch];
        [rv showView:app.window];
        
        //[WTools showAlertTile:wNoNet3 Message:nil ButtonTitle:wDone];
    }
    
    // finally release the reqest we alloc/init’ed in requestProUpgradeProductData
    [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerProductsFetchedNotification object:self userInfo:nil];
}

#pragma mark - LoadingTool
-(void)showLoading:(BOOL)isNeed withTitle:(NSString*)loadingStr;
{
    if (isNeed)
    {
        [wTools ShowMBProgressHUD];
    }
    else
    {
        [wTools HideMBProgressHUD];
    }
    
}

#pragma mark -
#pragma mark Public methods

//
// call this method once on startup
//
- (void)loadStore
{
    //[self showLoading:YES];
    // restarts any purchases if they were interrupted last time the app was open
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    // 取得目標商品 Apple端資訊
    // get the product description (defined in early sections)
    [self requestProUpgradeProductData];
}

- (void)goodByeBoss
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    productsRequest.delegate = nil; // <----- Solution
}

//
// call this before making a purchase
//
- (BOOL)canMakePurchases
{
    return [SKPaymentQueue canMakePayments];
}

//
// kick off the upgrade transaction
//
- (void)purchaseProUpgrade:(NSInteger)stage //購買
{
    [self showLoading:YES withTitle:@"與伺服器連結"];
    NSSet *productIdentifiers;
    
    productIdentifiers = [NSSet setWithObject:@"pinpinboxtest30"];
    
    
    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self; // your wrapper for IAP or AppDelegate or anything
    [productsRequest start];
    
}
- (void)purchaseProUpgrade2:(NSString *)stage //購買
{
    [self showLoading:YES withTitle:@"與伺服器連結"];
    NSSet *productIdentifiers=[NSSet setWithObject:stage];
    
    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self; // your wrapper for IAP or AppDelegate or anything
    [productsRequest start];
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSMutableArray *purchasedItemIDs = [[NSMutableArray alloc] init];
    
    NSLog(@"received restored transactions: %lu", (unsigned long)queue.transactions.count);
    
    for (SKPaymentTransaction *transaction in queue.transactions)
    {
        NSString *productID = transaction.payment.productIdentifier;
        [purchasedItemIDs addObject:productID];
    }
    
    NSLog(@"purchasedItemIDs:%@",purchasedItemIDs);
}



#pragma mark -
#pragma mark Purchase helpers

//
// saves a record of the transaction by storing the receipt to disk
//
- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"recordTransaction:%@",transaction.payment.productIdentifier);
    self.transaction = transaction;
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        
        // iOS 6.1 or earlier.
        
    } else {
        
        // iOS 7 or later.
        
        NSURL *receiptFileURL = nil;
        
        NSBundle *bundle = [NSBundle mainBundle];
        
        if ([bundle respondsToSelector:@selector(appStoreReceiptURL)]) {
            // Get the transaction receipt file path location in the app bundle.
            
            receiptFileURL = [bundle appStoreReceiptURL];
            
            // Read in the contents of the transaction file.
            
            
            NSData *receipt = [NSData dataWithContentsOfURL:receiptFileURL];
            // verifies receipt with Apple
            
            NSError *jsonError = nil;
            NSString *receiptBase64 = [receipt base64EncodedStringWithOptions:0];
            //NSLog(@"Receipt Base64: %@",receiptBase64);
            verifyJsonData=nil;
            verifyJsonData = [NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                      receiptBase64,
                                                                      @"receipt-data",
                                                                      @"cfaa16887b8e44b7b6f05e9c7b86a17e",
                                                                      @"password",
                                                                      nil]
                                                             options:NSJSONWritingPrettyPrinted
                                                               error:&jsonError
                              ];
            
            //NSLog(@"送出驗證的資料為 jsonData::%@",verifyJsonData);
            
            //NSError * error=nil;
            //            NSDictionary * parsedData = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
            //            NSLog(@"parsedData::%@",parsedData);
            //
            //            NSLog(@"JSON: %@",[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
            // URL for sandbox receipt validation; replace "sandbox" with "buy" in production or you will receive
            // error codes 21006 or 21007
            NSURL *requestURL = [NSURL URLWithString:kIAP_AppleSandbox];
            
            NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:requestURL];
            [req setHTTPMethod:@"POST"];
            [req setHTTPBody:verifyJsonData];
            [req setTimeoutInterval: 8];
            
            NSURLSession *session = [NSURLSession sharedSession];
            __block typeof(self) weakself = self;
            NSURLSessionTask *task = [session dataTaskWithRequest: req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                
                if (data.length > 0 && error == nil) {                    
                    NSLog(@"驗證程序...");
                    
                    NSDictionary *logDict =(NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                    
                    //  [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] mutableObjectFromJSONString];
                    NSLog(@"收到資料 didReceiveData:%@", logDict);
                    
                    id status = [logDict objectForKey:@"status"];
                    int verifyReceiptStatus = (int)[status integerValue];
                    
                    if ((verifyReceiptStatus==0) && ([weakself->verifyJsonData length] != 0)) //status = 0 正常 and 有驗證碼
                    {
                        NSString* verifyCode = [[NSString alloc] initWithData:weakself->verifyJsonData encoding:NSUTF8StringEncoding];
                        [weakself.delegate purchaseComplete:weakself->productStr withDic:logDict appendString:verifyCode flag:0];
                    }
                    else //問題兒童 顯示購買異常
                    {
                        NSString* verifyCode = [[NSString alloc] initWithData:weakself->verifyJsonData encoding:NSUTF8StringEncoding];
                        [weakself->delegate purchaseComplete:weakself->productStr withDic:logDict appendString:verifyCode flag:1];
                    }
                    
                    switch([(NSHTTPURLResponse *)response statusCode]) {
                        case 200:
                        case 206:
                            break;
                        case 304:
                            break;
                        case 400:
                            break;
                        case 404:
                            break;
                        case 416:
                            break;
                        case 403:
                            break;
                        case 401:
                        case 500:
                            break;
                        default:
                            break;
                    }
                    
                } else if (data.length == 0 && error == nil) {
                    NSLog(@"Nothing was downloaded");
                } else if (error != nil) {
                    NSLog(@"Error = %@", error);
                    NSLog(@"error.userInfo: %@", error.userInfo);
                    NSLog(@"error.localizedDescription: %@", error.localizedDescription);
                    NSLog(@"error code: %@", [NSString stringWithFormat: @"%d", (int)error.code]);
                }
            }];
            
            [task resume];
            
        } else {
            
            // Fall back to deprecated transaction receipt,
            
            // which is still available in iOS 7.
            
            // Use SKPaymentTransaction's transactionReceipt.
        }
    }
}

//
// enable pro features
// Make tweaks to match the game...
//
- (void)provideContent:(NSString *)productId
{
    //NSLog(@"provideContent ?? 幹嘛呢？");
    
    productStr = productId;
    
    //    if ([productId isEqualToString:kIAP_ProductId099])
    //    {
    //        [self buyAndSetRecord:99];
    //        [delegate purchaseComplete:kIAP_ProductId099];
    //    }
    //    else if ([productId isEqualToString:kIAP_ProductId199])
    //    {
    //        [self buyAndSetRecord:199];
    //        [delegate purchaseComplete:kIAP_ProductId199];
    //    }
    //    else if ([productId isEqualToString:kIAP_ProductId299])
    //    {
    //        [self buyAndSetRecord:299];
    //        [delegate purchaseComplete:kIAP_ProductId299];
    //    }
    //    else if ([productId isEqualToString:kIAP_ProductId399])
    //    {
    //        [self buyAndSetRecord:399];
    //        [delegate purchaseComplete:kIAP_ProductId399];
    //    }
}

//
// removes the transaction from the queue and posts a notification with the transaction result
//
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
    NSLog(@"finishTransaction");
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
    
    NSLog(@"wasSuccessful: %d", wasSuccessful);
    
    if (wasSuccessful)
    {
        NSLog(@"wasSuccessful");
        // send out a notification that we’ve finished the transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionSucceededNotification object:self userInfo:userInfo];
    }
    else
    {
        NSLog(@"was not Successful");
        // send out a notification for the failed transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionFailedNotification object:self userInfo:userInfo];
    }
}

//
// called when the transaction was successful
//
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    
    NSString *product = transaction.payment.productIdentifier;
    
    NSLog(@" 交易成功 > %@",product);
    
    [self recordTransaction:transaction]; //本機 記錄購買資訊
    [self provideContent:transaction.payment.productIdentifier]; //可進行資料內容處理或下載
    [self finishTransaction:transaction wasSuccessful:YES]; //代理事件告知完成
}

//
// called when a transaction has been restored and and successfully completed
//
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"交易恢复处理成功");
    [self recordTransaction:transaction.originalTransaction]; //本機 記錄購買資訊
    [self provideContent:transaction.originalTransaction.payment.productIdentifier]; //可進行資料內容處理或下載
    [self finishTransaction:transaction wasSuccessful:YES]; //代理事件告知完成
}

//
// called when a transaction has failed
//
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"failedTransaction");
    
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // error!
        [self finishTransaction:transaction wasSuccessful:NO];
        
        NSLog(@" 是 failedTransaction!!!!");
        
        [delegate purchaseFailed:NSLocalizedString(@"StoreMsg_4", @"購買發生錯誤，請稍後再試")];
        [self showLoading:NO withTitle:NSLocalizedString(@"StoreMsg_4", @"購買發生錯誤，請稍後再試")];
    }
    else
    {
        [delegate purchaseFailed:NSLocalizedString(@"StoreMsg_3", @"購買已取消")];
        [self showLoading:NO withTitle:NSLocalizedString(@"StoreMsg_3", @"購買已取消")];
        // this is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

#pragma mark -
#pragma mark SKPaymentTransactionObserver methods

//
// called when the transaction status is updated
//
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    NSLog(@"updatedTransactions");
    
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                
                [self completeTransaction:transaction];//完成交易
                break;
            case SKPaymentTransactionStateFailed: // You must call finishTransaction here too!
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored: //已经购买过该商品 // ...Re-unlock content...
                [self restoreTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchasing: //商品添加进列表 // Maybe show a progress bar?
                NSLog(@"商品被加入列表中 ...");
                break;
            default:
                break;
        }
    }
}


#pragma mark -
#pragma mark GamePlay, buy the set
-(void)buyAndSetRecord:(NSInteger)setnum
{
    NSLog(@"buyAndSetRecord");
    
    NSArray* record = [[NSUserDefaults standardUserDefaults] arrayForKey:@"WineNote_purchaseRecord"];
    
    NSMutableArray* newArray = [NSMutableArray arrayWithArray:record];
    
    switch (setnum)
    {
        case 99:
            [newArray addObject:@"pinpinboxtest30"];
            break;
        case 199:
            [newArray addObject:@"pinpinboxtest60"];
            break;
            
            break;
        default:
            break;
    }
    
    NSArray* changed = [NSArray arrayWithArray:newArray];
    [[NSUserDefaults standardUserDefaults] setObject:changed forKey:@"WineNote_purchaseRecord"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

#pragma mark - custom method
- (void) checkPurchasedItems
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}
-(void)clearInAppManager{
    NSLog(@"clearInAppManager");
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

// 獲得商品列表失敗
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
//    UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:@"Alert" message:[error localizedDescription]  delegate:nil cancelButtonTitle:NSLocalizedString(@"Close",nil)  otherButtonTitles:nil];
//    [alerView show];
    [UIViewController showCustomErrorAlertWithMessage:[error localizedDescription]   onButtonTouchUpBlock:^(CustomIOSAlertView * _Nonnull customAlertView, int buttonIndex) {
        [customAlertView close];
    }];
}

-(void)StoreInfoError:(NSString*)info
{
    [delegate StoreInfoError:@"查無商品資訊"];
}

@end
