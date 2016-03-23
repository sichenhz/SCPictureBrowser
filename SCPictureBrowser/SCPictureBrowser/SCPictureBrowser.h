//
//  SCPictureBrowser.h
//  SCPictureBrowser
//
//  Created by sichenwang on 16/3/21.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCPictureItem : NSObject

+ (instancetype)itemWithURL:(nonnull NSURL *)url sourceView:(nonnull UIView *)sourceView;

@property (nonnull, nonatomic, strong, readonly) NSURL *url;
@property (nonnull, nonatomic, strong, readonly) UIView *sourceView;

@end

@interface SCPictureBrowser : UIViewController

+ (instancetype)browserWithItems:(nonnull NSArray *)items currentPage:(NSInteger)currentPage numberOfPrefetchURLs:(NSInteger)numberOfPrefetchURLs;

@property (nonnull, nonatomic, strong, readonly) NSArray <SCPictureItem *> *items;
@property (nonatomic, readonly) NSInteger currentPage;

/**
 *  浏览时预加载前后n张图片，n默认为0（微信朋友圈的策略：在wifi情况下预加载前后2张，在非wifi环境下预加载前后1张）
 */
@property (nonatomic) NSInteger numberOfPrefetchURLs;

- (void)show;

@end

NS_ASSUME_NONNULL_END
