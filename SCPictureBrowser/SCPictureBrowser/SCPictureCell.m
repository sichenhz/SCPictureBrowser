//
//  SCPictureCell.m
//  SCPictureBrowser
//
//  Created by sichenwang on 16/3/21.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import "SCPictureCell.h"
#import "SDWebImageManager.h"
#import "SCPictureBrowser.h"

CGFloat const kMargin = 20;

@interface SCPictureCell()<UIScrollViewDelegate>

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic) BOOL enableDoubleTap;

@end

@implementation SCPictureCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        // scrollView
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width - kMargin, frame.size.height)];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.delegate = self;
        scrollView.minimumZoomScale = 1;
        scrollView.maximumZoomScale = 2;
        [self addSubview:scrollView];
        _scrollView = scrollView;
        
        // imageView
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [scrollView addSubview:imageView];
        _imageView = imageView;
        
        // gesture
        UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapHandler:)];
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapHandler:)];
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHandler:)];
        doubleTapGesture.numberOfTapsRequired = 2;
        [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];

        [self addGestureRecognizer:singleTapGesture];
        [self addGestureRecognizer:doubleTapGesture];
        [self addGestureRecognizer:longPressGesture];
    }
    return self;
}

- (void)configureCellWithURL:(NSURL *)url sourceView:(UIView *)sourceView isFirstShow:(BOOL)isFirstShow {

    // 尝试从缓存里取图片
    [[SDWebImageManager sharedManager].imageCache queryDiskCacheForKey:url.absoluteString done:^(UIImage *image, SDImageCacheType cacheType) {
        // 如果没有取到图片
        if (!image) {
            // 设置缩略图
            self.imageView.image = [self thumbnailImage:sourceView];
            self.imageView.frame = CGRectMake(0, 0, sourceView.frame.size.width, sourceView.frame.size.height);
            self.imageView.center = [UIApplication sharedApplication].keyWindow.center;
            
            // 加loading
            
            // 下载图片
            [[SDWebImageManager sharedManager] downloadImageWithURL:url options:SDWebImageLowPriority | SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                if (image) {
                    self.enableDoubleTap = YES;
                    self.imageView.image = image;
                    CGSize showSize = [self showSize:image.size];
                    
                    [UIView animateWithDuration:0.4 animations:^{
                        self.imageView.frame = CGRectMake(0, 0, showSize.width, showSize.height);
                        self.imageView.center = [UIApplication sharedApplication].keyWindow.center;
                    }];
                }
            }];
        }
        // 取到了图片
        else {
            self.enableDoubleTap = YES;
            self.imageView.image = image;
            CGSize showSize = [self showSize:image.size];
            
            // 第一次显示图片，转换坐标系，然后动画放大
            if (isFirstShow) {
                self.imageView.frame = [self convertRect:sourceView.frame toView:self];
                [UIView animateWithDuration:0.4 animations:^{
                    self.imageView.frame = CGRectMake(0, 0, showSize.width, showSize.height);
                    self.imageView.center = [UIApplication sharedApplication].keyWindow.center;
                }];
            }
            else {
                // 不是第一次显示图片，直接赋值frame
                if (CGRectEqualToRect(self.imageView.frame, CGRectZero)) {
                    self.imageView.frame = CGRectMake(0, 0, showSize.width, showSize.height);
                    self.imageView.center = [UIApplication sharedApplication].keyWindow.center;
                }
            }
        }
    }];
}

#pragma mark - GestureRecognizer

- (void)singleTapHandler:(UITapGestureRecognizer *)singleTap {
    if (self.scrollView.zoomScale > 1) {
        [self.scrollView setZoomScale:1 animated:YES];
    } else {
        if ([self.delegate respondsToSelector:@selector(pictureCellSingleTap:)]) {
            [self.delegate pictureCellSingleTap:self];
        }
    }
}

- (void)doubleTapHandler:(UITapGestureRecognizer *)doubleTap {
    
    if (!self.enableDoubleTap) {
        return;
    }
    
    CGPoint point = [doubleTap locationInView:doubleTap.view];
    if (self.scrollView.zoomScale <= 1) {
        [self.scrollView zoomToRect:CGRectMake(point.x, point.y, 1, 1) animated:YES];
    } else {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    }
}

- (void)longPressHandler:(UILongPressGestureRecognizer *)longPress {
    NSLog(@"longPress");
}

/**
 *  计算适应全屏的size
 */
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

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    CGPoint actualCenter = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                       scrollView.contentSize.height * 0.5 + offsetY);

    self.imageView.center = actualCenter;
}

@end