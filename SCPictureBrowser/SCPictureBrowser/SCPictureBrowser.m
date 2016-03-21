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

static NSString * const reuseIdentifier = @"SCPictureCell";

@interface SCPictureBrowser()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) UICollectionView *collectionView;

@end

@implementation SCPictureBrowser

#pragma mark - Life Cycle

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Private Method

- (void)setPictures:(NSArray<SCPicture *> *)pictures {
    _pictures = pictures;
    
    self.collectionView.contentSize = CGSizeMake(self.collectionView.frame.size.width * pictures.count, 0);
}

- (void)setIndex:(NSInteger)index {
    _index = index;
    
    self.collectionView.contentOffset = CGPointMake(index * _collectionView.frame.size.width, 0);
}

#pragma mark - Getter

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CGRect frame = self.view.frame;
        frame.size.width += 20;
        
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
        [self.view addSubview:collectionView];
        
        _collectionView = collectionView;
    }
    return _collectionView;
}

#pragma mark - Public Method

- (void)show {
    
    if (self.index > self.pictures.count - 1) {
        return;
    }
    
    SCPicture *picture = self.pictures[self.index];
    picture.firstShow = YES;
    
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
    cell.picture = self.pictures[indexPath.item];
    return cell;
}

#pragma mark - UICollectionViewDelegate

@end
