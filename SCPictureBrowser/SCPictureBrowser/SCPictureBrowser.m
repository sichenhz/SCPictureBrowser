//
//  SCPictureBrowser.m
//  SCPictureBrowser
//
//  Created by sichenwang on 16/3/21.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import "SCPictureBrowser.h"
#import "SCPictureCell.h"
#import "SDWebImageManager.h"
#import "SDWebImagePrefetcher.h"

static NSString * const reuseIdentifier = @"SCPictureCell";

@interface SCPictureItem()

@property (nonnull, nonatomic, strong, readwrite) NSURL *url;
@property (nonnull, nonatomic, strong, readwrite) UIView *sourceView;

@end

@implementation SCPictureItem

+ (instancetype)itemWithURL:(nonnull NSURL *)url sourceView:(nonnull UIView *)sourceView {
    SCPictureItem *item = [[SCPictureItem alloc] init];
    item.url = url;
    item.sourceView = sourceView;
    return item;
}

@end

@interface SCPictureBrowser()<UICollectionViewDataSource, UICollectionViewDelegate, SCPictureDelegate, UIScrollViewDelegate>

@property (nonnull, nonatomic, strong, readwrite) NSArray <SCPictureItem *> *items;
@property (nonatomic, readwrite) NSInteger currentPage;

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, weak) UIPageControl *pageControl;
@property (nonatomic, getter=isFirstShow) BOOL firstShow;
@property (nonatomic, getter=isStatusBarHidden) BOOL statusBarHidden;

@end

@implementation SCPictureBrowser

+ (instancetype)browserWithItems:(nonnull NSArray *)items currentPage:(NSInteger)currentPage numberOfPrefetchURLs:(NSInteger)numberOfPrefetchURLs {
    SCPictureBrowser *browser = [[SCPictureBrowser alloc] init];
    browser.items = items;
    browser.currentPage = currentPage;
    browser.numberOfPrefetchURLs = numberOfPrefetchURLs;
    return browser;
}

#pragma mark - Life Cycle

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view.backgroundColor = [UIColor blackColor];
}

#pragma mark - Getter

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CGRect frame = self.view.frame;
        frame.size.width += SCPictureCellRightMargin;
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = frame.size;
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        layout.sectionInset = UIEdgeInsetsZero;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
        collectionView.dataSource = self;
        collectionView.delegate = self;
        [collectionView registerClass:[SCPictureCell class] forCellWithReuseIdentifier:reuseIdentifier];
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.pagingEnabled = YES;
        collectionView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:collectionView];
        
        _collectionView = collectionView;
    }
    return _collectionView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        UIPageControl *pageControl = [[UIPageControl alloc] init];
        [self.view addSubview:pageControl];
        _pageControl = pageControl;
    }
    return _pageControl;
}

#pragma mark - Setter

- (void)setCurrentPage:(NSInteger)currentPage {
    if (_currentPage != currentPage) {
        _currentPage = currentPage;
        self.pageControl.currentPage = currentPage;
    }
}

#pragma mark - Private Method

- (void)prefetchPictures {
    if (self.numberOfPrefetchURLs <= 0) {
        return;
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    
    if (self.currentPage >= self.numberOfPrefetchURLs) {
        for (NSInteger i = self.currentPage - 1; i >= self.currentPage - self.numberOfPrefetchURLs; i--) {
            SCPictureItem *picture = self.items[i];
            [arrM addObject:picture.url];
            NSLog(@"开始预加载图片，下标为%zd",i);
        }
    }
    if (self.currentPage <= self.items.count - 1 - self.numberOfPrefetchURLs) {
        for (NSInteger i = self.currentPage + 1; i <= self.currentPage + self.numberOfPrefetchURLs; i++) {
            SCPictureItem *picture = self.items[i];
            [arrM addObject:picture.url];
            NSLog(@"开始预加载图片，下标为%zd",i);
        }
    }
    [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:[arrM copy] progress:^(NSUInteger noOfFinishedUrls, NSUInteger noOfTotalUrls) {
        NSLog(@"当前预加载进度%zd/%zd", noOfFinishedUrls, noOfTotalUrls);
    } completed:^(NSUInteger noOfFinishedUrls, NSUInteger noOfSkippedUrls) {
        NSLog(@"当前预加载成功%zd|加载失败%zd", noOfFinishedUrls, noOfSkippedUrls);
    }];
}

#pragma mark - Public Method

- (void)show {
    
    if (!self.items.count || self.currentPage > self.items.count - 1) {
        return;
    }
    
    [self prefetchPictures];

    self.statusBarHidden = [UIApplication sharedApplication].isStatusBarHidden;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];

    self.firstShow = YES;

    self.collectionView.contentSize = CGSizeMake(self.collectionView.frame.size.width * self.items.count, 0);
    self.collectionView.contentOffset = CGPointMake(self.currentPage * self.collectionView.frame.size.width, 0);
    
    self.pageControl.numberOfPages = self.items.count;
    self.pageControl.currentPage = self.currentPage;
    CGPoint center = self.pageControl.center;
    center.x = self.view.center.x;
    center.y = CGRectGetMaxY(self.view.frame) - self.pageControl.frame.size.height / 2 - 20;
    self.pageControl.center = center;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.view];
    [window.rootViewController addChildViewController:self];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SCPictureItem *picture = self.items[indexPath.item];
    SCPictureCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (self.isFirstShow && indexPath.item == self.currentPage) {
        
        [self.view bringSubviewToFront:self.pageControl];
        
        [[SDWebImageManager sharedManager].imageCache queryDiskCacheForKey:picture.url.absoluteString done:^(UIImage *image, SDImageCacheType cacheType) {
            // 如果取到了图片
            if (image) {
                // 开始浏览
                self.pageControl.hidden = YES;
                cell.enableDoubleTap = YES;
                cell.imageView.image = image;
                CGSize showSize = [cell showSize:image.size];
                // 第一次显示图片，转换坐标系，然后动画放大
                cell.imageView.frame = [cell convertRect:picture.sourceView.frame toView:cell];
                [UIView animateWithDuration:0.4 animations:^{
                    cell.imageView.frame = CGRectMake(0, 0, showSize.width, showSize.height);
                    cell.imageView.center = [UIApplication sharedApplication].keyWindow.center;
                } completion:^(BOOL finished) {
                    self.pageControl.hidden = NO;
                }];
            } else {
                [cell configureCellWithURL:picture.url sourceView:picture.sourceView];
            }
        }];
        self.firstShow = NO;
    } else {
        [cell configureCellWithURL:picture.url sourceView:picture.sourceView];
    }

    cell.delegate = self;
    return cell;
}

#pragma mark - UISCrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.currentPage = fabs(scrollView.contentOffset.x / scrollView.bounds.size.width);
}

#pragma mark - SCPictureCellDelegate

- (void)pictureCellSingleTap:(SCPictureCell *)pictureCell {
    
    // 结束浏览
    [[UIApplication sharedApplication] setStatusBarHidden:self.isStatusBarHidden withAnimation:UIStatusBarAnimationFade];
    self.pageControl.hidden = YES;
    SCPictureItem *picture = self.items[self.currentPage];
    CGRect targetFrame = [picture.sourceView convertRect:picture.sourceView.bounds toView:pictureCell];
    [UIView animateWithDuration:0.4 animations:^{
        self.view.backgroundColor = [UIColor clearColor];
        pictureCell.imageView.frame = targetFrame;
    } completion:^(BOOL finished) {
        self.pageControl.hidden = NO;
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}

@end
