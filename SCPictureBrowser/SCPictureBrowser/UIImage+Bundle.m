//
//  UIImage+Bundle.m
//  SCPictureBrowser
//
//  Created by sichenwang on 16/5/12.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import "UIImage+Bundle.h"

@implementation UIImage (Bundle)

+ (UIImage *)bundleImageNamed:(NSString *)name {
    static NSBundle *frameworkBundle = nil;
    if (frameworkBundle == nil) {
        NSString *frameworkDirPath = [[NSBundle mainBundle] privateFrameworksPath];
        NSString *frameworkPath = [frameworkDirPath stringByAppendingPathComponent:@"SCPictureBrowser.framework"];
        NSBundle *framework = [NSBundle bundleWithPath:frameworkPath];
        
        NSString *frameworkBundlePath = [framework pathForResource:@"SCPictureBrowser" ofType:@"bundle"];
        frameworkBundle = [NSBundle bundleWithPath:frameworkBundlePath];
    }
    
    CGFloat scale = [UIScreen mainScreen].scale;
    NSData *data = nil;
    if (scale > 2.0f) {
        NSString *retinaPath = [frameworkBundle pathForResource:[name stringByAppendingString:@"@3x"] ofType:@"png"];
        data = [NSData dataWithContentsOfFile:retinaPath];
    }
    if (scale > 1.0f && data==nil) {
        NSString *retinaPath = [frameworkBundle pathForResource:[name stringByAppendingString:@"@2x"] ofType:@"png"];
        data = [NSData dataWithContentsOfFile:retinaPath];
    }
    if (data==nil) {
        NSString *path = [frameworkBundle pathForResource:name ofType:@"png"];
        data = [NSData dataWithContentsOfFile:path];
    }
    if (data) {
        return [UIImage imageWithData:data scale:scale];
    }
    return [UIImage imageNamed:name];
}

@end
