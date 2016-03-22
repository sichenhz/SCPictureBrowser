//
//  SCPictureCell.h
//  SCPictureBrowser
//
//  Created by sichenwang on 16/3/21.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SCPictureCell;

extern CGFloat const kMargin;

@protocol SCPictureDelegate <NSObject>

- (void)pictureCellSingleTap:(SCPictureCell *)pictureCell;

@end

@interface SCPictureCell : UICollectionViewCell

@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) id<SCPictureDelegate> delegate;

- (void)configureCellWithURL:(NSURL *)url sourceView:(UIView *)sourceView isFirstShow:(BOOL)isFirstShow;

@end
