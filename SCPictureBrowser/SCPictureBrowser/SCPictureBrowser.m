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
#import "SCToastView.h"
#import "SCAlertView.h"

static NSString * const reuseIdentifier = @"SCPictureCell";

@interface SCPictureBrowser()<UICollectionViewDataSource, UICollectionViewDelegate, SCPictureDelegate, UIScrollViewDelegate, UIActionSheetDelegate>

@property (nonatomic, getter=isFirstShow) BOOL firstShow;
@property (nonatomic, getter=isStatusBarHidden) BOOL statusBarHidden;
@property (nonatomic, getter=isBrowsing) BOOL browsing;

@end

@implementation SCPictureBrowser
{
    UIActionSheet *_sheet;
    UICollectionView *_collectionView;
    UIPageControl *_pageControl;
    BOOL _isFromShowAction;
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
    
    self.firstShow = YES;
    self.browsing = YES;
}

- (void)initializeCollectionView {
    self.automaticallyAdjustsScrollViewInsets = NO;

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
    _collectionView.contentOffset = CGPointMake(self.index * _collectionView.frame.size.width, 0);
    [self.view addSubview:_collectionView];
}

- (void)initializePageControl {
    _pageControl = [[UIPageControl alloc] init];
    [self setPageControlHidden:YES];
    _pageControl.numberOfPages = self.items.count;
    _pageControl.currentPage = self.index;
    CGPoint center = _pageControl.center;
    center.x = self.view.center.x;
    center.y = CGRectGetMaxY(self.view.frame) - _pageControl.frame.size.height / 2 - 20;
    _pageControl.center = center;
    [self.view addSubview:_pageControl];
}

#pragma mark - Public Method

- (void)show {
    if (!self.items.count || self.index > self.items.count - 1) {
        return;
    }
    
    _isFromShowAction = YES;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.view];
    [window.rootViewController addChildViewController:self];
    
    self.statusBarHidden = [UIApplication sharedApplication].isStatusBarHidden;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

#pragma mark - Setter

- (void)setIndex:(NSInteger)index {
    if (_index != index) {
        _index = index;
        
        if (self.isBrowsing) {
            // 更新page
            _pageControl.currentPage = index;
            
            // 预加载图片
            [self prefetchPictures];
        }
        
        if ([self.delegate respondsToSelector:@selector(pictureBrowser:didChangePageAtIndex:)]) {
            [self.delegate pictureBrowser:self didChangePageAtIndex:index];
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
    _collectionView.contentOffset = CGPointMake(self.index * _collectionView.frame.size.width, 0);
    _pageControl.numberOfPages = self.items.count;
    [_collectionView reloadData];
}

- (void)prefetchPictures {
    if (self.numberOfPrefetchURLs <= 0) {
        return;
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    
    if (self.index >= self.numberOfPrefetchURLs) {
        for (NSInteger i = self.index - 1; i >= self.index - self.numberOfPrefetchURLs; i--) {
            SCPictureItem *item = self.items[i];
            if (!item.originImage && item.url) {
                [arrM addObject:item.url];
            }
        }
    }
    if (self.index <= (NSInteger)self.items.count - 1 - self.numberOfPrefetchURLs) {
        for (NSInteger i = self.index + 1; i <= self.index + self.numberOfPrefetchURLs; i++) {
            SCPictureItem *item = self.items[i];
            if (!item.originImage && item.url) {
                [arrM addObject:item.url];
            }
        }
    }
    [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:[arrM copy]];
}

- (void)configureCellFirstWithItem:(SCPictureItem *)item cell:(SCPictureCell *)cell {
    self.firstShow = NO;
    [self prefetchPictures];
    
    if (item.originImage) {
        [self showImage:item.originImage item:item cell:cell cacheType:SDImageCacheTypeMemory];
    }
    else if (item.url) {
        [[SDWebImageManager sharedManager].imageCache queryDiskCacheForKey:item.url.absoluteString done:^(UIImage *image, SDImageCacheType cacheType) {
            if (image) {
                item.originImage = image;
                [self showImage:image item:item cell:cell cacheType:cacheType];
            } else {
                [cell showImageWithItem:item];
                [self setPageControlHidden:NO];
            }
        }];
    }
}

- (void)showImage:(UIImage *)image item:(SCPictureItem *)item cell:(SCPictureCell *)cell cacheType:(SDImageCacheType)cacheType {
    cell.imageView.image = image;
    
    if (item.sourceView) {
        cell.imageView.frame = [item.sourceView convertRect:item.sourceView.bounds toView:cell];
        if (cacheType == SDImageCacheTypeMemory) { // 如果同步执行这段代码，坐标系转换会有bug，所以手动累加偏移量
            CGRect frame = cell.imageView.frame;
            frame.origin.x += (cell.frame.size.width * self.index);
            cell.imageView.frame = frame;
        }
        [UIView animateWithDuration:0.4 animations:^{
            cell.imageView.frame = [cell imageViewRectWithImageSize:image.size];
        } completion:^(BOOL finished) {
            cell.enableDoubleTap = YES;
            [cell setMaximumZoomScale];
            [self setPageControlHidden:NO];
        }];
    }
    else {
        [self setPageControlHidden:NO];
        cell.imageView.frame = [cell imageViewRectWithImageSize:image.size];
        cell.alpha = 0;
        [UIView animateWithDuration:0.4 animations:^{
            cell.alpha = 1;
        } completion:^(BOOL finished) {
            cell.enableDoubleTap = YES;
            [cell setMaximumZoomScale];
        }];
    }
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
    
    if (_isFromShowAction) {
        if (self.isFirstShow) {
            [self configureCellFirstWithItem:item cell:cell];
        } else {
            [cell showImageWithItem:item];
            [self setPageControlHidden:NO];
        }
    }
    else {
        [cell showImageWithItem:item];
        [self setPageControlHidden:NO];
    }
    
    return cell;
}

#pragma mark - UISCrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.index = fabs(scrollView.contentOffset.x / scrollView.bounds.size.width);
}

#pragma mark - SCPictureCellDelegate

- (void)pictureCellSingleTap:(SCPictureCell *)pictureCell {
    if (_isFromShowAction) {
        [[UIApplication sharedApplication] setStatusBarHidden:self.isStatusBarHidden withAnimation:UIStatusBarAnimationNone];
        [self setPageControlHidden:YES];
        SCPictureItem *item = self.items[self.index];
        [UIView animateWithDuration:0.4 animations:^{
            if (item.sourceView) {
                self.view.backgroundColor = [UIColor clearColor];
                pictureCell.imageView.frame = [item.sourceView convertRect:item.sourceView.bounds toView:pictureCell];
            } else {
                self.view.alpha = 0;
            }
        } completion:^(BOOL finished) {
            self.browsing = NO;
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        }];
    }
}

- (void)pictureCellDoubleTap:(SCPictureCell *)pictureCell {
    
}

- (void)pictureCellLongPress:(SCPictureCell *)pictureCell {
    SCPictureItem *item = self.items[self.index];
    if (item.originImage) {
        SCAlertView *alertView = [SCAlertView alertViewWithTitle:nil message:nil style:SCAlertViewStyleActionSheet];
        [alertView addAction:[SCAlertAction actionWithTitle:@"保存图片" style:SCAlertActionStyleDefault handler:^(SCAlertAction * _Nonnull action) {
            UIImageWriteToSavedPhotosAlbum(item.originImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }]];
        [alertView addAction:[SCAlertAction actionWithTitle:@"取消" style:SCAlertActionStyleCancel handler:nil]];
        [alertView show];
    }
}

// save picture
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (!error) {
        [SCToastView showInView:self.view text:@"保存成功"];
    } else {
        [SCToastView showInView:self.view text:@"保存失败"];
    }
}

@end
