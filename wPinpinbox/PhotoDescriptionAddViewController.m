//
//  PhotoDescriptionAddViewController.m
//  wPinpinbox
//
//  Created by Antelis on 2018/11/22.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "PhotoDescriptionAddViewController.h"
#import "LabelAttributeStyle.h"

@interface PhotoDescriptionAddViewController ()<UITextViewDelegate>
//@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionTitleLabel;
@property(nonatomic) IBOutlet UITextView *itemDesc;
//@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
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
    if ([wTools objectExists: self.titleLabel]) {
        [LabelAttributeStyle changeGapStringAndLineSpacingCenterAlignment: self.titleLabel content: self.titleLabel.text];
    }
    if ([wTools objectExists: self.descriptionTitleLabel]) {
        [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: self.descriptionTitleLabel content: self.descriptionTitleLabel.text];
    }
    if ([wTools objectExists: self.saveBtn]) {
        [LabelAttributeStyle changeGapStringAndLineSpacingCenterAlignment: self.saveBtn.titleLabel content: self.saveBtn.titleLabel.text];
    }    
    
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
    
    self.itemDesc.scrollEnabled = YES;
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
        //  calculate availble size of textview
        CGSize d = [textView sizeThatFits:CGSizeMake(self.baseView.frame.size.width - 32, dh)];
        
        // if keybaord is shown
        if (_keyboardOrigin > 0 ) {
            // check if textview is covered by keyboard
            BOOL crossed = (self.baseView.frame.origin.y+self.itemDesc.frame.origin.y+d.height) > _keyboardOrigin;
            //  max height minus keybard
            if (crossed) {
                dh -= _keyboardOrigin;
                dh += (self.itemDesc.frame.origin.y+self.baseView.frame.origin.y-8);
            }
        }
        //  enable scrolling
        textView.scrollEnabled = (d.height > dh);
        //  set textview height
        self.textViewHeight.constant = (d.height < dh)? d.height: dh;
    } else {
        self.textViewHeight.constant = 40;
        [self.itemDesc setNeedsLayout];
    }
}
- (CGFloat)fullTextViewHeight {
    //  max valid height of ItemDesc
    return self.baseView.frame.size.height-8-self.itemDesc.frame.origin.y;
}
@end
