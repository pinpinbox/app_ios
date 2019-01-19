//
//  DDAUIActionSheetViewController.m
//  CustomActionSheetTest
//
//  Created by David on 7/31/17.
//  Copyright © 2017 vmage. All rights reserved.
//

#import "DDAUIActionSheetViewController.h"
#import "MyLayout.h"
#import "UIColor+Extensions.h"
#import "GlobalVars.h"
#import "wTools.h"
//#import "LabelAttributeStyle.h"

@interface DDAUIActionSheetViewController () <UITextViewDelegate> {
    BOOL isTouchDown;
    BOOL setupPagesViewSelected;
    BOOL setupAllPagesViewSelected;
    BOOL kbShowsUp;
    NSInteger kbHeight;
    NSString *previewPageStr;
//    NSInteger allPageNum;
}
@property (weak, nonatomic) IBOutlet UIView *blackView;
//@property (nonatomic) UIVisualEffectView *effectView;
@property (weak, nonatomic) IBOutlet UIView *actionSheetView;
@property (weak, nonatomic) IBOutlet UILabel *topicLabel;
@property (weak, nonatomic) IBOutlet MyLinearLayout *contentLayout;
@property (nonatomic) NSInteger allPageNum;
@property (nonatomic) NSInteger selectedTag;

@end

@implementation DDAUIActionSheetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"");
    NSLog(@"DDAUIActionSheetViewController");
    NSLog(@"viewWillAppear");
    NSLog(@"Before slideIn");
    NSLog(@"self.actionSheetView: %@", self.actionSheetView);
    
    /*
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(handleTapFromView:)];
    [self.view addGestureRecognizer: tapGestureRecognizer];
    tapGestureRecognizer.delegate = self;
    */
    
    [self slideIn];
    
    NSLog(@"After slideIn");
    NSLog(@"self.actionSheetView: %@", self.actionSheetView);
}

#pragma mark - Keyboard Notification
- (void)addKeyboardNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)removeKeyboardNotification {
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIKeyboardDidShowNotification
                                                  object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIKeyboardWillHideNotification
                                                  object: nil];
}

- (void)keyboardDidShow:(NSNotification*)aNotification {
    NSLog(@"keyboardDidShow");
    kbShowsUp = YES;
    NSDictionary *info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey: UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    kbHeight = kbSize.height;
    NSLog(@"kbSize.height: %f", kbSize.height);
    
    if (@available(iOS 11.0, *)) {
        CGFloat bt = self.view.safeAreaInsets.bottom;
        NSLog(@"bt: %f", bt);
        
        if (bt > 0) {
            NSLog(@"For Full Screen");
            CGRect frame = self.actionSheetView.frame;
            frame.origin.y -= kbHeight;
            self.actionSheetView.frame = frame;
            self.actionSheetView.myBottomMargin = kbHeight;
        } else {
            NSLog(@"For Non Full Screen");
            CGRect frame = self.actionSheetView.frame;
            frame.origin.y -= 100;
            self.actionSheetView.frame = frame;
            self.actionSheetView.myBottomMargin = 100;
        }
    } else {
        NSLog(@"For iOS Version earlier than 11.0");
        NSLog(@"For Non Full Screen");
        CGRect frame = self.actionSheetView.frame;
        frame.origin.y -= 100;
        self.actionSheetView.frame = frame;
        self.actionSheetView.myBottomMargin = 100;
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    NSLog(@"keyboardWillBeHidden");
    kbShowsUp = NO;
    
    CGRect frame = self.actionSheetView.frame;
    frame.origin.y = self.view.bounds.size.height - self.actionSheetView.frame.size.height;
    self.actionSheetView.frame = frame;
    self.actionSheetView.myBottomMargin = 0;
}

- (void)dismissKeyboard {
    NSLog(@"dismissKeyboard");
    [self.view endEditing: YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addSelectButtons:(NSArray *)btnStrs
          identifierStrs:(NSArray *)identifierStrs {
    if (btnStrs.count < 1) return ;
    
    MyLinearLayout *horzLayout = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Horz];
    
    horzLayout.myLeftMargin = horzLayout.myRightMargin = 0;
    horzLayout.myTopMargin = horzLayout.myBottomMargin = 0;
    
    if (@available(iOS 11.0, *)) {
        CGFloat bt = self.view.safeAreaInsets.bottom;
        horzLayout.myHeight = 48 + bt;
    } else {
        // Fallback on earlier versions
        horzLayout.myHeight = 48;
    }
    CGFloat ww = [UIApplication sharedApplication].keyWindow.frame.size.width / btnStrs.count;
    //NSInteger n = btnStrs.count;
    
    for (int i = 0 ; i < btnStrs.count; i++) {
        NSString *s = [btnStrs objectAtIndex:i];
        NSString *is = [identifierStrs objectAtIndex:i];
        
        UIButton *btn = [UIButton buttonWithType: UIButtonTypeCustom];
        btn.myTopMargin = 4;
        btn.wrapContentWidth = YES;
        btn.myLeftMargin = btn.myRightMargin = 8;
//        btn.myCenterYOffset = 0;
        btn.widthDime.min(ww - 16);
        btn.heightDime.min(48);
        btn.layer.cornerRadius = kCornerRadius;
        btn.layer.borderColor = [UIColor firstGrey].CGColor;
        btn.layer.borderWidth = 1.0;
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 4);
        btn.backgroundColor = [UIColor clearColor];
        
        [btn setTitle: s forState: UIControlStateNormal];
        [btn setTitleColor: [UIColor firstGrey] forState: UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize: 18.0];
        [btn sizeToFit];
        btn.accessibilityIdentifier = is;
        btn.tag = i + 1;
        
        [btn addTarget: self action: @selector(buttonHighlight:) forControlEvents: UIControlEventTouchDown];
        [btn addTarget: self action: @selector(buttonNormal:) forControlEvents: UIControlEventTouchUpInside];
        [btn addTarget: self action: @selector(buttonTouchUpOutside:) forControlEvents: UIControlEventTouchUpOutside];
        
        [horzLayout addSubview: btn];
    }
    [self.contentLayout addSubview: horzLayout];
}

- (void)addSelectItemForPreviewPage:(BOOL)gridViewSelected
                        hasTextView:(BOOL)hasTextView
                     firstLabelText:(NSString *)firstLabelText
                    secondLabelText:(NSString *)secondLabelText
                     previewPageNum:(NSInteger)previewPageNum
                         allPageNum:(NSInteger)allPageNum
                             tagInt:(NSInteger)tagInt
                      identifierStr:(NSString *)identifierStr {
    NSLog(@"addSelectItemForPreviewPage");
    MyLinearLayout *horzLayout = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Horz];
    horzLayout.myLeftMargin = horzLayout.myRightMargin = 0;
    horzLayout.myTopMargin = horzLayout.myBottomMargin = 0;
    horzLayout.myHeight = 48;
    horzLayout.tag = tagInt;
    horzLayout.accessibilityIdentifier = identifierStr;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(handleTapForPreviewPage:)];
    singleTap.numberOfTapsRequired = 1;
    [horzLayout addGestureRecognizer: singleTap];
    
    UIView *gridView = [UIView new];
    gridView.accessibilityIdentifier = @"gridView";
    gridView.mySize = CGSizeMake(30.0, 30.0);
    gridView.myLeftMargin = 16.0;
    gridView.myRightMargin = 4.0;
    gridView.myCenterYOffset = 0;
    gridView.layer.cornerRadius = kCornerRadius;
    gridView.layer.borderColor = [UIColor thirdGrey].CGColor;
    gridView.layer.borderWidth = 1.0;
    if (gridViewSelected) {
        gridView.backgroundColor = [UIColor thirdMain];
    } else {
        gridView.backgroundColor = [UIColor clearColor];
    }
    [horzLayout addSubview: gridView];
    
    UILabel *firstLabel = [UILabel new];
    firstLabel.accessibilityIdentifier = @"firstLabel";
    firstLabel.myCenterYOffset = 0;
    firstLabel.myLeftMargin = 16;
    firstLabel.myRightMargin = 4;
    firstLabel.text = firstLabelText;
    //[LabelAttributeStyle changeGapString: label content: title];
    if (gridViewSelected) {
        firstLabel.textColor = [UIColor firstGrey];
    } else {
        firstLabel.textColor = [UIColor thirdGrey];
    }
    firstLabel.font = [UIFont systemFontOfSize: 18];
    [firstLabel sizeToFit];
    [horzLayout addSubview: firstLabel];
    
    if (hasTextView) {
        UIToolbar *toolBarForDoneBtn = [[UIToolbar alloc] initWithFrame: CGRectMake(0, 0, 320, 40)];
        toolBarForDoneBtn.barStyle = UIBarStyleDefault;
        toolBarForDoneBtn.items = [NSArray arrayWithObjects:
                                   //[[UIBarButtonItem alloc] initWithTitle: @"取消" style: UIBarButtonItemStylePlain target: self action: @selector(cancelNumberPad)],
                                   [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil],
                                   [[UIBarButtonItem alloc] initWithTitle: @"完成" style: UIBarButtonItemStyleDone target: self action: @selector(dismissKeyboard)] ,nil];
        
        UITextView *inputTextView = [UITextView new];
        inputTextView.accessibilityIdentifier = @"inputTextView";
        inputTextView.delegate = self;
        inputTextView.myCenterYOffset = 0;
        inputTextView.mySize = CGSizeMake(56.0, 33.0);
        inputTextView.inputAccessoryView = toolBarForDoneBtn;
        inputTextView.keyboardType = UIKeyboardTypeNumberPad;
        
        if (gridViewSelected) {
            inputTextView.backgroundColor = [UIColor thirdGrey];
            inputTextView.textColor = [UIColor firstGrey];
        } else {
            inputTextView.backgroundColor = [UIColor clearColor];
            inputTextView.textColor = [UIColor thirdGrey];
        }
        inputTextView.layer.cornerRadius = kCornerRadius;
        inputTextView.textContainerInset = UIEdgeInsetsMake(4, 4, 4, 4);
        inputTextView.font = [UIFont systemFontOfSize: 18];
        inputTextView.text = [NSString stringWithFormat: @"%ld", (long)previewPageNum];
//        inputTextView.text = @"";
        [horzLayout addSubview: inputTextView];
    }
    if (![secondLabelText isEqualToString: @""]) {
        UILabel *secondLabel = [UILabel new];
        secondLabel.accessibilityIdentifier = @"secondLabel";
        secondLabel.myCenterYOffset = 0;
        secondLabel.myLeftMargin = 4;
        secondLabel.text = @"頁";
        //[LabelAttributeStyle changeGapString: label content: title];
        if (gridViewSelected) {
            secondLabel.textColor = [UIColor firstGrey];
        } else {
            secondLabel.textColor = [UIColor thirdGrey];
        }
        secondLabel.font = [UIFont systemFontOfSize: 18];
        [secondLabel sizeToFit];
        [horzLayout addSubview: secondLabel];
    }
    
    self.allPageNum = allPageNum;
    NSLog(@"self.allPageNum: %ld", (long)self.allPageNum);
    
    if ([identifierStr isEqualToString: @"setupPages"]) {
        setupPagesViewSelected = gridViewSelected;
        if (setupPagesViewSelected) {
            previewPageStr = [NSString stringWithFormat: @"%ld", (long)previewPageNum];
        }
    }
    if ([identifierStr isEqualToString: @"setupAllPages"]) {
        setupAllPagesViewSelected = gridViewSelected;
        
        if (setupAllPagesViewSelected) {
            previewPageStr = [NSString stringWithFormat: @"%ld", (long)self.allPageNum];
            NSLog(@"previewPageStr: %@", previewPageStr);
        }
    }
    [self.contentLayout addSubview: horzLayout];
}
- (void)addSelectItemForPreviewPage:(BOOL)gridViewSelected
                        hasTextView:(BOOL)hasTextView
                     firstLabelText:(NSString *)firstLabelText
                    secondLabelText:(NSString *)secondLabelText
                     previewPageNum:(NSInteger)previewPageNum
                             tagInt:(NSInteger)tagInt
                      identifierStr:(NSString *)identifierStr {
    
}
- (void)addSelectItemForPreviewPage:(NSString *)imgName
                              title:(NSString *)title
                           horzLine:(BOOL)horzLine                
                             btnStr:(NSString *)btnStr
                             tagInt:(NSInteger)tagInt
                      identifierStr:(NSString *)identifierStr {
    MyLinearLayout *horzLayout = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Horz];
    horzLayout.myLeftMargin = horzLayout.myRightMargin = 0;
    horzLayout.myTopMargin = horzLayout.myBottomMargin = 0;
    horzLayout.myHeight = 48;
    horzLayout.tag = tagInt;
    horzLayout.accessibilityIdentifier = identifierStr;
    
//    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(handleTapFromView:)];
//    singleTap.numberOfTapsRequired = 1;
//    [horzLayout addGestureRecognizer: singleTap];
    
    if (imgName != nil) {
        NSLog(@"imgName != nil");
        NSLog(@"imgName isEqualToString: %@", imgName);
        
        if (![imgName isEqualToString: @""]) {
            UIImageView *imgView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 20, 20)];
            imgView.image = [UIImage imageNamed: imgName];
            imgView.myLeftMargin = 16;
            imgView.myRightMargin = 8;
            imgView.myCenterYOffset = 0;
            [horzLayout addSubview: imgView];
        }
    }
    if (title != nil) {
        NSLog(@"title != nil");
        NSLog(@"title: %@", title);
        
        if (![title isEqualToString: @""]) {
            UILabel *label = [UILabel new];
            
            if ([imgName isEqualToString: @""]) {
                label.myLeftMargin = 16;
            } else {
                label.myLeftMargin = 8;
            }
            label.text = title;
            //[LabelAttributeStyle changeGapString: label content: title];
            label.textColor = [UIColor firstGrey];
            label.font = [UIFont systemFontOfSize: 18];
            [label sizeToFit];
            label.myCenterYOffset = 0;
            
            [horzLayout addSubview: label];
        }
    }
    if (horzLine) {
        UIView *horzLine = [UIView new];
        horzLine.wrapContentWidth = YES;
        horzLine.myCenterYOffset = 0;
        horzLine.myLeftMargin = horzLine.myRightMargin = 8;
        horzLine.myHeight = 0.5;
        horzLine.weight = 0.9;
        horzLine.backgroundColor = [UIColor secondGrey];
        [horzLayout addSubview: horzLine];
    }
    if (btnStr != nil) {
        if (![btnStr isEqualToString: @""]) {
            UIButton *btn = [UIButton buttonWithType: UIButtonTypeCustom];
            btn.wrapContentWidth = YES;
            btn.myLeftMargin = 8;
            btn.myRightMargin = 16;
            btn.myCenterYOffset = 0;
            btn.widthDime.min(90);
            btn.layer.cornerRadius = 8;
            btn.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 4);
            btn.backgroundColor = [UIColor firstMain];
            
            [btn addTarget: self action: @selector(buttonHighlight:) forControlEvents: UIControlEventTouchDown];
            [btn addTarget: self action: @selector(buttonNormal:) forControlEvents: UIControlEventTouchUpInside];
            [btn addTarget: self action: @selector(buttonNormal:) forControlEvents: UIControlEventTouchUpOutside];
            [btn setTitle: btnStr forState: UIControlStateNormal];
            [btn setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
            [btn sizeToFit];
            
            [horzLayout addSubview: btn];
        }
    }
    [self.contentLayout addSubview: horzLayout];
}

- (void)addSelectItem:(NSString *)imgName
                title:(NSString *)title
               btnStr:(NSString *)btnStr
               tagInt:(NSInteger)tagInt
        identifierStr:(NSString *)identifierStr {
    MyLinearLayout *horzLayout = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Horz];
    horzLayout.myLeftMargin = horzLayout.myRightMargin = 0;
    horzLayout.myTopMargin = horzLayout.myBottomMargin = 0;
    horzLayout.myHeight = 48;
    horzLayout.tag = tagInt;
    horzLayout.accessibilityIdentifier = identifierStr;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(handleTapFromView:)];
    singleTap.numberOfTapsRequired = 1;
    //singleTap.delaysTouchesEnded = YES;
    //singleTap.cancelsTouchesInView = YES;
    [horzLayout addGestureRecognizer: singleTap];
    
    NSLog(@"imgName: %@", imgName);
    NSLog(@"title: %@", title);
    NSLog(@"btnStr: %@", btnStr);
    NSLog(@"tagInt: %ld", (long)tagInt);
    
    if (imgName != nil) {
        NSLog(@"imgName != nil");
        NSLog(@"imgName isEqualToString: %@", imgName);
        
        if (![imgName isEqualToString: @""]) {
            UIImageView *imgView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 20, 20)];
            imgView.image = [UIImage imageNamed: imgName];
            imgView.myLeftMargin = 16;
            imgView.myRightMargin = 8;
            imgView.myCenterYOffset = 0;
            [horzLayout addSubview: imgView];
        }
    } else if (imgName == nil) {
        NSLog(@"imgName == nil");
    }
    
    if (title != nil) {
        NSLog(@"title != nil");
        NSLog(@"title: %@", title);
        
        if (![title isEqualToString: @""]) {
            UILabel *label = [UILabel new];
            
            if ([imgName isEqualToString: @""]) {
                label.myLeftMargin = 16;
            } else {
                label.myLeftMargin = 8;
            }
            
            label.text = title;
            //[LabelAttributeStyle changeGapString: label content: title];
            label.textColor = [UIColor firstGrey];
            label.font = [UIFont systemFontOfSize: 18];
            [label sizeToFit];
            label.myCenterYOffset = 0;
            
            [horzLayout addSubview: label];
        }
    } else if (title == nil) {
        NSLog(@"title == nil");
    }
    
    if (btnStr != nil) {
        if (![btnStr isEqualToString: @""]) {
            UIButton *btn = [UIButton buttonWithType: UIButtonTypeCustom];
            btn.wrapContentWidth = YES;
            btn.myLeftMargin = 8;
            btn.myRightMargin = 16;
            btn.myCenterYOffset = 0;
            btn.widthDime.min(112);
            btn.layer.cornerRadius = 8;
            btn.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 4);
            btn.backgroundColor = [UIColor firstMain];
            
            [btn addTarget: self action: @selector(buttonHighlight:) forControlEvents: UIControlEventTouchDown];
            [btn addTarget: self action: @selector(buttonNormal:) forControlEvents: UIControlEventTouchUpInside];
            [btn addTarget: self action: @selector(buttonNormal:) forControlEvents: UIControlEventTouchUpOutside];
            [btn setTitle: btnStr forState: UIControlStateNormal];
            [btn setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
            [btn sizeToFit];
            
            [horzLayout addSubview: btn];
        }
    }
    
    [self.contentLayout addSubview: horzLayout];
}

// Method below only applies to collectView
// If there are any changes below, the method above should also be changed as well.
- (void)addSelectItem:(NSString *)imgName
                title:(NSString *)title
               btnStr:(NSString *)btnStr
               tagInt:(NSInteger)tagInt
        identifierStr:(NSString *)identifierStr
          isCollected:(BOOL)isCollected {
    MyLinearLayout *horzLayout = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Horz];
    horzLayout.myLeftMargin = horzLayout.myRightMargin = 0;
    horzLayout.myTopMargin = horzLayout.myBottomMargin = 0;
    horzLayout.myHeight = 48;
    horzLayout.tag = tagInt;
    horzLayout.accessibilityIdentifier = identifierStr;
    
    if (isCollected) {
        horzLayout.userInteractionEnabled = NO;
    } else {
        horzLayout.userInteractionEnabled = YES;
    }
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(handleTapFromView:)];
    singleTap.numberOfTapsRequired = 1;
    //singleTap.delaysTouchesEnded = YES;
    //singleTap.cancelsTouchesInView = YES;
    [horzLayout addGestureRecognizer: singleTap];
    
    NSLog(@"imgName: %@", imgName);
    NSLog(@"title: %@", title);
    NSLog(@"btnStr: %@", btnStr);
    NSLog(@"tagInt: %ld", (long)tagInt);
    
    if (imgName != nil) {
        NSLog(@"imgName != nil");
        NSLog(@"imgName isEqualToString: %@", imgName);
        
        if (![imgName isEqualToString: @""]) {
            UIImageView *imgView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 20, 20)];
            imgView.image = [UIImage imageNamed: imgName];
            imgView.myLeftMargin = 16;
            imgView.myRightMargin = 8;
            imgView.myCenterYOffset = 0;
            [horzLayout addSubview: imgView];
        }
    } else if (imgName == nil) {
        NSLog(@"imgName == nil");
    }
    
    if (title != nil) {
        NSLog(@"title != nil");
        NSLog(@"title: %@", title);
        
        if (![title isEqualToString: @""]) {
            UILabel *label = [UILabel new];
            
            if ([imgName isEqualToString: @""]) {
                label.myLeftMargin = 16;
            } else {
                label.myLeftMargin = 8;
            }
            
            label.text = title;
            //[LabelAttributeStyle changeGapString: label content: title];
            
            if (isCollected) {
                label.textColor = [UIColor lightGrayColor];
            } else {
                label.textColor = [UIColor firstGrey];
            }
            label.font = [UIFont systemFontOfSize: 18];
            [label sizeToFit];
            label.myCenterYOffset = 0;
            
            [horzLayout addSubview: label];
        }
    } else if (title == nil) {
        NSLog(@"title == nil");
    }
    
    if (btnStr != nil) {
        if (![btnStr isEqualToString: @""]) {
            if (!isCollected) {
                UIButton *btn = [UIButton buttonWithType: UIButtonTypeCustom];
                btn.wrapContentWidth = YES;
                btn.myLeftMargin = 8;
                btn.myRightMargin = 16;
                btn.myCenterYOffset = 0;
                btn.widthDime.min(100);
                btn.layer.cornerRadius = 8;
                btn.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 4);
                btn.backgroundColor = [UIColor firstMain];
                
                [btn addTarget: self action: @selector(buttonHighlight:) forControlEvents: UIControlEventTouchDown];
                [btn addTarget: self action: @selector(buttonNormal:) forControlEvents: UIControlEventTouchUpInside];
                [btn addTarget: self action: @selector(buttonNormal:) forControlEvents: UIControlEventTouchUpOutside];
                [btn setTitle: btnStr forState: UIControlStateNormal];
                [btn setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
                [btn sizeToFit];
                
                [horzLayout addSubview: btn];
            }                        
        }
    }
    
    [self.contentLayout addSubview: horzLayout];
}

- (void)addHorizontalLine {
    UIView *horizontalLineView = [UIView new];
    horizontalLineView.backgroundColor = [UIColor thirdGrey];
    horizontalLineView.myHeight = 1;
    horizontalLineView.myLeftMargin = horizontalLineView.myRightMargin = 0;
    horizontalLineView.myTopMargin = horizontalLineView.myBottomMargin = 10;
    [self.contentLayout addSubview: horizontalLineView];
}

- (void)addSafeArea {
    NSLog(@"addSafeArea");
    
    if (@available(iOS 11.0, *)) {
        MyLinearLayout *horzLayout = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Horz];
        horzLayout.myLeftMargin = horzLayout.myRightMargin = 0;
        horzLayout.myTopMargin = horzLayout.myBottomMargin = 0;
        CGFloat bt = self.view.safeAreaInsets.bottom;
        horzLayout.myHeight = bt;
        [self.contentLayout addSubview: horzLayout];
    } else {
        // Fallback on earlier versions
    }
}

#pragma mark - Custom ActionSheet Methods
- (void)slideIn {
    NSLog(@"");
    NSLog(@"sldeIn");
    kbShowsUp = NO;
    [self addKeyboardNotification];
    
    NSLog(@"Before setting self.view.frame");
    NSLog(@"self.view.frame: %@", NSStringFromCGRect(self.view.frame));
    NSLog(@"[[UIScreen mainScreen] bounds]: %@", NSStringFromCGRect([[UIScreen mainScreen] bounds]));
    
    self.view.frame = [[UIScreen mainScreen] bounds];
    
    NSLog(@"");
    NSLog(@"After setting self.view.frame");
    NSLog(@"self.view.frame: %@", NSStringFromCGRect(self.view.frame));
    
    //[self.actionSheetView setBounds: CGRectMake(0, [[UIScreen mainScreen] bounds].origin.y, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    
    NSLog(@"");
    NSLog(@"Before changing actionSheetView");
    NSLog(@"self.actionSheetView: %@", self.actionSheetView);
    
    // Set initial location at bottom of view
    CGRect frame = self.actionSheetView.frame;
    frame.origin = CGPointMake(0.0, self.view.bounds.size.height - self.actionSheetView.frame.size.height);
    self.actionSheetView.frame = frame;
    
    self.actionSheetView.myLeftMargin = self.actionSheetView.myRightMargin = 0;
    self.actionSheetView.myBottomMargin = 0;
    self.actionSheetView.wrapContentHeight = YES;
    
    NSLog(@"");
    NSLog(@"After changing actionSheetView");
    NSLog(@"self.actionSheetView: %@", self.actionSheetView);
    
    // Topic Label Setting
    self.topicLabel.myLeftMargin = 16;
    self.topicLabel.myTopMargin = 4;
    self.topicLabel.myBottomMargin = 16;    
    self.topicLabel.text = self.topicStr;
    //[LabelAttributeStyle changeGapString: self.topicLabel content: self.topicStr];
    self.topicLabel.textColor = [UIColor whiteColor];
    self.topicLabel.font = [UIFont boldSystemFontOfSize: 24];
    [self.topicLabel sizeToFit];        
    
    // ContentLayout Setting
    self.contentLayout.padding = UIEdgeInsetsMake(16, 0, 16, 0);
    self.contentLayout.myLeftMargin = self.contentLayout.myRightMargin = 0;
    self.contentLayout.myTopMargin = 0;
    self.contentLayout.myBottomMargin = 0;
    self.contentLayout.wrapContentHeight = YES;
    
    // Creating Blur Effect
    //self.effectView = [[UIVisualEffectView alloc] initWithEffect: [UIBlurEffect effectWithStyle: UIBlurEffectStyleDark]];
    /*
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle: UIBlurEffectStyleDark];
    self.effectView = [[UIVisualEffectView alloc] initWithEffect: blurEffect];
    self.effectView.frame = self.view.frame;
    self.effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.effectView.myLeftMargin = self.effectView.myRightMargin = 0;
    self.effectView.myTopMargin = self.effectView.myBottomMargin = 0;    
    self.effectView.tag = 100;
    //self.effectView.alpha = 0.5;
    
    [self.view addSubview: self.effectView];
     */
    
    [self.view addSubview: self.actionSheetView];
    
    // Set up an animation for the transition between the views
    CATransition *animation = [CATransition animation];
    [animation setDuration: 0.2];
    [animation setType: kCATransitionPush];
    [animation setSubtype: kCATransitionFromTop];
    [animation setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
    
    //self.view.alpha = 1.0f;
    self.view.backgroundColor = [UIColor clearColor];
    [self.actionSheetView.layer addAnimation: animation forKey: @"TransitionToActionSheet"];
}

- (void)slideOut {
    NSLog(@"");
    NSLog(@"slideOut");
    NSLog(@"kbShowsUp: %d", kbShowsUp);
    
//    if (kbShowsUp) {
//        // Reset CustomActionSheet Origin
//        CGRect frame = self.actionSheetView.frame;
//        frame.origin.y = self.view.bounds.size.height - self.actionSheetView.frame.size.height;
//        self.actionSheetView.frame = frame;
//        self.actionSheetView.myBottomMargin = 0;
//    }
    [self removeKeyboardNotification];
    
    [UIView beginAnimations: @"removeFromSuperviewWithAnimation" context: nil];
    
    // Set delegate and selector to remove from superview when animation completes
    [UIView setAnimationDelegate: self];
    [UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
    
    NSLog(@"");
    NSLog(@"Before setting bounds");
    NSLog(@"self.actionSheetView: %@", self.actionSheetView);
    
    // Move this view to bottom of superview
    CGRect frame = self.actionSheetView.frame;
    frame.origin = CGPointMake(0.0, self.view.bounds.size.height);
    self.actionSheetView.frame = frame;
    self.actionSheetView.myBottomMargin = 0;
    
    NSLog(@"");
    NSLog(@"After setting bounds");
    NSLog(@"self.actionSheetView: %@", self.actionSheetView);
    
    [UIView commitAnimations];
    
    if ([self.delegate respondsToSelector: @selector(actionSheetViewDidSlideOut:)]) {
        [self.delegate actionSheetViewDidSlideOut: self];
    }
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    NSLog(@"");
    NSLog(@"animationDidStop");
    
    if ([animationID isEqualToString: @"removeFromSuperviewWithAnimation"]) {
        [self.view removeFromSuperview];
        
        NSArray *viewsToRemove = self.contentLayout.subviews;
        
        NSLog(@"Before Removing");
        NSLog(@"viewsToRemove: %@", viewsToRemove);
        
        for (UIView *v in viewsToRemove) {
            [v removeFromSuperview];
            NSLog(@"v removeFromSuperview");
        }
        NSLog(@"After Removing");
        NSLog(@"viewsToRemove: %@", viewsToRemove);
    }
}

#pragma mark - UIButton Selector Method
- (void)buttonNormal:(UIButton *)sender {
    NSLog(@"btnPress");
    sender.backgroundColor = [UIColor firstMain];
    
    if (self.customButtonBlock) {
        NSLog(@"self.customButtonBlock exists");
        self.customButtonBlock(sender.selected);
    } else if (self.customButtonTapBlock) {
        NSLog(@"self.customButtonTapBlock exists");
        [self slideOut];
        self.customButtonTapBlock(sender.tag, sender.accessibilityIdentifier);
    } else if (self.customButtonBlockForPreview) {
        [self dismissKeyboard];
        self.customButtonBlockForPreview(sender.selected, previewPageStr);
    }
}

- (void)buttonHighlight:(UIButton *)sender {
    NSLog(@"buttonHighlight");
    sender.backgroundColor = [UIColor secondMain];
}

- (void)buttonTouchUpOutside:(UIButton *)sender {
    NSLog(@"buttonTouchUpOutside");
    sender.backgroundColor = [UIColor clearColor];
}

#pragma mark - UITapGestureRecognizer Selector Handler Method
// Method below is to achieve the TouchUpInside Behavior
- (void)handleTapFromView:(UITapGestureRecognizer *)sender {
    NSLog(@"handleTapFromView");
    [self slideOut];
    
    if (self.customViewBlock) {
        self.customViewBlock(sender.view.tag, isTouchDown, sender.view.accessibilityIdentifier);
    }
    
    /*
     if (sender.state == UIGestureRecognizerStateBegan || sender.state == UIGestureRecognizerStateChanged) {
     sender.view.backgroundColor = [UIColor lightGrayColor];
     } else if (sender.state == UIGestureRecognizerStateEnded) {
     sender.view.backgroundColor = [UIColor clearColor];
     }
     */
}

- (void)handleTapForPreviewPage:(UITapGestureRecognizer *)sender {
    NSLog(@"handleTapForPreviewPage");
    if (self.customViewBlock) {
        self.customViewBlock(sender.view.tag, isTouchDown, sender.view.accessibilityIdentifier);
    }
}

// Methods below are to achieve the selected behavior
// If executing slideOut here, then the TouchUpInside behavior can not be achieved
- (void)touchesBegan:(NSSet<UITouch *> *)touches
           withEvent:(UIEvent *)event {
    NSLog(@"");
    NSLog(@"touchesBegan");
    NSLog(@"");
    
    UITouch *touch = [touches anyObject];
    NSLog(@"touch.view: %@", touch.view);
    NSLog(@"touch.view.tag: %d", (int)touch.view.tag);
    NSLog(@"touch.view.accessibilityIdentifier: %@", touch.view.accessibilityIdentifier);
    
    NSString *identifierStr = touch.view.accessibilityIdentifier;
    
    isTouchDown = YES;
    
    if ([wTools objectExists: identifierStr]) {
        if ([identifierStr isEqualToString: @"setupPreview"]) {
            touch.view.backgroundColor = [UIColor clearColor];
            return;
        } else if ([identifierStr isEqualToString: @"setupPages"]) {
            touch.view.backgroundColor = [UIColor clearColor];
            [self changePreviewPageSetupViews: touch.view];
            return;
        } else if ([identifierStr isEqualToString: @"setupAllPages"]) {
            touch.view.backgroundColor = [UIColor clearColor];
            NSLog(@"self.allPageNum: %ld", (long)self.allPageNum);
            previewPageStr = [NSString stringWithFormat: @"%ld", (long)self.allPageNum];
            NSLog(@"previewPageStr: %@", previewPageStr);
            [self changePreviewPageSetupViews: touch.view];
            return;
        } else if ([identifierStr isEqualToString: @"gridView"]) {
            NSLog(@"touch.view.superview: %@", touch.view.superview);
            NSLog(@"touch.view.superview.accessibilityIdentifier: %@", touch.view.superview.accessibilityIdentifier);
            NSString *identifierStr1 = touch.view.superview.accessibilityIdentifier;
            if ([identifierStr1 isEqualToString: @"setupPages"]) {
                touch.view.backgroundColor = [UIColor clearColor];
                
                for (UITextView *textView in touch.view.superview.subviews) {
                    if ([textView.accessibilityIdentifier isEqualToString: @"inputTextView"]) {
                        NSLog(@"textView.text: %@", textView.text);
                        previewPageStr = textView.text;
                    }
                }
                [self changePreviewPageSetupViews: touch.view.superview];
                return;
            } else if ([identifierStr1 isEqualToString: @"setupAllPages"]) {
                NSLog(@"self.allPageNum: %ld", (long)self.allPageNum);
                previewPageStr = [NSString stringWithFormat: @"%ld", (long)self.allPageNum];
                NSLog(@"previewPageStr: %@", previewPageStr);
                [self changePreviewPageSetupViews: touch.view.superview];
                return;
            }
            return;
        }
    }
    if (touch.view.tag != 0 && touch.view.tag != 100 && touch.view.tag != 200 && touch.view.tag != 300) {
        touch.view.backgroundColor = [UIColor thirdMain];
    }
    if (touch.view.tag == 100) {
        [self slideOut];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches
           withEvent:(UIEvent *)event {
    NSLog(@"");
    NSLog(@"touchesEnded");
    NSLog(@"");
    
    UITouch *touch = [touches anyObject];
    
    if (touch.view.tag != 0 && touch.view.tag != 100 && touch.view.tag != 200 && touch.view.tag != 300) {
        touch.view.backgroundColor = [UIColor clearColor];                
    }
    
    if (isTouchDown) {
        isTouchDown = NO;
        /*
        if (self.customViewBlock) {
            self.customViewBlock(touch.view.tag, isTouchDown);
        }
         */
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches
               withEvent:(UIEvent *)event {
    NSLog(@"");
    NSLog(@"touchesCancelled");
    NSLog(@"");
    
    UITouch *touch = [touches anyObject];
    
    if (touch.view.tag != 0 && touch.view.tag != 100 && touch.view.tag != 200 && touch.view.tag != 300) {
        touch.view.backgroundColor = [UIColor clearColor];
    }
    
    if (isTouchDown) {
        isTouchDown = NO;
        
        /*
        if (self.customViewBlock) {
            self.customViewBlock(touch.view.tag, isTouchDown);
        }
         */
    }
}

- (void)changePreviewPageSetupViews:(UIView *)view {
    if ([view.accessibilityIdentifier isEqualToString: @"setupPages"]) {
        setupPagesViewSelected = YES;
        setupAllPagesViewSelected = NO;
        [self changeSetupPagesView: view];
        
        NSLog(@"view.accessibilityIdentifier: %@", view.accessibilityIdentifier);
        for (UIView *v in view.superview.subviews) {
            NSLog(@"v.accessibilityIdentifier: %@", v.accessibilityIdentifier);
            
            if ([v.accessibilityIdentifier isEqualToString: @"setupAllPages"]) {
                [self changeSetupAllPagesView: v];
            }
        }
    } else if ([view.accessibilityIdentifier isEqualToString: @"setupAllPages"]) {
        setupPagesViewSelected = NO;
        setupAllPagesViewSelected = YES;
        [self changeSetupAllPagesView: view];
        
        NSLog(@"view.accessibilityIdentifier: %@", view.accessibilityIdentifier);
        for (UIView *v in view.superview.subviews) {
            NSLog(@"v.accessibilityIdentifier: %@", v.accessibilityIdentifier);
            
            if ([v.accessibilityIdentifier isEqualToString: @"setupPages"]) {
                [self changeSetupPagesView: v];
            }
        }
    }
}

- (void)changeSetupPagesView:(UIView *)view {
    NSLog(@"changeSetupPagesView");
    NSLog(@"setupPagesViewSelected: %d", setupPagesViewSelected);
    NSLog(@"setupAllPagesViewSelected: %d", setupAllPagesViewSelected);
    
    for (UIView *v in view.subviews) {
        NSLog(@"v.accessibilityIdentifier: %@", v.accessibilityIdentifier);
        if ([v.accessibilityIdentifier isEqualToString: @"gridView"]) {
            if (setupPagesViewSelected) {
                v.backgroundColor = [UIColor thirdMain];
            } else {
                v.backgroundColor = [UIColor clearColor];
            }
        }
        if ([v.accessibilityIdentifier isEqualToString: @"firstLabel"]) {
            UILabel *firstLabel = (UILabel *)v;
            if (setupPagesViewSelected) {
                firstLabel.textColor = [UIColor firstGrey];
            } else {
                firstLabel.textColor = [UIColor thirdGrey];
            }
        }
        if ([v.accessibilityIdentifier isEqualToString: @"secondLabel"]) {
            UILabel *secondLabel = (UILabel *)v;
            if (setupPagesViewSelected) {
                secondLabel.textColor = [UIColor firstGrey];
            } else {
                secondLabel.textColor = [UIColor thirdGrey];
            }
        }
        if ([v.accessibilityIdentifier isEqualToString: @"inputTextView"]) {
            UITextView *inputTextView = (UITextView *)v;
            if (setupPagesViewSelected) {
                inputTextView.backgroundColor = [UIColor thirdGrey];
                inputTextView.textColor = [UIColor firstGrey];
            } else {
                inputTextView.backgroundColor = [UIColor clearColor];
                inputTextView.textColor = [UIColor thirdGrey];
            }
        }
    }
}

- (void)changeSetupAllPagesView:(UIView *)view {
    NSLog(@"changeSetupAllPagesView");
    NSLog(@"setupPagesViewSelected: %d", setupPagesViewSelected);
    NSLog(@"setupAllPagesViewSelected: %d", setupAllPagesViewSelected);
    
    for (UIView *v in view.subviews) {
        NSLog(@"v.accessibilityIdentifier: %@", v.accessibilityIdentifier);
        if ([v.accessibilityIdentifier isEqualToString: @"gridView"]) {
            if (setupAllPagesViewSelected) {
                v.backgroundColor = [UIColor thirdMain];
            } else {
                v.backgroundColor = [UIColor clearColor];
            }
        }
        if ([v.accessibilityIdentifier isEqualToString: @"firstLabel"]) {
            UILabel *firstLabel = (UILabel *)v;
            if (setupAllPagesViewSelected) {
                firstLabel.textColor = [UIColor firstGrey];
            } else {
                firstLabel.textColor = [UIColor thirdGrey];
            }
        }
    }
}

#pragma mark - UITextViewDelegate Methods
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    NSLog(@"textViewShouldBeginEditing");
    NSLog(@"textView.superview.accessibilityIdentifier: %@", textView.superview.accessibilityIdentifier);
    
    if ([textView.superview.accessibilityIdentifier isEqualToString: @"setupPages"]) {
        [self changePreviewPageSetupViews: textView.superview];
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    NSLog(@"textViewDidBeginEditing");
    if ([textView.accessibilityIdentifier isEqualToString: @"inputTextView"]) {
        textView.text = previewPageStr;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    NSLog(@"textViewDidEndEditing");
    if ([textView.accessibilityIdentifier isEqualToString: @"inputTextView"]) {
        previewPageStr = textView.text;
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    NSLog(@"textViewDidChange");
}

- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text {
    NSLog(@"shouldChangeTextInRange");
    NSLog(@"DDAUIActionSheetViewController");
    NSLog(@"textView.text.length: %lu", (unsigned long)textView.text.length);
    NSLog(@"range.length: %lu", (unsigned long)range.length);
    NSLog(@"text.length: %lu", (unsigned long)text.length);
    if ((textView.text.length + (text.length - range.length)) > 3) {
        return NO;
    }
    return YES;
//    if ([text isEqualToString: @"\n"]) {
//        return NO;
//    }
    
//    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
