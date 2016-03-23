//
//  SCPictureCell.h
//  SCPictureBrowser
//
//  Created by sichenwang on 16/3/21.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const SCPictureCellRightMargin;

@protocol SCPictureDelegate;

@interface SCPictureCell : UICollectionViewCell

@property (nonatomic, weak, readonly) UIImageView *imageView;
@property (nonatomic, weak) id<SCPictureDelegate> delegate;
@property (nonatomic) BOOL enableDoubleTap;

- (void)configureCellWithURL:(NSURL *)url sourceView:(UIView *)sourceView;

- (CGRect)imageViewRectWithImageSize:(CGSize)imageSize;

@end

@protocol SCPictureDelegate <NSObject>

- (void)pictureCellSingleTap:(SCPictureCell *)pictureCell;
- (void)pictureCellLongPress:(SCPictureCell *)pictureCell;

@end
