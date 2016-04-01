//
//  SCPictureBrowser.h
//  SCPictureBrowser
//
//  Created by sichenwang on 16/3/21.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SCPictureBrowserDelegate;

@interface SCPictureItem : NSObject

@property (nullable, nonatomic, strong) NSURL *url;

@property (nullable, nonatomic, strong) UIImage *originImage;

@property (nonnull, nonatomic, strong) UIView *sourceView;

@end

@interface SCPictureBrowser : UIViewController

@property (nonnull, nonatomic, strong) NSArray <SCPictureItem *> *items;
@property (nonatomic) NSInteger currentPage;

@property (nonatomic, weak) id<SCPictureBrowserDelegate> delegate;

/**
 *  浏览时预加载前后n张图片，默认为0（微信朋友圈的策略：在wifi情况下预加载前后2张，在非wifi环境下预加载前后1张）
 */
@property (nonatomic) NSInteger numberOfPrefetchURLs;

/**
 *  总是隐藏pageControl，默认为NO
 */
@property (nonatomic) BOOL alwaysPageControlHidden;

- (void)show;

@end

@protocol SCPictureBrowserDelegate <NSObject>

@optional

- (void)pictureBrowser:(SCPictureBrowser *)browser didChangePageAtIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
