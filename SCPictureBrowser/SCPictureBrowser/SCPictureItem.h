//
//  SCPictureItem.h
//  SCPictureBrowser
//
//  Created by sichenwang on 16/4/5.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCPictureItem : NSObject

@property (nullable, nonatomic, strong) NSURL *url;
@property (nullable, nonatomic, strong) UIImage *originImage;
@property (nullable, nonatomic, strong) UIView *sourceView;

@end

NS_ASSUME_NONNULL_END