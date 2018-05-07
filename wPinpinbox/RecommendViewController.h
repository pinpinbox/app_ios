//
//  RecommendViewController.h
//  wPinpinbox
//
//  Created by Angus on 2015/10/22.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecommendViewController : UIViewController<UIScrollViewDelegate>{
    
    __weak IBOutlet UILabel *wtitle;
    __weak IBOutlet UILabel *lab_fb;
    __weak IBOutlet UILabel *lab_contacts;
    __weak IBOutlet UILabel *lab_text;
}
@property (nonatomic, assign) BOOL working;
@end
