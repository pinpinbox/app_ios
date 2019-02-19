//
//  URLAddViewController.m
//  wPinpinbox
//
//  Created by Antelis on 2018/11/19.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "URLAddViewController.h"

#import "UIView+Toast.h"
#import "UIColor+Extensions.h"
#import "LabelAttributeStyle.h"
#import "wTools.h"

@interface  URLDataCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *linkNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *websiteLabel;
@property (nonatomic) IBOutlet LeftPaddingTextfield *descTextField;
@property (nonatomic) IBOutlet LeftPaddingTextfield *urlTextField;
@end

@implementation URLDataCell
- (void)awakeFromNib {
    [super awakeFromNib];
    if ([wTools objectExists: self.linkNameLabel]) {
        [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: self.linkNameLabel content: self.linkNameLabel.text];
    }
    if ([wTools objectExists: self.websiteLabel]) {
        [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: self.websiteLabel content: self.websiteLabel.text];
    }
    [self addTextViewAccessoryView:_descTextField];
    [self addTextViewAccessoryView:_urlTextField];
}
- (void)dismissCurKeyboard {
    if (_descTextField.isFirstResponder)
        [_descTextField resignFirstResponder];
    else if (_urlTextField.isFirstResponder)
        [_urlTextField resignFirstResponder];
    
}
- (void)addTextViewAccessoryView:(UITextField *)textfield {
    UIToolbar *keybardBar = [[UIToolbar alloc] init];
    [keybardBar sizeToFit];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *dimiss = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissCurKeyboard)];
    
    keybardBar.items = @[space, dimiss];
    
    textfield.inputAccessoryView = keybardBar;
    
}
@end


@interface URLAddViewController ()<UITextFieldDelegate, UITableViewDelegate,UITableViewDataSource>
@property (nonatomic) IBOutlet UITableView *urlList;
@property (nonatomic) NSMutableArray *urldata;
@property (nonatomic) BOOL hasPreviousData;
@end



@implementation URLAddViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.hasPreviousData = NO;
    self.urldata = [NSMutableArray array];
    
    if ([wTools objectExists: self.saveBtn]) {
        [LabelAttributeStyle changeGapStringAndLineSpacingCenterAlignment: self.saveBtn.titleLabel content: self.saveBtn.titleLabel.text];
    }    
}

- (void)loadURLs:(NSArray *)urls {
    
    if (urls && urls.count) {
        [self.urldata setArray:urls];
        self.hasPreviousData = YES;
    }
    if (!urls || [urls count] < 2) {
        for (int i = (int)urls.count; i < 2; i++) {
            [self.urldata addObject:[NSMutableDictionary dictionary]];
        }
        
    }
    
    [self.urlList reloadData];
}
- (IBAction)submitURLs:(id)sender {
    __block NSArray *urls = [self getURLArray];
    if (self.urlDelegate && urls && urls.count >= 0) {
        __block typeof(self) wself = self;
        [self removeKeyboardNotification];
        [self dismissViewControllerAnimated:YES completion:^{
           [wself.urlDelegate didSetURLs:urls];
        }];
        
    } else if (!urls){
        if (self.hasPreviousData ) {
            __block typeof(self) wself = self;
            [self removeKeyboardNotification];
            [self dismissViewControllerAnimated:YES completion:^{
                [wself.urlDelegate didSetURLs:nil];
            }];
        } else {
            [self showErrorToastWithMessage:@"請至少填上一組連結"];
        }
    } else {
        [self cancelAndDismiss];
    }
    
}
- (void)showErrorToastWithMessage:(NSString *)message {
    CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
    style.messageColor = [UIColor whiteColor];
    style.backgroundColor = [UIColor thirdPink];
    
    [self.view makeToast: message
                 duration: 2.0
                 position: CSToastPositionBottom
                    style: style];
}
- (NSDictionary *)getURLParam:(NSString *)u desc:(NSString *)desc {
    if (u.length > 1) {
        NSString *uu = [u lowercaseString];
        
        if (![uu hasPrefix:@"https"] || ![uu hasPrefix:@"http"]) {
            u = [NSString stringWithFormat:@"https://%@",u];
        }
        u = [u stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        if (desc && desc.length > 0) {
            return @{@"url":u, @"text":desc};
        } else {
            return @{@"url":u};
        }
    }
    return nil;
}
- (NSArray *)getURLArray {

    NSMutableArray *ar = [NSMutableArray array];
    for (NSDictionary *data in self.urldata) {
        NSDictionary *de1 = [self getURLParam:data[@"url"] desc:data[@"text"]];
        if (de1)
            [ar addObject:de1];
    }
    if (ar.count)
        return ar;
    return nil;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {

    if (textField.superview && textField.tag >= 100) {
        NSInteger index = textField.tag%10;
        URLDataCell *c =  (URLDataCell *)[self.urlList cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index  inSection:0]];
        if (c) {
            [self.urlList setContentOffset:c.frame.origin];
        }
    }
    return YES;
}
- (void)keyboardWasShown:(NSNotification*)aNotification {
    
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.superview && textField.tag >= 100) {
        NSInteger index = textField.tag%10;
        BOOL isd = textField.tag >= 110;
        
        NSString *result = [textField.text stringByReplacingCharactersInRange:range withString:string];
        NSMutableDictionary *changed = [NSMutableDictionary dictionaryWithDictionary:[self.urldata objectAtIndex:index]];
        if (isd) {
            [changed setObject:result forKey:@"text"];
        } else {
            [changed setObject:result forKey:@"url"];
        }
        [self.urldata removeObjectAtIndex:index];
        [self.urldata insertObject:changed atIndex:index];
        
        //[self.urlList reloadData];
    }
    return YES;
}
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    
    self.urlList.contentOffset = CGPointZero;
}

#pragma mark -
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 226;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.urldata.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    URLDataCell *c = (URLDataCell *) [tableView dequeueReusableCellWithIdentifier:@"URLDataCell"];
    NSDictionary *d = [self.urldata objectAtIndex:indexPath.row];
    if ([d objectForKey:@"url"]) {
        NSObject *u = [d objectForKey:@"url"];
        if ([u isKindOfClass:[NSString class]]) {
            c.urlTextField.text = (NSString *)u;
        }
    } else {
        c.urlTextField.text = @"";
    }
    if ([d objectForKey:@"text"]) {
        NSObject *u = [d objectForKey:@"text"];
        if ([u isKindOfClass:[NSString class]]) {
            c.descTextField.text = (NSString *)u;
        }
    } else {
        c.descTextField.text = @"";
    }
    c.descTextField.delegate = self;
    c.urlTextField.tag = indexPath.row+100;
    c.urlTextField.delegate = self;
    c.descTextField.tag = indexPath.row+110;
    return c;
}
@end
