//
//  CoCreatorListViewController.m
//  wPinpinbox
//
//  Created by Antelis on 2018/9/18.
//  Copyright © 2018 Angus. All rights reserved.
//

//  https://free.modao.cc/app/rsPJEqdqNcSYkdLfx7w0jFRFxlrKlaA#screen=s56D99857E51516181156570

#import "CoCreatorListViewController.h"
#import "AppDelegate.h"
#import "UIColor+Extensions.m"

#import "boxAPI.h"
#import "GlobalVars.h"
#import "CustomIOSAlertView.h"
#import "UIViewController+ErrorAlert.h"

#import <SDWebImage/UIImageView+WebCache.h>

@implementation CoCreatorCell
- (IBAction)inviteCreator:(id)sender {
    if (self.coDelegate && [self.coDelegate respondsToSelector:@selector(processInviteUserWithIndex:)]) {
        [self.coDelegate processInviteUserWithIndex:self.cindex];
    }
}
@end

@implementation CoAdminCell
- (IBAction)editAdmin:(id)sender {
    if (self.coDelegate && [self.coDelegate respondsToSelector:@selector(processDeleteUserWithIndex:)]) {
        [self.coDelegate processDeleteUserWithIndex:self.cindex];
    }
}
- (void)setViewerMode :(BOOL)edit {
    self.manageButton.layer.borderColor = [UIColor thirdGrey].CGColor;
    self.manageButton.layer.borderWidth = 1;
    self.manageButton.enabled = NO;
    [self.manageButton setBackgroundColor:[UIColor whiteColor]];
    [self.manageButton setTitleColor:[UIColor thirdGrey] forState:UIControlStateNormal];
    self.editButton.hidden = !edit;
}
- (void)setAdminMode:(BOOL)edit selfRank:(NSString *)selfRank userRank:(NSString *)userRank {
    self.manageButton.layer.borderColor = [UIColor thirdGrey].CGColor;
    self.manageButton.layer.borderWidth = 1;
    self.manageButton.enabled = ![userRank isEqualToString:@"admin"];
    if (self.manageButton.enabled) {
        [self.manageButton setBackgroundColor:[UIColor thirdGrey]];
        [self.manageButton setTitleColor:[UIColor firstGrey] forState:UIControlStateNormal];
    } else {
        [self.manageButton setBackgroundColor:[UIColor whiteColor]];
        [self.manageButton setTitleColor:[UIColor thirdGrey] forState:UIControlStateNormal];
    }
    self.editButton.hidden = NO;
    if ([selfRank isEqualToString:@"admin"])
        self.editButton.hidden = !edit;
    else {
        self.editButton.hidden = ![userRank isEqualToString:@"admin"];
    }
        
}
- (IBAction)manageAdmin:(id)sender {
    if (self.coDelegate && [self.coDelegate respondsToSelector:@selector(processChangeCoCreatorRankWithIndex:)]) {
        [self.coDelegate processChangeCoCreatorRankWithIndex:self.cindex];
    }
}
@end


@interface CoCreatorListViewController ()<UITextFieldDelegate>
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *searchViewWidth;
@property (nonatomic) NSMutableArray *coCreators;
@property (nonatomic) NSMutableArray *searchUsers;
@property (nonatomic,strong) NSString *albumId;
@property (nonatomic) NSString *curRank;
@end

@implementation CoCreatorListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _coCreators = [NSMutableArray array];
    _searchUsers = [NSMutableArray array];
}
- (BOOL)prefersStatusBarHidden {
    return NO;
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];    
    [self.navigationController.navigationBar setShadowImage: [UIImage imageNamed:@"navigationbarshadow"]];
}
- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    
    //UIBarButtonItem *litem = [[UIBarButtonItem alloc]initWithCustomView:self.backButton];
    //self.searchView.translatesAutoresizingMaskIntoConstraints = NO;
    UIBarButtonItem *l = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic200_arrow_left_darknav"] style:UIBarButtonItemStylePlain target:self action:@selector(onBackButton:)];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:self.searchView];
    UIBarButtonItem *r1 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic200_scancamera_darknav"] style:UIBarButtonItemStylePlain target:self action:@selector(onBackButton:)];
    r1.title = @"";
    l.title = @"";
    l.tintColor = [UIColor firstGrey];
    l.width = 44;
    r1.tintColor = [UIColor firstGrey];
    r1.width = 44;
    CGFloat w = self.view.bounds.size.width - 110;
    _searchViewWidth.constant = w;
    //item.width = w;
    
    //ic200_scancamera_dark
    //ic200_arrow_left_darknav
    [self.navigationItem setLeftBarButtonItems:@[l]];
    [self.navigationItem setRightBarButtonItems:@[r1,item]];
    
    //self.edgesForExtendedLayout = UIRectEdgeBottom;
    
    [self getCooperatorList];
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _creatorListView) {
        UICollectionReusableView *v = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"creatorHeader" forIndexPath:indexPath];
        
        return v;
    }
    
    return nil;
}
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    //  search result list
    if (collectionView == self.creatorListView) {
        if (indexPath.row < _searchUsers.count) {
            NSDictionary *user = _searchUsers[indexPath.row][@"user"];
            
            CoCreatorCell *ccell = (CoCreatorCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CoCreatorCell" forIndexPath:indexPath];
            if ([user[@"picture"] isEqual: [NSNull null]]) {
                ccell.avatar.image = [UIImage imageNamed: @"member_back_head.png"];
            } else {
                [ccell.avatar sd_setImageWithURL: [NSURL URLWithString: user[@"picture"]]
                                             placeholderImage: [UIImage imageNamed: @"member_back_head.png"]];
            }
            ccell.userName.text = user[@"name"];
            [ccell.inviteButton setTitle:@"邀請" forState:UIControlStateNormal];
            ccell.coDelegate = self;
            ccell.cindex = indexPath.row;
            return ccell;
        }
        
    } else if (collectionView == self.adminListView) { //  cooperator list
        if (indexPath.row < _coCreators.count) {
            NSDictionary *creator = _coCreators[indexPath.row];
            NSDictionary *user = creator[@"user"];
            NSString *uid = [user[@"user_id"] stringValue];
            CoAdminCell *ccell = (CoAdminCell *) [collectionView dequeueReusableCellWithReuseIdentifier:@"CoAdminCell" forIndexPath:indexPath];
            
            
            if ([user[@"picture"] isEqual: [NSNull null]]) {
                ccell.avatar.image = [UIImage imageNamed: @"member_back_head.png"];
            } else {
                [ccell.avatar sd_setImageWithURL: [NSURL URLWithString: user[@"picture"]]
                                placeholderImage: [UIImage imageNamed: @"member_back_head.png"]];
            }
            ccell.userName.text = user[@"name"];
            ccell.coDelegate = self;
            ccell.cindex = indexPath.row;
            NSString *c = creator[@"cooperation"][@"identity"];
            if ([CoCreatorListViewController isNonAdminRank:self.curRank]) {
                [ccell setViewerMode:[uid isEqualToString:[wTools getUserID]]];
            } else {
                [ccell setAdminMode:[uid isEqualToString:[wTools getUserID]] selfRank:self.curRank userRank:c];
            }
            
            [ccell.manageButton setTitle:[CoCreatorListViewController getRankName:c] forState:UIControlStateNormal];
            return ccell;
        }
    }
    
    return cell;
}
//  check if rank is editor or viewer
+ (BOOL) isNonAdminRank:(NSString *)rank {
    if ([rank isEqualToString:@"admin"] || [rank isEqualToString:@"approver"])
        return NO;
    
    return YES;
}
+ (NSString *)getRankName:(NSString *)rank {
    //identity (string, 身分, admin<管理者> / approver<副管理者> / editor<共用者> / viewer<瀏覽者>)
    if ([rank isEqualToString:@"admin"])
        return @"管理者";
    else if ([rank isEqualToString:@"approver"])
        return @"副管理者";
    else if ([rank isEqualToString:@"editor"])
        return @"共用者";

    return @"瀏覽者";
}
- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == _creatorListView)
        return _searchUsers.count;
    return _coCreators.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}
#pragma mark -
- (void)setAlbumId:(NSString *)aid {
    _albumId = aid;
}
- (IBAction)onBackButton:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav popViewControllerAnimated: YES];
    appDelegate.myNav.navigationBarHidden = YES;
}
- (void)findCurrentRank {
    for (NSDictionary *op in self.coCreators) {
        NSDictionary *u  = op[@"user"];
        if (u && ![u[@"user_id"] isKindOfClass:[NSNull class]]) {
            NSString *uid = [u[@"user_id"] stringValue];
            if ([uid isEqualToString:[wTools getUserID]]){
                self.curRank = op[@"cooperation"][@"identity"];
                return;
            }
        }
            
    }
}
#pragma mark - 
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSLog(@"shouldChangeCharactersInRange");
    [_searchUsers removeAllObjects];
    NSString *resultString = [textField.text stringByReplacingCharactersInRange: range
                                                                     withString: string];
    
    // refresh search user list
    
    if (resultString.length)
        [self searchUserByKeyword:resultString];
    else {
        [_searchUsers removeAllObjects];
        
        [_creatorListView reloadData];
    }
    
    _infoView.hidden = _searchUsers.count>0;
    return YES;
}
#pragma mark - API
//  load list of cooperators
- (void)getCooperatorList {
    
    __block typeof(_albumId) aid = _albumId;
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSMutableDictionary *data=[NSMutableDictionary new];
        [data setObject:aid forKey:@"type_id"];
        [data setObject:@"album" forKey:@"type"];
        NSString *response = [boxAPI getcooperationlist:[wTools getUserID] token:[wTools getUserToken] data:data];
        
//        NSMutableDictionary *qrDic = [NSMutableDictionary new];
//        [qrDic setObject: [NSNumber numberWithBool: YES] forKey: @"is_cooperation"];
//        [qrDic setObject: [NSNumber numberWithBool: NO] forKey: @"is_follow"];
//
//        NSLog(@"generate jSON data for getQRCode");
//        NSLog(@"qrDic: %@", qrDic);
//
//        NSData *jsonData = [NSJSONSerialization dataWithJSONObject: qrDic
//                                                           options: 0
//                                                             error: nil];
//        NSString *jsonStr = [[NSString alloc] initWithData: jsonData
//                                                  encoding: NSUTF8StringEncoding];
        
        //NSString *responseQRCode = [boxAPI getQRCode: [wTools getUserID] token: [wTools getUserToken] type: @"album" type_id: aid effect: @"execute" is: jsonStr];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (response != nil) {
                if ([response isEqualToString: timeOutErrorCode]) {
                    
                    [wself.view endEditing:YES];
                    
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                     protocolName: @"getCooperatorList"
                                          eventId: @""
                                             text: @""];
                } else {
                
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    //NSDictionary *dicQR = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [responseQRCode dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    //NSLog(@"response from getQRCode: %@", responseQRCode);
                    //NSLog(@"dicQR: %@", dicQR);
                    
                    [wself processCooperator:dic]; //dicQR:dicQR];
                }
            }
//            } else {
//                [wself.refreshControl endRefreshing];
//            }
            
            [wTools HideMBProgressHUD];
        });
    });
    
}
- (void)processCooperator:(NSDictionary *)result {
    
    int r = [result[@"result"] intValue];
    if (r  == 1) {
        NSArray *list = (NSArray *)result[@"data"];
        
        //  sort array by identity
        if (list)
            [self rearrangeCooperators:list];
        [self findCurrentRank];
        //  coCreatorCell button usage?
        [self.adminListView reloadData];
        if (self.searchUsers.count) {
            [self.creatorListView reloadData];
        }
    } else if (r == 0) {
        [self showCustomErrorAlert: result[@"message"]];
    } else {
        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
    }

}
//  sort creators by identity
- (void)rearrangeCooperators:(NSArray *)list {
    [self.coCreators removeAllObjects];
    NSMutableArray *admin = [NSMutableArray array];
    NSMutableArray *apr = [NSMutableArray array];
    NSMutableArray *editor = [NSMutableArray array];
    NSMutableArray *viewer = [NSMutableArray array];
    [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *d = (NSDictionary *)obj;
        NSDictionary *c = d[@"cooperation"];
        NSString *i = c[@"identity"];
        if ([i isEqualToString:@"admin"])
            [admin addObject:d];
        else if ([i isEqualToString:@"approver"])
            [apr addObject:d];
        else if ([i isEqualToString:@"editor"])
            [editor addObject:d];
        else
            [viewer addObject:d];
    }];
    
    [self.coCreators addObjectsFromArray:admin];
    [self.coCreators addObjectsFromArray:apr];
    [self.coCreators addObjectsFromArray:editor];
    [self.coCreators addObjectsFromArray:viewer];
    
}
//  search users
- (void)searchUserByKeyword:(NSString *)keyword {
    
    
    __block typeof(self) wself = self;
    NSString *string = keyword;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSString *response = @"";
        
        NSMutableDictionary *data = [NSMutableDictionary new];
        [data setObject: @"user" forKey: @"searchtype"];
        [data setObject: keyword forKey: @"searchkey"];
        [data setObject: @"0,32" forKey: @"limit"];
        
        response = [boxAPI search: [wTools getUserID]
                            token: [wTools getUserToken]
                             data: data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (response != nil) {
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    
                    [wself.view endEditing:YES];
                    
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                     protocolName: @"filterUserContentForSearchText"
                                          eventId: @""
                                             text: keyword];
                } else {
                
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if (![dic[@"result"] boolValue]) {
                        return ;
                    }
                    //判斷回傳是否一樣
                    if (![keyword isEqualToString:string]) {
                        return;
                    }
                    //判斷目前table和 搜尋結果是否相同
                    if (![data[@"searchtype"] isEqualToString: @"user"]) {
                        return;
                    }
                    
                    [wself processSearchUserResult:dic text:keyword];
                }
            }
        });
    });
}
- (void)processSearchUserResult:(NSDictionary *)result text:(NSString *)text {
    
    int r = [result[@"result"] intValue];
    if (r  == 1) {
        NSArray *users = (NSArray *)result[@"data"];
        //  filter id from cooperatorlist //
        //  invaite status?
        if (users)
            [self.searchUsers addObjectsFromArray:users];
        
//        if (userData.count == 0) {
//            if (!isNoInfoHorzViewCreate) {
//                [self addNoInfoViewOnHorizontalCollectionView: @"沒有符合關鍵字的創作人"];
//            }
//            noInfoHorzView.hidden = NO;
//        } else if (userData.count > 0) {
//            noInfoHorzView.hidden = YES;
//        }
        
        _infoView.hidden = users.count>0;
        [self.creatorListView reloadData];
        
    } else if (r == 0) {
        
        [self showCustomErrorAlert: result[@"message"]];
    } else {
        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
    }
    
}
//  generate QRCode

//  add cooperators
- (void)inviteUserWithUserId:(NSString *)uid albumId:(NSString *)albumId {
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *response=@"";
        NSMutableDictionary *data=[NSMutableDictionary new];
        [data setObject:uid forKey:@"user_id"];
        [data setObject:@"album" forKey:@"type"];
        [data setObject:albumId forKey:@"type_id"];
        
        
        response=[boxAPI addcooperation:[wTools getUserID] token:[wTools getUserToken] data:data];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //[wTools HideMBProgressHUD];
            if (response!=nil) {
                if ([response isEqualToString: timeOutErrorCode]) {
                    
                    //[wself.view endEditing:YES];
                    
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                     protocolName: @"inviteUserWithUserId"
                                          eventId: @""
                                             text: uid];
                } else {
                    NSLog(@"%@",respone);
                    NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    [wself processInsertCoopResult:dic userid:uid];
                }
            }
        });
    });
}
- (void)processInsertCoopResult:(NSDictionary *)result userid:(NSString *)userid {
    NSLog(@"%@",result);
    if (result) {
        int r = [result[@"result"] intValue];
        if (r == 1) {
            //  get cooperatorlist
            //  reload
            [self.coCreators removeAllObjects];
            [self getCooperatorList];

        } else {
            NSString *msg = result[@"message"];
            if (!msg || msg.length < 1)
                msg = @"邀請用戶失敗，請重試";
            [self showCustomErrorAlert:msg];
            
        }
        
    }
}
//  delete cooperators
#pragma mark - Show QRCode

#pragma mark - show alert
- (void)showCustomErrorAlert: (NSString *)msg {
    
    [UIViewController showCustomErrorAlertWithMessage:msg onButtonTouchUpBlock:^(CustomIOSAlertView * _Nullable customAlertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[customAlertView tag]);
        [customAlertView close];
    }];
}
- (void)showCustomTimeOutAlert: (NSString *)msg
                  protocolName: (NSString *)protocolName
                       eventId: (NSString *)eventId
                          text: (NSString *)text {
    
    CustomIOSAlertView *alertTimeOutView = [[CustomIOSAlertView alloc] init];
    
    [alertTimeOutView setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
    
    alertTimeOutView.arrangeStyle = @"Horizontal";
    
    alertTimeOutView.parentView = self.view;
    [alertTimeOutView setButtonTitles: [NSMutableArray arrayWithObjects: NSLocalizedString(@"TimeOut-CancelBtnTitle", @""), NSLocalizedString(@"TimeOut-OKBtnTitle", @""), nil]];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    [alertTimeOutView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor clearColor], [UIColor clearColor],nil]];
    [alertTimeOutView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstGrey], nil]];
    [alertTimeOutView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    
    [alertTimeOutView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertTimeOutView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertTimeOutView tag]);
        
        [alertTimeOutView close];
    }];
    [alertTimeOutView setUseMotionEffects: YES];
    [alertTimeOutView show];
}
#pragma mark - CoCreatorManageDelegate
- (void)processInviteUserWithIndex:(NSInteger)index {
    if (index < self.searchUsers.count) {
        NSDictionary *user = _searchUsers[index][@"user"];
        NSString *uid = user[@"user_id"];
        NSString *aid = self.albumId;
        [self inviteUserWithUserId:uid albumId:aid];
    }
}
- (void)processDeleteUserWithIndex:(NSInteger)index {
    
}
- (void)processChangeCoCreatorRankWithIndex:(NSInteger)index {
    
}
@end
