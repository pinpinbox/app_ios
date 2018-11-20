//
//  FTWCache.m
//  wPinpinbox
//
//  Created by David on 2/22/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "FTWCache.h"

static NSTimeInterval cacheTime =  (double)604800;

@implementation FTWCache

+ (void)resetCache {
    //NSLog(@"resetCache");
    //NSLog(@"[FTWCache cacheDirectory]: %@", [FTWCache cacheDirectory]);
    [[NSFileManager defaultManager] removeItemAtPath: [FTWCache cacheDirectory] error: nil];
}

+ (NSString *)cacheDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    //NSLog(@"paths: %@", paths);
    
    NSString *cacheDirectory = [paths objectAtIndex: 0];
    //NSLog(@"cacheDirectory: %@", cacheDirectory);
    
    cacheDirectory = [cacheDirectory stringByAppendingPathComponent: @"FTWCaches"];
    //NSLog(@"cacheDirectory: %@", cacheDirectory);
    
    return cacheDirectory;
}

+ (NSData *)objectForKey:(NSString *)key {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filename = [self.cacheDirectory stringByAppendingPathComponent: key];
    //NSLog(@"filename: %@", filename);
    
    if ([fileManager fileExistsAtPath: filename]) {
        NSDate *modificationDate = [[fileManager attributesOfItemAtPath: filename error: nil] objectForKey: NSFileModificationDate];
        
        if ([modificationDate timeIntervalSinceNow] > cacheTime) {
            //NSLog(@"modificationDate timeIntervalSinceNow > cacheTime");
            //NSLog(@"modificationDate timeIntervalSinceNow: %f", [modificationDate timeIntervalSinceNow]);
            //NSLog(@"cacheTime: %f", cacheTime);
            
            [fileManager removeItemAtPath: filename error: nil];
        } else {
            NSData *data = [NSData dataWithContentsOfFile: filename];
            return data;
        }
    }
    return nil;
}

+ (void)setObject:(NSData *)data forKey:(NSString *)key {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filename = [self.cacheDirectory stringByAppendingPathComponent: key];
    
    BOOL isDir = YES;
    
    if (![fileManager fileExistsAtPath: self.cacheDirectory isDirectory: &isDir]) {
        [fileManager createDirectoryAtPath: self.cacheDirectory withIntermediateDirectories: NO attributes: nil error: nil];
    }
    
    NSError *error;
    @try {
        [data writeToFile: filename options: NSDataWritingAtomic error: &error];
    } @catch (NSException *e) {
        //TODO: error handling maybe
    }
}

@end
