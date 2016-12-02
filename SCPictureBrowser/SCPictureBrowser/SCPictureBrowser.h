//
//  SCPictureBrowser.h
//  SCPictureBrowser
//
//  Created by sichenwang on 16/3/21.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCPictureItem.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SCPictureBrowserDelegate;

@interface SCPictureBrowser : UIViewController

@property (nonnull, nonatomic, strong) NSArray <SCPictureItem *> *items;
@property (nonatomic) NSInteger index;

@property (nonatomic, weak) id<SCPictureBrowserDelegate> delegate;

// 浏览时预加载前后n张图片，默认为0（微信朋友圈的策略：在wifi情况下预加载前后2张，在非wifi环境下预加载前后1张）
@property (nonatomic) NSInteger numberOfPrefetchURLs;

// 总是隐藏pageControl，默认为NO
@property (nonatomic) BOOL alwaysPageControlHidden;

// 是否支持删除功能，默认为NO
@property (nonatomic) BOOL supportDelete;

// 是否隐藏状态栏，需要设置成和来源页面一致，默认为NO
@property (nonatomic) BOOL statusBarHidden;
// 状态栏颜色，需要设置成和来源页面一致，默认为UIStatusBarStyleLightContent
@property (nonatomic) UIStatusBarStyle statusBarStyle;

// 图片缩放时的contentMode, 为了缩放时的动画能匹配，该值应该和放大前的来源UIImageView模式一样，默认为UIViewContentModeScaleAspectFill
@property (nonatomic) UIViewContentMode contentMode;

// 如果通过present或push方式来浏览图片，需外部自己实现结束浏览的事件
- (void)show;

@end

@protocol SCPictureBrowserDelegate <NSObject>

@optional

- (void)pictureBrowser:(SCPictureBrowser *)browser didChangePageAtIndex:(NSInteger)index;
- (void)pictureBrowser:(SCPictureBrowser *)browser didDeleteItems:(NSArray *)items indexSet:(NSIndexSet *)indexSet;

@end

NS_ASSUME_NONNULL_END
