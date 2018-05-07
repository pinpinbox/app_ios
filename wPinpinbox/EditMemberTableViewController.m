//
//  EditMemberTableViewController.m
//  wPinpinbox
//
//  Created by David on 1/17/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "EditMemberTableViewController.h"
#import "AsyncImageView.h"
#import "PhotosViewController.h"
#import "EditPhoneViewController.h"

#import "wTools.h"
#import "boxAPI.h"
#import "NSString+emailValidation.h"

#define kYAxis 129
#define kGap 9
#define kRowHeight 70

@interface EditMemberTableViewController () <UITextViewDelegate, UITextFieldDelegate, PhotosViewDelegate>
{
    NSDictionary *myData;
    CGFloat firstRowHeight;
    UIImage *selectImage;
    int sexInt;
    
    UIDatePicker *datePicker;
    NSLocale *datelocale;
}

@property (weak, nonatomic) IBOutlet UIImageView *cameraImageView;
@property (weak, nonatomic) IBOutlet AsyncImageView *headShotImageView;
@property (weak, nonatomic) IBOutlet UITextView *introTextView;
@property (weak, nonatomic) IBOutlet UITextField *nickNameField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@property (weak, nonatomic) IBOutlet UIButton *maleBtn;
@property (weak, nonatomic) IBOutlet UIButton *femaleBtn;

@property (weak, nonatomic) IBOutlet UITextField *birthdayTextField;

@end

@implementation EditMemberTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self fieldDataSetUp];
    
    [self.tableView reloadData];
}

- (void)fieldDataSetUp
{
    // Get the profile data
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    myData = [userPrefs objectForKey: @"profile"];
    
    // Size UIImage
    /*
    UIImage *originalImage = [UIImage imageNamed: @"camera.png"];
    CGSize destinationSize = CGSizeMake(18, 18);
    UIGraphicsBeginImageContext(destinationSize);
    [originalImage drawInRect: CGRectMake(0, 0, destinationSize.width, destinationSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.cameraImageView.image = newImage;
     */
    
    //UIImage *cameraImage = [UIImage imageNamed: @"camera.png"];
    
    //self.cameraImageView.image = cameraImage;
    //self.cameraImageView.bounds = CGRectInset(self.cameraImageView.frame, 10.0f, 10.0f);
    //[self.cameraImageView sizeThatFits: CGSizeMake(1, 1)];
    
    
    [[self.cameraImageView layer] setMasksToBounds: YES];
    [[self.cameraImageView layer] setCornerRadius: self.cameraImageView.bounds.size.height / 2];
    
    // Let UIImageView be Clickable
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(tapDetected)];
    singleTap.numberOfTapsRequired = 1;
    [self.cameraImageView setUserInteractionEnabled: YES];
    [self.cameraImageView addGestureRecognizer: singleTap];
    
    // Check whether profilePic is null or not
    NSString *profilePic = myData[@"profilepic"];
    NSLog(@"profilePic: %@", profilePic);
    
    if (![profilePic isKindOfClass: [NSNull class]]) {
        NSLog(@"profilePic is not NSNull class");
        
        if (![profilePic isEqualToString: @""]) {
            NSLog(@"profilePic is not equal to string empty");
            //[[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: self.headShotImageView];
            self.headShotImageView.imageURL = [NSURL URLWithString: myData[@"profilepic"]];
        }
    } else {
        NSLog(@"profilePic is null");
        //[[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: self.headShotImageView];
        self.headShotImageView.image = [UIImage imageNamed: @"member_back_head.png"];
    }
    
    [[self.headShotImageView layer] setMasksToBounds: YES];
    [[self.headShotImageView layer] setCornerRadius: self.headShotImageView.bounds.size.height / 2];
    
    
    self.nickNameField.text = myData[@"nickname"];
    
    
    // TextView Setting
    self.introTextView.text = myData[@"selfdescription"];
    
    CGFloat fixedWidth = self.introTextView.frame.size.width;
    CGFloat originalHeight = self.introTextView.frame.size.height;
    
    NSLog(@"originalHeight: %f", originalHeight);
    
    CGSize newSize = [self.introTextView sizeThatFits: CGSizeMake(fixedWidth, MAXFLOAT)];
    NSLog(@"newSize.height: %f", newSize.height);
    
    CGRect newFrame = self.introTextView.frame;
    newFrame.size = CGSizeMake(fmax(newSize.width, fixedWidth), newSize.height);
    NSLog(@"newFrame.height: %f", newFrame.size.height);
    
    self.introTextView.frame = newFrame;
    NSLog(@"self.introTextView.frame.size.height: %f", self.introTextView.frame.size.height);
    
    self.introTextView.scrollEnabled = NO;
    
    firstRowHeight = kYAxis + self.introTextView.frame.size.height + kGap;
    
    NSLog(@"firstRowHeight: %f", firstRowHeight);
    
    
    // Email TextField
    self.emailTextField.text = myData[@"email"];
    
    // PhoneNumber TextField
    self.phoneNumberTextField.text = myData[@"cellphone"];
    
    // Sex Gender
    sexInt = [myData[@"gender"] intValue];
    NSLog(@"sexInt: %d", sexInt);
    
    if (sexInt == 1) {
        [self.maleBtn setTitleColor: [UIColor colorWithRed: 32.0/255.0 green: 191.0/255.0 blue: 193.0/255.0 alpha: 1.0] forState: UIControlStateNormal];
        [self.femaleBtn setTitleColor: [UIColor lightGrayColor] forState: UIControlStateNormal];
    } else if (sexInt == 0) {
        [self.maleBtn setTitleColor: [UIColor lightGrayColor] forState: UIControlStateNormal];
        [self.femaleBtn setTitleColor: [UIColor colorWithRed: 32.0/255.0 green: 191.0/255.0 blue: 193.0/255.0 alpha: 1.0] forState: UIControlStateNormal];
    }
    
    
    // Birthday TextField
    self.birthdayTextField.text = myData[@"birthday"];
    
    datePicker = [[UIDatePicker alloc] init];
    datelocale = [[NSLocale alloc] initWithLocaleIdentifier: @"zh_TW"];
    datePicker.locale = datelocale;
    datePicker.timeZone = [NSTimeZone timeZoneWithName: @"GMT"];
    datePicker.datePickerMode = UIDatePickerModeDate;
    
    self.birthdayTextField.inputView = datePicker;
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame: CGRectMake(0, 0, 320, 44)];
    //UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone target: self action: @selector(donePicker)];
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle: @"確定" style: UIBarButtonItemStylePlain target: self action: @selector(donePicker)];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil];
    
    //UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel target: self action: @selector(cancelPicker)];
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle: @"取消" style: UIBarButtonItemStylePlain target: self action: @selector(cancelPicker)];
    
    toolBar.items = [NSArray arrayWithObjects: left, flexibleSpace, right, nil];
    
    self.birthdayTextField.inputAccessoryView = toolBar;
}

- (void)donePicker
{
    if ([self.view endEditing: NO]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate: @"yyyy-MM-dd" options: 0 locale: datelocale];
        [formatter setDateFormat: dateFormat];
        [formatter setLocale: datelocale];
        
        self.birthdayTextField.text = [NSString stringWithFormat: @"%@", [formatter stringFromDate: datePicker.date]];
    }
}

- (void)cancelPicker
{
    [self.view endEditing: YES];
}

#pragma mark - IBAction

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated: YES];
}

- (IBAction)malePressed:(id)sender {
    [self.maleBtn setTitleColor: [UIColor colorWithRed: 32.0/255.0 green: 191.0/255.0 blue: 193.0/255.0 alpha: 1.0] forState: UIControlStateNormal];
    [self.femaleBtn setTitleColor: [UIColor lightGrayColor] forState: UIControlStateNormal];
    
    sexInt = 1;
}

- (IBAction)femalePressed:(id)sender {
    [self.maleBtn setTitleColor: [UIColor lightGrayColor] forState: UIControlStateNormal];
    [self.femaleBtn setTitleColor: [UIColor colorWithRed: 32.0/255.0 green: 191.0/255.0 blue: 193.0/255.0 alpha: 1.0] forState: UIControlStateNormal];
    
    sexInt = 0;
}

- (IBAction)saveBtnPressed:(id)sender {
    NSLog(@"saveBtnPressed");
    
    NSString *msg = @"";
    
    if ([self.emailTextField.text isEqualToString: @""]) {
        msg = [msg stringByAppendingString: NSLocalizedString(@"GeneralText-email", @"")];
        msg = [msg stringByAppendingString: @"\n"];
    } else {
        // If Email Field is invalid then message got data
        if (![self.emailTextField.text isEmailValid]) {
            NSLog(@"信箱格式不對");
            //msg = NSLocalizedString(@"RegText-wrongEmail", @"");
            msg = [msg stringByAppendingString: NSLocalizedString(@"RegText-wrongEmail", @"")];
            msg = [msg stringByAppendingString: @"\n"];
        }
    }
    if ([self.nickNameField.text isEqualToString: @""]) {
        //msg = NSLocalizedString(@"GeneralText-nickName", @"");
        msg = [msg stringByAppendingString: NSLocalizedString(@"GeneralText-nickName", @"")];
        msg = [msg stringByAppendingString: @"\n"];
    }
    
    if (![msg isEqualToString: @""]) {
        Remind *rv = [[Remind alloc] initWithFrame: self.view.bounds];
        [rv addtitletext: [NSString stringWithFormat: @"資料輸入不完整：\n %@", msg]];
        [rv addBackTouch];
        [rv showView: self.view];
        return;
    }
    
    NSMutableDictionary *data = [NSMutableDictionary new];
    [data setObject: self.nickNameField.text forKey: @"nickname"];
    [data setObject: [NSString stringWithFormat: @"%d", sexInt] forKey: @"gender"];
    [data setObject: self.birthdayTextField.text forKey: @"birthday"];
    [data setObject: self.introTextView.text forKey: @"selfdescription"];
    [data setObject: self.emailTextField.text forKey: @"email"];
    
    [wTools ShowMBProgressHUD];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = [boxAPI updateprofile: [wTools getUserID] token: [wTools getUserToken] data: data];
        
        NSLog(@"user id: %@", [wTools getUserID]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                
                if ([dic[@"result"] boolValue]) {
                    // If headshot didn't change
                    if (selectImage == nil) {
                        NSLog(@"update 1");
                        
                        [self.navigationController popViewControllerAnimated:YES];
                        
                        
                        // Check whether getting edit profile point or not
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        NSString *editProfile = [defaults objectForKey: @"editProfile"];
                        NSLog(@"Check whether getting first time edit point or not");
                        NSLog(@"editProfile: %@", editProfile);
                        
                        if ([editProfile isEqualToString: @"ModifiedAlready"]) {
                            NSLog(@"Get the First Time Eidt Profile Point Already");
                        } else {
                            NSLog(@"show alert point view");
                            editProfile = @"FirstTimeModified";
                            [defaults setObject: editProfile forKey: @"editProfile"];
                            [defaults synchronize];
                        }
                    } else {
                        
                        // If headshot did change
                        NSLog(@"update 2");
                        
                        [wTools ShowMBProgressHUD];
                        UIImage *image=[wTools scaleImage: selectImage toScale:0.5];
                        
                        NSMutableDictionary *dc=[NSMutableDictionary new];
                        [dc setObject:[wTools getUserToken] forKey:@"token"];
                        [dc setObject:[wTools getUserID] forKey:@"id"];
                        
                        boxAPI *box=[[boxAPI alloc]init];
                        [box boxIMGAPI:dc URL:@"/updateprofilepic" image:image done:^(NSDictionary *responseData) {
                            
                            [wTools HideMBProgressHUD];
                            
                            NSInteger status = [[responseData objectForKey:@"status"] integerValue];
                            
                            if (status < 0) {
                                NSLog(@"画像のUploadに失敗");
                                return;
                            }
                            
                            //成功
                            NSLog(@"wusuccess %@", responseData);
                            [self.navigationController popViewControllerAnimated:YES];
                            
                            
                            // Check whether getting edit profile point or not
                            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                            NSString *editProfile = [defaults objectForKey: @"editProfile"];
                            NSLog(@"Check whether getting first time edit point or not");
                            NSLog(@"editProfile: %@", editProfile);
                            
                            if ([editProfile isEqualToString: @"ModifiedAlready"]) {
                                NSLog(@"Get the First Time Eidt Profile Point Already");
                            } else {
                                NSLog(@"show alert point view");
                                editProfile = @"FirstTimeModified";
                                [defaults setObject: editProfile forKey: @"editProfile"];
                                [defaults synchronize];
                            }
                            
                        } fail:^(NSInteger status) {
                            [wTools HideMBProgressHUD];
                            NSLog(@"画像のUploadに失敗");
                        }];
                    }
                } else {
                    NSLog(@"失敗：%@",dic[@"message"]);
                    Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
                    [rv addtitletext:dic[@"message"]];
                    [rv addBackTouch];
                    [rv showView:self.view];
                }
            }
        });
    });
}


#pragma mark -

- (void)tapDetected
{
    NSLog(@"tapDetected");
    PhotosViewController *pVC = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"PhotosViewController2"];
    pVC.selectrow = 1;
    pVC.phototype = @"0";
    pVC.delegate = self;
    [self.navigationController pushViewController: pVC animated: YES];
}

#pragma mark - PhotoViewsController Delegate Method
- (void)imageCropViewController:(PhotosViewController *)controller Image:(UIImage *)Image
{
    selectImage = Image;
    self.headShotImageView.image = selectImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return firstRowHeight;
    } else {
        return kRowHeight;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 3) {
        [self performSegueWithIdentifier: @"showEditPhoneViewController" sender: self];
    }
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)performSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString: @"showEditPhoneViewController"]) {
        EditPhoneViewController *edPV = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"EditPhoneViewController"];
        edPV.editview = self;
        edPV.cellphoen = self.phoneNumberTextField.text;
        NSLog(@"edPV.cellPhone: %@", edPV.cellphoen);
        edPV.email = self.emailTextField.text;
        [self.navigationController pushViewController: edPV animated: YES];
    }
}

#pragma mark UITextViewDelegate Methods
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString: @"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - UITextFieldDelegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
