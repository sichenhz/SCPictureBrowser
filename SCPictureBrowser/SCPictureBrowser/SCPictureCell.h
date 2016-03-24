//
//  SCPictureCell.h
//  SCPictureBrowser
//
//  Created by sichenwang on 16/3/21.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern CGFloat const SCPictureCellRightMargin;

@protocol SCPictureDelegate;

@interface SCPictureCell : UICollectionViewCell

@property (nonatomic, strong, readonly, nonnull) UIImageView *imageView;
@property (nonatomic, weak) id<SCPictureDelegate> delegate;
@property (nonatomic) BOOL enableDoubleTap;

- (void)configureCellWithURL:(nonnull NSURL *)url sourceView:(nonnull UIView *)sourceView;
- (CGRect)imageViewRectWithImageSize:(CGSize)imageSize;

@end

@protocol SCPictureDelegate <NSObject>

- (void)pictureCellSingleTap:(SCPictureCell *)pictureCell;
- (void)pictureCellLongPress:(SCPictureCell *)pictureCell;

@end

NS_ASSUME_NONNULL_END
