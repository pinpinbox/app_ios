//
//  PhotoDescriptionAddViewController.m
//  wPinpinbox
//
//  Created by Antelis on 2018/11/22.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "PhotoDescriptionAddViewController.h"


@interface PhotoDescriptionAddViewController ()<UITextViewDelegate>
@property(nonatomic) IBOutlet UITextView *itemDesc;
@property(nonatomic) DescSubmitBlock submitBlock;
@property(nonatomic) IBOutlet NSLayoutConstraint *textViewHeight;
@property(nonatomic) IBOutlet UILabel *placeholder;
@property(nonatomic) CGFloat keyboardOrigin;
@end

@implementation PhotoDescriptionAddViewController

- (id)init {
    self = [super init];
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.transitioningDelegate = self;
    self.modalPresentationCapturesStatusBarAppearance = YES;
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.transitioningDelegate = self;
    self.modalPresentationCapturesStatusBarAppearance = YES;
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addDismissTap];
    [self addKeyboardNotification];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self relayoutTextViewHeight:self.itemDesc];
}
- (void)addDesc:(NSString *)desc submitBlock:(DescSubmitBlock)submitBlock {

    self.keyboardOrigin = 0;
    self.itemDesc.text = desc;
    self.submitBlock = submitBlock;

    [self addTextViewAccessoryView];
    [self relayoutTextViewHeight:self.itemDesc];
}
- (void)addTextViewAccessoryView {
    UIToolbar *keybardBar = [[UIToolbar alloc] init];
    [keybardBar sizeToFit];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *dimiss = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissCurKeyboard:)];
    
    keybardBar.items = @[space, dimiss];
    
    self.itemDesc.inputAccessoryView = keybardBar;
    
}
- (IBAction)dismissCurKeyboard:(id)sender {
    if (self.itemDesc.isFirstResponder) {
        [self.itemDesc resignFirstResponder];
    }
}
- (IBAction)submitDesc:(id)sender {
    
    __block NSString *desc = self.itemDesc.text;
    __block typeof(self) wself = self;
    [self dismissViewControllerAnimated:YES completion:^{
        if (wself.submitBlock) {
            wself.submitBlock(desc);
        }
    }];
}

- (void)keyboardWasShown:(NSNotification*)aNotification {
    
    NSDictionary* info = [aNotification userInfo];
    CGRect key = [[info objectForKey: UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    _keyboardOrigin = key.origin.y;
    
    CGFloat th = self.textViewHeight.constant;
    CGFloat dh = [self fullTextViewHeight];
    BOOL crossed = (self.baseView.frame.origin.y+self.itemDesc.frame.origin.y+th) > _keyboardOrigin;
    if (crossed) {
        
        dh -= _keyboardOrigin;
        dh += (self.itemDesc.frame.origin.y+self.baseView.frame.origin.y-8);
    }
    
    self.itemDesc.scrollEnabled = YES;//(self > dh);
    self.textViewHeight.constant = (th < dh)? th: dh;
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    //self.baseView.transform = CGAffineTransformIdentity;
    _keyboardOrigin = 0;
    [self relayoutTextViewHeight:self.itemDesc];
}
- (void)textViewDidChange:(UITextView *)textView {
    
    [self relayoutTextViewHeight:textView];
}
- (void)relayoutTextViewHeight:(UITextView *)textView {
    
    self.placeholder.hidden = (textView.text.length > 0);
    
    if (textView.text.length) {
        
        CGFloat dh = [self fullTextViewHeight];
        CGSize d = [textView sizeThatFits:CGSizeMake(self.baseView.frame.size.width - 32, dh)];
        
        
        if (_keyboardOrigin > 0 ) {
            BOOL crossed = (self.baseView.frame.origin.y+self.itemDesc.frame.origin.y+d.height) > _keyboardOrigin;
            if (crossed) {
                dh -= _keyboardOrigin;
                dh += (self.itemDesc.frame.origin.y+self.baseView.frame.origin.y-8);
            }
        }
        textView.scrollEnabled = (d.height > dh);
        self.textViewHeight.constant = (d.height < dh)? d.height: dh;
    } else {
        self.textViewHeight.constant = 40;
        [self.itemDesc setNeedsLayout];
    }
}
- (CGFloat)fullTextViewHeight {
    return self.baseView.frame.size.height-8-self.itemDesc.frame.origin.y;
}
@end
