//
//  LabelAttributeStyle.m
//  wPinpinbox
//
//  Created by David on 11/01/2018.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "LabelAttributeStyle.h"
#import "UIColor+Extensions.h"

@implementation LabelAttributeStyle

+ (void)changeGapString:(UILabel *)label content:(NSString *)content {
    NSMutableDictionary *attDic = [NSMutableDictionary dictionary];
    //[attDic setValue:[UIFont systemFontOfSize:16] forKey:NSFontAttributeName];      // 字体大小
    //[attDic setValue:[UIColor redColor] forKey:NSForegroundColorAttributeName];     // 字体颜色
    [attDic setValue:@1 forKey:NSKernAttributeName];                                // 字间距
    //[attDic setValue:[UIColor cyanColor] forKey:NSBackgroundColorAttributeName];    // 设置字体背景色
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:content attributes:attDic];
    
    //NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    //style.lineSpacing = 6;                                                          // 设置行之间的间距
    //[attStr addAttribute:NSParagraphStyleAttributeName value:style range: NSMakeRange(0, content.length)];
    
    //.attributedText = attStr;
    label.attributedText = attStr;
}

+ (NSInteger)checkTagString:(NSString *)searchedString {
    NSLog(@"");
    NSLog(@"checkTagString");
    NSRange searchedRange = NSMakeRange(0, searchedString.length);
    
    // Regular Expression Setting
    NSString *pattern = @"\\[{1}[0-9]+\\:{1}[^\\[\\]:]+\\]{1}";
    NSError *error = nil;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern: pattern
                                                                           options: 0
                                                                             error: &error];
    NSArray *matches = [regex matchesInString: searchedString
                                      options: 0
                                        range: searchedRange];
    
    NSLog(@"searchedString: %@", searchedString);
//    NSLog(@"matches: %@", matches);
    
    return matches.count;
}

+ (NSMutableAttributedString *)convertToTagString:(NSString *)searchedString {
    NSLog(@"");
    NSLog(@"convertToTagString");
    NSRange searchedRange = NSMakeRange(0, searchedString.length);
    
    // Regular Expression Setting
    NSString *pattern = @"\\[{1}[0-9]+\\:{1}[^\\[\\]:]+\\]{1}";
    NSError *error = nil;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern: pattern
                                                                           options: 0
                                                                             error: &error];
    NSArray *matches = [regex matchesInString: searchedString
                                      options: 0
                                        range: searchedRange];
    
    NSLog(@"searchedString: %@", searchedString);
//    NSLog(@"matches: %@", matches);
    
    // Array for Tag Info
    NSMutableArray *tagArray = [[NSMutableArray alloc] init];
    
    // Loop for getting Tag Info
    for (NSTextCheckingResult *match in matches) {
        // Tag Name Filtering ex: [userId: userName]
        NSLog(@"match.range: %@", NSStringFromRange(match.range));
        
        NSString *matchText = [searchedString substringWithRange: [match range]];
        NSLog(@"matchText: %@", matchText);
        
        // Getting range for highlighting text
//        NSRange range = [searchedString rangeOfString: matchText];
        NSLog(@"range.length: %lu", (unsigned long)match.range.length);
        NSLog(@"range.location: %lu", (unsigned long)match.range.location);
        
        // String Filtering
        NSArray *array = [matchText componentsSeparatedByString: @":"];
        NSLog(@"array: %@", array);
        
        // Getting UserId
        NSString *userId = [array objectAtIndex: 0];
        userId = [userId substringFromIndex: 1];
        NSLog(@"userId: %@", userId);
        
        // Getting UserName
        NSString *userName = [array objectAtIndex: 1];
        userName = [userName substringToIndex: userName.length - 1];
        NSLog(@"userName: %@", userName);
        
        // Dictinoary for TagInfo setup
        NSMutableDictionary *tagDic = [[NSMutableDictionary alloc] init];
        [tagDic setObject: userName forKey: @"userName"];
        [tagDic setObject: userId forKey: @"userId"];
        [tagDic setObject: matchText forKey: @"sendingType"];
        [tagDic setObject: [NSNumber numberWithUnsignedInteger: match.range.location] forKey: @"location"];
        [tagDic setObject: [NSNumber numberWithUnsignedInteger: match.range.length] forKey: @"length"];
        
        [tagArray addObject: tagDic];
    }
    
//    NSLog(@"tagArray: %@", tagArray);
    
    // Record tag string origin
    NSInteger strOrigin = 0;
    
    for (int i = 0; i < tagArray.count; i++) {
        NSMutableDictionary *dic = [tagArray objectAtIndex: i];
        
        // String Replacement without [:] & userId
        searchedString = [searchedString stringByReplacingOccurrencesOfString: [dic objectForKey: @"sendingType"] withString: [dic objectForKey: @"userName"]];
        
        // Getting info for changing
        NSInteger locationInt = [[dic objectForKey: @"location"] integerValue];
        NSString *userId = [dic objectForKey: @"userId"];
        
        // Change location info
        [dic setObject: [NSNumber numberWithUnsignedInteger: locationInt - strOrigin] forKey: @"location"];
        // 3 is three symbols like [ : ]
        // So, strOrigin need to subtract userId.length and 3 symbols
        strOrigin = strOrigin + userId.length + 3;
        
        // Change length info
        NSUInteger length = [[dic objectForKey: @"length"] integerValue];
        [dic setObject: [NSNumber numberWithUnsignedInteger: length - userId.length - 3] forKey: @"length"];
    }
    NSLog(@"searchedString: %@", searchedString);
    
//    NSLog(@"tagArray: %@", tagArray);
    
//    NSMutableAttributedString *mutableStr = [[NSMutableAttributedString alloc] initWithString: searchedString];
    
    NSMutableDictionary *attDic = [NSMutableDictionary dictionary];
    //[attDic setValue:[UIFont systemFontOfSize:16] forKey:NSFontAttributeName];      // 字体大小
    //[attDic setValue:[UIColor redColor] forKey:NSForegroundColorAttributeName];     // 字体颜色
    [attDic setValue:@1 forKey:NSKernAttributeName];                                // 字间距
    //[attDic setValue:[UIColor firstMain] forKey:NSBackgroundColorAttributeName];    // 设置字体背景色
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString: searchedString attributes:attDic];
    
    NSLog(@"");
    NSLog(@"LabelAttributeStyle");
    NSLog(@"tagArray: %@", tagArray);
    
    // Setting Text Highlighted Color
    for (int i = 0; i < tagArray.count; i++) {
        NSLog(@"");
        NSLog(@"Setting Text Highlighted Color");
        NSLog(@"i: %d", i);
        NSMutableDictionary *dic = [tagArray objectAtIndex: i];
        [attStr addAttribute: NSForegroundColorAttributeName
                       value: [UIColor firstMain]
                       range: NSMakeRange([[dic objectForKey: @"location"] integerValue], [[dic objectForKey: @"length"] integerValue])];
    }
    
//    return mutableStr;
    return attStr;
}

//+ (NSMutableAttributedString *)changeTextColor:(NSRange)tagRange
//                          stringForReplacement:(NSString *)stringForReplacement {
//    NSMutableDictionary *attDic = [NSMutableDictionary dictionary];
//    //[attDic setValue:[UIFont systemFontOfSize:16] forKey:NSFontAttributeName];      // 字体大小
//    //[attDic setValue:[UIColor redColor] forKey:NSForegroundColorAttributeName];     // 字体颜色
//    [attDic setValue:@1 forKey:NSKernAttributeName];                                // 字间距
//    //[attDic setValue:[UIColor firstMain] forKey:NSBackgroundColorAttributeName];    // 设置字体背景色
//    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString: stringForReplacement attributes:attDic];
//    [attStr addAttribute: NSForegroundColorAttributeName
//                   value: [UIColor firstMain]
//                   range: tagRange];
//    
//    return attStr;
//}

@end
