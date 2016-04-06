//
//  SCPictureCell.h
//  SCPictureBrowser
//
//  Created by sichenwang on 16/3/21.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SCPictureItem;

NS_ASSUME_NONNULL_BEGIN

extern CGFloat const SCPictureCellRightMargin;

@protocol SCPictureDelegate;

@interface SCPictureCell : UICollectionViewCell

@property (nonatomic, strong, readonly, nonnull) UIImageView *imageView;
@property (nonatomic, strong, readonly, nonnull) UIScrollView *scrollView;

@property (nonatomic, weak) id<SCPictureDelegate> delegate;
@property (nonatomic) BOOL enableDoubleTap;
@property (nonatomic) BOOL enableDynamicsDismiss;

- (void)showImageWithItem:(SCPictureItem *)item;
- (CGRect)imageViewRectWithImageSize:(CGSize)imageSize;
- (void)setMaximumZoomScale;

@end

@protocol SCPictureDelegate <NSObject>

- (void)pictureCell:(SCPictureCell *)pictureCell singleTap:(UITapGestureRecognizer *)singleTap;
- (void)pictureCell:(SCPictureCell *)pictureCell doubleTap:(UITapGestureRecognizer *)doubleTap;
- (void)pictureCell:(SCPictureCell *)pictureCell longPress:(UILongPressGestureRecognizer *)longPress;
- (void)pictureCell:(SCPictureCell *)pictureCell pan:(UIPanGestureRecognizer *)pan;

@end

NS_ASSUME_NONNULL_END
