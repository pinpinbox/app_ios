// InAppPurchaseManager.h
#import <StoreKit/StoreKit.h>

#define kInAppPurchaseManagerProductsFetchedNotification @"kInAppPurchaseManagerProductsFetchedNotification"
#define kInAppPurchaseManagerTransactionFailedNotification @"kInAppPurchaseManagerTransactionFailedNotification"
#define kInAppPurchaseManagerTransactionSucceededNotification @"kInAppPurchaseManagerTransactionSucceededNotification"

@protocol inAppPurchaseDelegate <NSObject>

-(void)purchaseComplete:(NSString*)PID withDic:(NSDictionary*)dict appendString:(NSString*)str flag:(int)status;

-(void)purchaseFailed:(NSString*)info;

-(void)StoreInfoError:(NSString*)info;

//-(void)giveMeStoreList:(NSArray*)products; //商品列表 from apple

-(void)giveMeItemInfo:(NSMutableDictionary*)products; //商品資訊

@end



@interface InAppPurchaseManager : NSObject <SKProductsRequestDelegate,SKPaymentTransactionObserver, NSURLSessionDelegate, UIAlertViewDelegate>
{
    SKProduct *proUpgradeProduct;
    SKProductsRequest *productsRequest;
    // id <inAppPurchaseDelegate> delegate;
    
    
     // verifyCode
}

@property (assign) id delegate;
@property(nonatomic,strong)NSArray *priceid;    //商品id
@property (nonatomic, strong) SKPaymentTransaction *transaction;

+(InAppPurchaseManager*)getInstance;
+(void)releaseInstance;

// public methods
- (void)loadStore;
- (BOOL)canMakePurchases;
//購買
- (void)purchaseProUpgrade:(NSInteger)stage;
- (void)purchaseProUpgrade2:(NSString *)stage;
- (void)goodByeBoss;


//custom method
-(void)checkPurchasedItems;
-(void)clearInAppManager;


@end
