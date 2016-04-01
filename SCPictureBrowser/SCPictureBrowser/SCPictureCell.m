//
//  SCPictureCell.m
//  SCPictureBrowser
//
//  Created by sichenwang on 16/3/21.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import "SCPictureCell.h"
#import "SDWebImageManager.h"
#import "SCActivityIndicatorView.h"

CGFloat const SCPictureCellRightMargin = 20;
static CGFloat const SCMinMaximumZoomScale = 2;

@interface SCPictureCell()<UIScrollViewDelegate>

@end

@implementation SCPictureCell
{
    UIScrollView *_scrollView;
    SCActivityIndicatorView *_indicatorView;
    NSURL *_url;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self initializeScrollViewWithFrame:frame];
        [self initializeImageView];
        [self initializeIndicatorView];
        [self initializeGesture];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.enableDoubleTap = NO;
    
    if (_indicatorView.isAnimating) {
        [_indicatorView stopAnimating];
    }
}

#pragma mark - Private Method

- (void)initializeScrollViewWithFrame:(CGRect)frame {
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width - SCPictureCellRightMargin, frame.size.height)];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.delegate = self;
    [self addSubview:_scrollView];
}

- (void)initializeImageView {
    _imageView = [[UIImageView alloc] init];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    [_scrollView addSubview:_imageView];
}

- (void)initializeIndicatorView {
    _indicatorView = [[SCActivityIndicatorView alloc] init];
    _indicatorView.center = _scrollView.center;
    [self addSubview:_indicatorView];
}

- (void)initializeGesture {
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapHandler:)];
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapHandler:)];
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHandler:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
    [self addGestureRecognizer:singleTapGesture];
    [self addGestureRecognizer:doubleTapGesture];
    [self addGestureRecognizer:longPressGesture];
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

#pragma mark - Public Method

- (void)configureCellWithURL:(NSURL *)url sourceView:(UIView *)sourceView {
    
    _url = url;
    
    // 尝试从缓存里取图片
    [[SDWebImageManager sharedManager].imageCache queryDiskCacheForKey:url.absoluteString done:^(UIImage *image, SDImageCacheType cacheType) {
        // 如果没有取到图片
        if (!image) {
            // 设置缩略图
            if (sourceView) {
                self.imageView.image = [self thumbnailImage:sourceView];
                self.imageView.frame = CGRectMake(0, 0, sourceView.frame.size.width, sourceView.frame.size.height);
                self.imageView.center = [UIApplication sharedApplication].keyWindow.center;
            }
            
            // loading
            [_indicatorView startAnimating];
            
            // 下载图片
            [[SDWebImageManager sharedManager] downloadImageWithURL:url options:SDWebImageLowPriority | SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                
                if ([imageURL isEqual:_url]) {
                    // 结束loading
                    [_indicatorView stopAnimating];
                    
                    // 成功下载图片
                    if (image) {
                        self.enableDoubleTap = YES;
                        self.imageView.image = image;
                        
                        if (sourceView) {
                            [UIView animateWithDuration:0.4 animations:^{
                                self.imageView.frame = [self imageViewRectWithImageSize:image.size];
                            } completion:^(BOOL finished) {
                                [self setMaximumZoomScale];
                            }];
                        } else {
                            self.imageView.frame = [self imageViewRectWithImageSize:image.size];
                            [self setMaximumZoomScale];
                        }
                    }
                }
            }];
        }
        // 从缓存中取到了图片
        else {
            if (_scrollView.zoomScale > 1) {
                [_scrollView setZoomScale:1 animated:NO];
            }
            
            self.enableDoubleTap = YES;
            self.imageView.image = image;
            self.imageView.frame = [self imageViewRectWithImageSize:image.size];
            [self setMaximumZoomScale];
        }
    }];
}

- (CGRect)imageViewRectWithImageSize:(CGSize)imageSize {
    CGFloat heightRatio = imageSize.height / [UIScreen mainScreen].bounds.size.height;
    CGFloat widthRatio = imageSize.width / [UIScreen mainScreen].bounds.size.width;
    CGSize size = CGSizeZero;
    if (heightRatio > 1 && widthRatio <= 1) {
        size = [self ratioSize:imageSize ratio:heightRatio];
    }
    if (heightRatio <= 1 && widthRatio > 1) {
        size = [self ratioSize:imageSize ratio:widthRatio];
    }
    size = [self ratioSize:imageSize ratio:MAX(heightRatio, widthRatio)];
    CGFloat x = ([UIScreen mainScreen].bounds.size.width - size.width) / 2;
    CGFloat y = ([UIScreen mainScreen].bounds.size.height - size.height) / 2;
    return CGRectMake(x, y, size.width, size.height);
}

- (void)setMaximumZoomScale {
    if (_scrollView.frame.size.height > self.imageView.frame.size.height * SCMinMaximumZoomScale) {
        _scrollView.maximumZoomScale = self.frame.size.height / self.imageView.frame.size.height;
    } else {
        _scrollView.maximumZoomScale = SCMinMaximumZoomScale;
    }
}

#pragma mark - GestureRecognizer

- (void)singleTapHandler:(UITapGestureRecognizer *)singleTap {
    if ([self.delegate respondsToSelector:@selector(pictureCellSingleTap:)]) {
        [self.delegate pictureCellSingleTap:self];
    }
    
    if (_scrollView.zoomScale > _scrollView.minimumZoomScale) {
        [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:YES];
    } else if (_indicatorView.isAnimating) {
        [_indicatorView stopAnimating];
    }
}

- (void)doubleTapHandler:(UITapGestureRecognizer *)doubleTap {
    if ([self.delegate respondsToSelector:@selector(pictureCellDoubleTap:)]) {
        [self.delegate pictureCellDoubleTap:self];
    }
    
    if (!self.enableDoubleTap) {
        return;
    }
    if (_scrollView.zoomScale > _scrollView.minimumZoomScale) {
        [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:YES];
    } else {
        CGPoint point = [doubleTap locationInView:doubleTap.view];
        [_scrollView zoomToRect:CGRectMake(point.x, point.y, 1, 1) animated:YES];
    }
}

- (void)longPressHandler:(UILongPressGestureRecognizer *)longPress {
    if ([self.delegate respondsToSelector:@selector(pictureCellLongPress:)]) {
        [self.delegate pictureCellLongPress:self];
    }
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
