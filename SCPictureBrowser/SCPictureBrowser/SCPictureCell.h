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
@property (nonatomic, weak) id<SCPictureDelegate> delegate;
@property (nonatomic) BOOL enableDoubleTap;

- (void)showImageWithItem:(SCPictureItem *)item;
- (CGRect)imageViewRectWithImageSize:(CGSize)imageSize;
- (void)setMaximumZoomScale;

@end

@protocol SCPictureDelegate <NSObject>

- (void)pictureCellSingleTap:(SCPictureCell *)pictureCell;
- (void)pictureCellDoubleTap:(SCPictureCell *)pictureCell;
- (void)pictureCellLongPress:(SCPictureCell *)pictureCell;

@end

NS_ASSUME_NONNULL_END
