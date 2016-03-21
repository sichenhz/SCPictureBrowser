//
//  SCPictureCell.m
//  SCPictureBrowser
//
//  Created by sichenwang on 16/3/21.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import "SCPictureCell.h"
#import "SDWebImageManager.h"

@interface SCPictureCell()

@property (nonatomic, weak) UIImageView *imageView;

@end

@implementation SCPictureCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [self addSubview:imageView];
        _imageView = imageView;
    }
    return self;
}


- (void)setPicture:(SCPicture *)picture {
    _picture = picture;
    
    __block BOOL isDownLoading = NO;
    [[SDWebImageManager sharedManager] downloadImageWithURL:picture.url options:SDWebImageLowPriority | SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        // 第一次下载图片，先截取小图放中间，加loading
        if (!isDownLoading) {
            isDownLoading = YES;
            self.imageView.image = [self thumbnailImage:picture.sourceView];
            self.imageView.frame = CGRectMake(0, 0, picture.sourceView.frame.size.width, picture.sourceView.frame.size.height);
            self.imageView.center = [UIApplication sharedApplication].keyWindow.center;
        }
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        
        if (image) {
            
            self.imageView.image = image;
            CGSize showSize = [self showSize:image.size];
            
            if (cacheType == SDImageCacheTypeNone) {
                // 下载完毕
                isDownLoading = NO;
                // 动画放大
                [UIView animateWithDuration:0.4 animations:^{
                    self.imageView.frame = CGRectMake(0, 0, showSize.width, showSize.height);
                    self.imageView.center = [UIApplication sharedApplication].keyWindow.center;
                }];
            } else {
                // 第一次显示图片，转换坐标系，然后动画放大
                if (picture.isFirstShow) {
                    picture.firstShow = NO;
                    self.imageView.frame = [picture.sourceView convertRect:picture.sourceView.bounds toView:self];
                    [UIView animateWithDuration:0.4 animations:^{
                        self.imageView.frame = CGRectMake(0, 0, showSize.width, showSize.height);
                        self.imageView.center = [UIApplication sharedApplication].keyWindow.center;
                    }];
                }
                // 不是第一次显示图片，直接赋值frame
                else {
                    self.imageView.frame = CGRectMake(0, 0, showSize.width, showSize.height);
                    self.imageView.center = [UIApplication sharedApplication].keyWindow.center;
                }
            }
        }
    }];
}

- (CGSize)showSize:(CGSize)imageSize {
    CGFloat heightRatio = imageSize.height / [UIScreen mainScreen].bounds.size.height;
    CGFloat widthRatio = imageSize.width / [UIScreen mainScreen].bounds.size.width;
    
    if (heightRatio > 1 && widthRatio <= 1) {
        return [self ratioSize:imageSize ratio:heightRatio];
    }
    if (heightRatio <= 1 && widthRatio > 1) {
        return [self ratioSize:imageSize ratio:widthRatio];
    }
    return [self ratioSize:imageSize ratio:MAX(heightRatio, widthRatio)];
}

- (CGSize)ratioSize:(CGSize)originSize ratio:(CGFloat)ratio {
    return CGSizeMake(originSize.width / ratio, originSize.height / ratio);
}

- (UIImage *)thumbnailImage:(UIView *)sourceView {
    UIGraphicsBeginImageContextWithOptions(sourceView.frame.size, YES, 0.0);
    [sourceView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
