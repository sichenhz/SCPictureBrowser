//
//  SCPictureBrowser.m
//  SCPictureBrowser
//
//  Created by sichenwang on 16/3/21.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import "SCPictureBrowser.h"
#import "SCPictureCell.h"

static NSString * const reuseIdentifier = @"SCPictureCell";

@implementation SCPicture

@end

@interface SCPictureBrowser()<UICollectionViewDataSource, UICollectionViewDelegate, SCPictureDelegate, UIScrollViewDelegate>

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, weak) UIPageControl *pageControl;
@property (nonatomic, getter=isFirstShow) BOOL firstShow;

@end

@implementation SCPictureBrowser

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

- (void)setIndex:(NSInteger)index {
    if (_index != index) {
        _index = index;
        self.pageControl.currentPage = index;
    }
}

#pragma mark - Public Method

- (void)show {
    
    if (!self.pictures.count || self.index > self.pictures.count - 1) {
        return;
    }
    
    self.firstShow = YES;

    self.collectionView.contentSize = CGSizeMake(self.collectionView.frame.size.width * self.pictures.count, 0);
    self.collectionView.contentOffset = CGPointMake(self.index * self.collectionView.frame.size.width, 0);
    
    self.pageControl.numberOfPages = self.pictures.count;
    self.pageControl.currentPage = self.index;
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
    return self.pictures.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SCPictureCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    SCPicture *picture = self.pictures[indexPath.item];
    if (self.isFirstShow && indexPath.item == self.index) {
        [cell configureCellWithURL:picture.url sourceView:picture.sourceView isFirstShow:YES];
        self.firstShow = NO;
    } else {
        [cell configureCellWithURL:picture.url sourceView:picture.sourceView isFirstShow:NO];
    }
    cell.delegate = self;
    return cell;
}

#pragma mark - UISCrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.index = fabs(scrollView.contentOffset.x / scrollView.bounds.size.width);
}

#pragma mark - SCPictureCellDelegate

- (void)pictureCellSingleTap:(SCPictureCell *)pictureCell {
    SCPicture *picture = self.pictures[self.index];
    CGRect targetFrame = [picture.sourceView convertRect:picture.sourceView.bounds toView:pictureCell];
    [UIView animateWithDuration:0.4 animations:^{
        self.view.backgroundColor = [UIColor clearColor];
        pictureCell.imageView.frame = targetFrame;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}

@end
