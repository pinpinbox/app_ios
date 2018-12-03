//
//  HomeCategoryCollectionViewCell.m
//  wPinpinbox
//
//  Created by David on 12/01/2018.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "HomeCategoryCollectionViewCell.h"
#import "GlobalVars.h"
#import "UIColor+HexString.h"

@implementation HomeCategoryCollectionHeader
- (void)awakeFromNib {
    [super awakeFromNib];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerTap:)];
    [self addGestureRecognizer:tap];
    NSLog(@"awakeFromNib");
}
- (void)headerTap:(UITapGestureRecognizer *)tap {
    if (self.tapBlock) {
        self.tapBlock();
    }
}

@end

@implementation HomeCategoryCollectionViewCell
- (void)awakeFromNib {
    [super awakeFromNib];
    NSLog(@"awakeFromNib");
    
    self.categoryBgView.backgroundColor = [UIColor clearColor];
    self.categoryBgView.layer.borderColor = [UIColor grayColor].CGColor;
    
    self.categoryBgView.layer.borderWidth = 0.5;
    
    
    //self.categoryBgView.layer.shadowRadius = 12;
    //self.categoryBgView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    //self.categoryBgView.layer.shadowOpacity = 0.2;
    
    //self.categoryBgView.layer.shadowOffset = CGSizeMake(2, 2);
    
}
@end
