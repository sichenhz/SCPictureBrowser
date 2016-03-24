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

@implementation SCPictureItem

@end

static NSString * const reuseIdentifier = @"SCPictureCell";

@interface SCPictureBrowser()<UICollectionViewDataSource, UICollectionViewDelegate, SCPictureDelegate, UIScrollViewDelegate>

@property (nonatomic, getter=isFirstShow) BOOL firstShow;
@property (nonatomic, getter=isStatusBarHidden) BOOL statusBarHidden;
@property (nonatomic, getter=isBrowsing) BOOL browsing;

@end

@implementation SCPictureBrowser
{
    UICollectionView *_collectionView;
    UIPageControl *_pageControl;
}

#pragma mark - Life Cycle

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeCollectionView];
    [self initializePageControl];

    self.statusBarHidden = [UIApplication sharedApplication].isStatusBarHidden;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    self.firstShow = YES;
    self.browsing = YES;
}

- (void)initializeCollectionView {
    CGRect frame = self.view.frame;
    frame.size.width += SCPictureCellRightMargin;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = frame.size;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.sectionInset = UIEdgeInsetsZero;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [_collectionView registerClass:[SCPictureCell class] forCellWithReuseIdentifier:reuseIdentifier];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.pagingEnabled = YES;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.contentSize = CGSizeMake(_collectionView.frame.size.width * self.items.count, 0);
    _collectionView.contentOffset = CGPointMake(self.currentPage * _collectionView.frame.size.width, 0);
    [self.view addSubview:_collectionView];
}

- (void)initializePageControl {
    _pageControl = [[UIPageControl alloc] init];
    [self setPageControlHidden:YES];
    _pageControl.numberOfPages = self.items.count;
    _pageControl.currentPage = self.currentPage;
    CGPoint center = _pageControl.center;
    center.x = self.view.center.x;
    center.y = CGRectGetMaxY(self.view.frame) - _pageControl.frame.size.height / 2 - 20;
    _pageControl.center = center;
    [self.view addSubview:_pageControl];
}

#pragma mark - Public Method

- (void)show {
    if (!self.items.count || self.currentPage > self.items.count - 1) {
        return;
    }
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.view];
    [window.rootViewController addChildViewController:self];    
}

#pragma mark - Setter

- (void)setCurrentPage:(NSInteger)currentPage {
    if (_currentPage != currentPage) {
        _currentPage = currentPage;
        
        if (self.isBrowsing) {
            // 更新page
            _pageControl.currentPage = currentPage;
            
            // 预加载图片
            [self prefetchPictures];
        }
        
        if ([self.delegate respondsToSelector:@selector(pictureBrowser:didChangePageAtIndex:)]) {
            [self.delegate pictureBrowser:self didChangePageAtIndex:currentPage];
        }
    }
}

- (void)setItems:(NSArray<SCPictureItem *> *)items {
    _items = [items copy];
    [self layoutData];
}

#pragma mark - Private Method

- (void)layoutData {
    _collectionView.contentSize = CGSizeMake(_collectionView.frame.size.width * self.items.count, 0);
    _collectionView.contentOffset = CGPointMake(self.currentPage * _collectionView.frame.size.width, 0);
    _pageControl.numberOfPages = self.items.count;
    [_collectionView reloadData];
}

- (void)prefetchPictures {
    if (self.numberOfPrefetchURLs <= 0) {
        return;
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    
    if (self.currentPage >= self.numberOfPrefetchURLs) {
        for (NSInteger i = self.currentPage - 1; i >= self.currentPage - self.numberOfPrefetchURLs; i--) {
            SCPictureItem *picture = self.items[i];
            [arrM addObject:picture.url];
        }
    }
    if (self.currentPage <= (NSInteger)self.items.count - 1 - self.numberOfPrefetchURLs) {
        for (NSInteger i = self.currentPage + 1; i <= self.currentPage + self.numberOfPrefetchURLs; i++) {
            SCPictureItem *picture = self.items[i];
            [arrM addObject:picture.url];
        }
    }
    [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:[arrM copy]];
}

- (void)configureCellFirstWithItem:(SCPictureItem *)item cell:(SCPictureCell *)cell {
    self.firstShow = NO;
    [self prefetchPictures];
    [[SDWebImageManager sharedManager].imageCache queryDiskCacheForKey:item.url.absoluteString done:^(UIImage *image, SDImageCacheType cacheType) {
        // 取到了图片
        if (image) {
            cell.imageView.image = image;
            // 第一次显示图片，转换坐标系，然后动画放大
            cell.imageView.frame = [item.sourceView convertRect:item.sourceView.bounds toView:cell];
            if (cacheType == SDImageCacheTypeMemory) { // 如果同步执行这段代码，坐标系转换会有bug，所以手动累加偏移量
                CGRect frame = cell.imageView.frame;
                frame.origin.x += (cell.frame.size.width * self.currentPage);
                cell.imageView.frame = frame;
            }
            [UIView animateWithDuration:0.4 animations:^{
                cell.imageView.frame = [cell imageViewRectWithImageSize:image.size];
            } completion:^(BOOL finished) {
                cell.enableDoubleTap = YES;
                [cell setMaximumZoomScale];
                [self setPageControlHidden:NO];
            }];
        } else {
            [cell configureCellWithURL:item.url sourceView:item.sourceView];
            [self setPageControlHidden:NO];
        }
    }];
}

- (void)setPageControlHidden:(BOOL)hidden {
    if (hidden) {
        _pageControl.hidden = YES;
    } else {
        if (self.items.count > 1 && !self.alwaysPageControlHidden) {
            _pageControl.hidden = NO;
        }
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SCPictureCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    
    SCPictureItem *item = self.items[indexPath.item];
    if (self.isFirstShow) {
        [self configureCellFirstWithItem:item cell:cell];
    } else {
        [cell configureCellWithURL:item.url sourceView:item.sourceView];
        [self setPageControlHidden:NO];
    }
    return cell;
}

#pragma mark - UISCrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.currentPage = fabs(scrollView.contentOffset.x / scrollView.bounds.size.width);
}

#pragma mark - SCPictureCellDelegate

- (void)pictureCellSingleTap:(SCPictureCell *)pictureCell {
    [self setPageControlHidden:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:self.isStatusBarHidden withAnimation:UIStatusBarAnimationNone];
    SCPictureItem *picture = self.items[self.currentPage];
    
    CGRect targetFrame = CGRectZero;
    if (picture.sourceView) {
        targetFrame = [picture.sourceView convertRect:picture.sourceView.bounds toView:pictureCell];
    } else {
        targetFrame = CGRectMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2, 0, 0);
    }
    [UIView animateWithDuration:0.4 animations:^{
        self.view.backgroundColor = [UIColor clearColor];
        pictureCell.imageView.frame = targetFrame;
    } completion:^(BOOL finished) {
        self.browsing = NO;
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}

- (void)pictureCellLongPress:(SCPictureCell *)pictureCell {
    NSLog(@"longPress");
}

@end
