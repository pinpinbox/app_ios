//
//  InfoBubbleView.h
//  wPinpinbox
//
//  Created by Antelis on 2018/11/26.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, InfoBubbleTipPosition) {
    InfoBubbleTipTopLeft = 0,
    InfoBubbleTipTopRight = 1,
    InfoBubbleTipBottomLeft = 2,
    InfoBubbleTipBottomRight = 3,
};

@interface InfoBubbleView : UIView
@property (nonatomic) InfoBubbleTipPosition tipPosition;
@end

NS_ASSUME_NONNULL_END
