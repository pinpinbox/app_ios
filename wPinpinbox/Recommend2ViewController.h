//
//  Recommend2ViewController.h
//  wPinpinbox
//
//  Created by Angus on 2015/12/9.
//  Copyright © 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Recommend2ViewController : UIViewController{
    
    __weak IBOutlet UILabel *wtitle;
    __weak IBOutlet UILabel *lab_text;
    __weak IBOutlet UIButton *button_attAll;
}
@property(nonatomic)NSString *type;
@end
