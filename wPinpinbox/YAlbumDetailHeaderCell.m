//
//  YAlbumDetailHeaderCell.m
//  wPinpinbox
//
//  Created by Antelis on 2019/1/7.
//  Copyright © 2019 Angus. All rights reserved.
//

#import "YAlbumDetailHeaderCell.h"
#import "wTools.h"
#import "LabelAttributeStyle.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "LabelAttributeStyle.h"

@implementation YAlbumDetailHeaderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end

@implementation YAlbumTitleCell : UITableViewCell
- (void)loadData:(NSDictionary *)data {
    if ([wTools objectExists:data[@"name"]])
        _titleLabel.text = data[@"name"];
}

+ (CGFloat)estimatedHeight:( NSDictionary *)data {
    return 64;
}
@end

@implementation YAlbumLocationCell : UITableViewCell
- (void)loadData:(NSDictionary *)data {
    if ([wTools objectExists:data[@"album"][@"location"]]) {
        NSString *l = data[@"album"][@"location"];
        _locIcon.hidden = l.length < 1;
        _locationLabel.text = l;
    } else {
        _locationLabel.text = @"";
        _locIcon.hidden = YES;
    }
    
    _viewedCountLabel.text = @"0次瀏覽";
    if ([wTools objectExists:data[@"albumstatistics"]]) {
        NSInteger viewed = [data[@"albumstatistics"][@"viewed"] integerValue];
        if (viewed >= 100000) {
            viewed /= 10000;
            [LabelAttributeStyle changeGapString: _viewedCountLabel content: [NSString stringWithFormat: @"%ldM次瀏覽", (long)viewed]];
        } else if (viewed >= 10000) {
            viewed /= 1000;
            [LabelAttributeStyle changeGapString: _viewedCountLabel content: [NSString stringWithFormat:  @"%ldK次瀏覽", (long)viewed]];
        } else {
            
            [LabelAttributeStyle changeGapString: _viewedCountLabel content: [NSString stringWithFormat: @"%ld次瀏覽", (long)viewed]];
        }
        
    }
}
+ (CGFloat)estimatedHeight:(NSDictionary *)data {
    
    return 36;
}
@end
@implementation YAlbumContentTypeCell : UITableViewCell
+ (CGFloat)estimatedHeight:(NSDictionary *)data {
    
    if ([YAlbumContentTypeCell ifVisible:data[@"usefor"]])
        return 36;
    return 0;
}
+ (BOOL)ifVisible:(NSDictionary *)data {
    
    BOOL gotAudio;
    BOOL gotVideo;
    BOOL gotExchange;
    BOOL gotSlot;
    
    @try {
        gotAudio = [data[@"audio"] boolValue];
        gotVideo = [data[@"video"] boolValue];
        gotExchange = [data[@"exchange"] boolValue];
        gotSlot = [data[@"slot"] boolValue];
        
    } @catch (NSException *exception) {
        return false;
    }
    
    return  (gotAudio || gotVideo || gotExchange || gotSlot);
}
- (void)loadData:(NSDictionary *)data {
    
    BOOL gotAudio;
    BOOL gotVideo;
    BOOL gotExchange;
    BOOL gotSlot;
    self.audIcon.hidden = YES;
    self.vidIcon.hidden = YES;
    self.giftIcon.hidden = YES;
    @try {
        gotAudio = [data[@"audio"] boolValue];
        gotVideo = [data[@"video"] boolValue];
        gotExchange = [data[@"exchange"] boolValue];
        gotSlot = [data[@"slot"] boolValue];
    } @catch (NSException *exception) {
        return;
    }
    if (gotAudio) {
        _audIcon.hidden = NO;
        
        if (gotVideo) {
            _vidIcon.hidden = NO;
            if (gotExchange || gotSlot) {
                _giftIcon.hidden = NO;
            }
        }
    } else if (gotVideo) {
        _vidIcon.hidden = NO;
        if (gotExchange || gotSlot) {
            _giftIcon.hidden = NO;
        }
    } else if (gotExchange || gotSlot) {
        _giftIcon.hidden = NO;
    }
    self.audioLeading.constant = ((_vidIcon.hidden)?-_vidIcon.frame.size.width-8:8);//);
    self.giftLeading.constant = ((_vidIcon.hidden)?8:0)+((_audIcon.hidden)?-_audIcon.frame.size.width:0);
}

@end
@implementation YAlbumDescCell : UITableViewCell
- (void)loadData:(NSDictionary *)data {
    self.albumDesc.text = [data[@"description"] isKindOfClass:[NSNull class]]? @"" : data[@"description"];
    self.albumDesc.editable = NO;
    self.albumDesc.dataDetectorTypes = UIDataDetectorTypeAll;
    UIColor *c = self.albumDesc.textColor;
    CGFloat s = self.albumDesc.font.pointSize;
    [LabelAttributeStyle changeGapStringForTextView:self.albumDesc content:[data[@"description"] isKindOfClass:[NSNull class]]? @"" : data[@"description"] color:c fontSize:s];
}
+ (CGFloat)estimatedHeight:(NSDictionary *)data {
    
    CGRect est = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-32, CGFLOAT_MAX);
    NSString *t = @"";
    if (![data[@"description"] isKindOfClass:[NSNull class]])
        t = data[@"description"];
    if (t.length) {
        NSStringDrawingContext *ctx = [[NSStringDrawingContext alloc] init];
        CGRect ss = [t boundingRectWithSize:est.size options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18],NSKernAttributeName:@1} context:ctx];
        ctx = nil;
        return ss.size.height+72;
    }
    
    return 0;
}
@end
@implementation YAlbumFollowerCell : UITableViewCell
- (void)loadData:(NSDictionary *)data {
    int c = 0;
    if (data[@"likes"])
        c = (int)[data[@"likes"] integerValue];
    [LabelAttributeStyle changeGapString: self.followerCount content: [NSString stringWithFormat:@"%d人釘過", c]];
}
+ (CGFloat)estimatedHeight:(NSDictionary *)data {
    
    return 52;
}
@end
@implementation YAlbumPointCell: UITableViewCell
- (void)loadData:(NSDictionary *)data {
    int c = 0;
    if (data[@"exchange"])
        c = (int)[data[@"exchange"] integerValue];
    [LabelAttributeStyle changeGapString: self.pointCount content: [NSString stringWithFormat:@"%d人贊助", c]];
    
}
+ (CGFloat)estimatedHeight:(NSDictionary *)data {
    NSInteger i = [[wTools getUserID] intValue];
    NSInteger i1 = [data[@"user_id"] intValue];
    return (i != i1)? 0 : 52;
}
@end
@implementation YAlbumMessageCell: UITableViewCell
- (void)loadData:(NSDictionary *)data {
    int c = 0;
    if (data[@"messageboard"])
        c = (int)[data[@"messageboard"] integerValue];
    [LabelAttributeStyle changeGapString: self.messageCount content: [NSString stringWithFormat:@"%d則留言", c]];
}
+ (CGFloat)estimatedHeight:(NSDictionary *)data {
    
    return 52;
}
@end
@implementation YAlbumCreatorCell: UITableViewCell
- (void)loadData:(NSDictionary *)data {
    NSDictionary *u = data[@"user"];
    if ([wTools objectExists:u[@"name"]])
        _creatorName.text = u[@"name"];
    [LabelAttributeStyle changeGapString: _creatorName content: u[@"name"]];
    _creatorName.textAlignment = NSTextAlignmentJustified;
    if ([wTools objectExists:u[@"picture"]])
        [_creatorAvatar sd_setImageWithURL:[NSURL URLWithString:u[@"picture"]] placeholderImage:[UIImage imageNamed:@"member_back_head"]];
}
+ (CGFloat)estimatedHeight:(NSDictionary *)data {
    
    return 148;
}
@end
@implementation YAlbumEventCell: UITableViewCell
- (void)loadData:(NSDictionary *)data {
    NSLog(@"%@", data);
    NSDictionary *ev = data[@"event"];
    //NSDictionary *evj = data[@"eventjoin"];
    self.eventDesc.text = @"";
    if ([wTools objectExists: ev] && [wTools objectExists: ev[@"name"]]) {
        NSString *evs = ev[@"name"];
        
        [LabelAttributeStyle changeGapString: _eventDesc content: evs];
        _eventDesc.textAlignment = NSTextAlignmentJustified;
        _eventDesc.lineBreakMode = NSLineBreakByTruncatingTail;
    }
}
+ (CGFloat)estimatedHeight:(NSDictionary *)data {
    
    if ([wTools objectExists:data])
        return 180;
    return 0;
}
@end


