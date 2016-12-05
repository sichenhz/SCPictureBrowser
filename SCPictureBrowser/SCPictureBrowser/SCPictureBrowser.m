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
static CGFloat const kDismissalVelocity = 1000.0;

@interface SCPictureBrowser()<UICollectionViewDataSource, UICollectionViewDelegate, SCPictureDelegate, UIScrollViewDelegate>

@property (nonatomic, getter=isFirstShow) BOOL firstShow;
@property (nonatomic, getter=isBrowsing) BOOL browsing;

@property (nonatomic,strong) UIImageView *screenshotImageView;
@property (nonatomic,strong) UIImage *screenshot;

// delete
@property (nonatomic, strong) UIButton *trashButton;
@property (nonatomic, strong) NSArray *originItems;
@property (nonatomic, strong) NSMutableArray *removedItems;
@property (nonatomic, strong) NSMutableIndexSet *indexSet;

// UIDynamics
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIAttachmentBehavior *attachmentBehavior;
@property (nonatomic, assign) CGPoint imageDragStartingPoint;
@property (nonatomic, assign) UIOffset imageDragOffsetFromActualTranslation;
@property (nonatomic, assign) UIOffset imageDragOffsetFromImageCenter;
@property (nonatomic, assign) BOOL isDraggingImage;

@end

@implementation SCPictureBrowser
{
    UICollectionView *_collectionView;
    UIPageControl *_pageControl;
    BOOL _isFromShowAction;
}

- (BOOL)prefersStatusBarHidden {
    return self.statusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.statusBarStyle;
}

#pragma mark - Life Cycle

- (instancetype)init {
    if (self = [super init]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        _statusBarHidden = NO;
        _statusBarStyle = UIStatusBarStyleLightContent;
        _contentMode = UIViewContentModeScaleAspectFill;
        _screenshot = [self screenshotFromView:[UIApplication sharedApplication].keyWindow];
    }
    return self;
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.screenshotImageView];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.pageControl];
    if (self.supportDelete) {
        [self.view addSubview:self.trashButton];
    }

    
    self.firstShow = YES;
    self.browsing = YES;
}

#pragma mark - Public Method

- (void)show {
    if (!self.items.count || self.index > self.items.count - 1) {
        return;
    }
    
    _isFromShowAction = YES;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window.rootViewController presentViewController:self animated:NO completion:^{
        self.statusBarHidden = YES;
        [self setNeedsStatusBarAppearanceUpdate];
    }];
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

#pragma mark - Getter

- (UIImageView *)screenshotImageView {
    if (_screenshotImageView) {
        return _screenshotImageView;
    }
    _screenshotImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _screenshotImageView.image = self.screenshot;
    return _screenshotImageView;
}

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
        
        _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[SCPictureCell class] forCellWithReuseIdentifier:reuseIdentifier];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.pagingEnabled = YES;
        _collectionView.contentSize = CGSizeMake(_collectionView.frame.size.width * self.items.count, 0);
        _collectionView.contentOffset = CGPointMake(self.index * _collectionView.frame.size.width, 0);
    }
    
    return _collectionView;
}

- (UIPageControl *)pageControl {
    _pageControl = [[UIPageControl alloc] init];
    [self setPageControlHidden:YES];
    _pageControl.numberOfPages = self.items.count;
    _pageControl.currentPage = self.index;
    CGPoint center = _pageControl.center;
    center.x = self.view.center.x;
    center.y = CGRectGetMaxY(self.view.frame) - _pageControl.frame.size.height / 2 - 20;
    _pageControl.center = center;

    return _pageControl;
}

- (UIButton *)trashButton {
    if (!_trashButton) {
        _originItems = [self.items copy];
        _removedItems = [NSMutableArray array];
        _indexSet = [NSMutableIndexSet indexSet];
        _trashButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _trashButton.frame = CGRectMake(_collectionView.frame.size.width - 60, 20, 30, 30);
        [_trashButton addTarget:self action:@selector(trashButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_trashButton setImage:[UIImage imageNamed:[@"SCPictureBrowser.bundle" stringByAppendingPathComponent:@"trash.png"]] forState:UIControlStateNormal];
    }
    return _trashButton;
}

#pragma mark - Private Method

- (UIImage *)screenshotFromView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size,NO,[UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenshotImage;
}

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
    
    self.collectionView.backgroundColor = [UIColor blackColor];
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
        
        [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
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
        self.collectionView.alpha = 0.0f;
        [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.collectionView.alpha = 1.0f;
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

- (void)trashButtonPressed:(id)sender {
    SCAlertView *alertView = [SCAlertView alertViewWithTitle:@"删除这张图片？" message:nil style:SCAlertViewStyleAlert];
    [alertView addAction:[SCAlertAction actionWithTitle:@"取消" style:SCAlertActionStyleCancel handler:nil]];
    [alertView addAction:[SCAlertAction actionWithTitle:@"删除" style:SCAlertActionStyleConfirm handler:^(SCAlertAction * _Nonnull action) {
        [self.removedItems addObject:self.items[self.index]];
        for (SCPictureItem *item in self.originItems) {
            if ([item isEqual:self.items[self.index]]) {
                [self.indexSet addIndex:[self.originItems indexOfObject:item]];
                break;
            }
        }
        if (self.items.count > 1) {
            NSMutableArray *arrM = [NSMutableArray arrayWithArray:self.items];
            [arrM removeObjectAtIndex:self.index];
            self.items = arrM;
            [_collectionView reloadData];
        } else {
            SCPictureCell *pictureCell = (SCPictureCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.index inSection:0]];
            [self endBrowseWithCell:pictureCell];
        }
        [SCToastView showInView:[UIApplication sharedApplication].keyWindow text:@"删除成功" duration:1.5 autoHide:YES];
    }]];
    [alertView show];
}

- (void)endBrowseWithCell:(SCPictureCell *)pictureCell {

    self.statusBarHidden = NO;
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self setPageControlHidden:YES];
    SCPictureItem *item = self.items[self.index];
    
    self.trashButton.alpha = 0.0f;
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        BOOL needsAnimation = NO;
        
        if (item.sourceView) {
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            CGRect rect = [item.sourceView convertRect:item.sourceView.bounds toView:window];
            if (CGRectIntersectsRect(rect, window.frame)) {
                needsAnimation = YES;
            }
        }
        
        self.collectionView.backgroundColor = [UIColor clearColor];

        if (needsAnimation) {
            pictureCell.imageView.frame = [item.sourceView convertRect:item.sourceView.bounds toView:pictureCell];
        } else {
            CGRect frame = pictureCell.imageView.frame;
            frame.size = CGSizeMake(frame.size.width * 2/3, frame.size.height * 2/3);
            pictureCell.imageView.frame = frame;
            pictureCell.imageView.center = CGPointMake(pictureCell.frame.size.width / 2, pictureCell.frame.size.height / 2);
            pictureCell.imageView.alpha = 0.0f;
        }
        
    } completion:^(BOOL finished) {
        
        self.browsing = NO;
        [self dismissViewControllerAnimated:NO completion:nil];
        
        if (self.supportDelete) {
            if (self.removedItems.count) {
                if ([self.delegate respondsToSelector:@selector(pictureBrowser:didDeleteItems:indexSet:)]) {
                    [self.delegate pictureBrowser:self didDeleteItems:[self.removedItems copy] indexSet:[self.indexSet copy]];
                }
            }
        }
        
    }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SCPictureCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.imageView.contentMode = self.contentMode;
    cell.enableDynamicsDismiss = self.items.count == 1 ? YES : NO;
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

- (void)pictureCell:(SCPictureCell *)pictureCell singleTap:(UITapGestureRecognizer *)singleTap {
    if (_isFromShowAction) {
        [self endBrowseWithCell:pictureCell];
    }
}

- (void)pictureCell:(SCPictureCell *)pictureCell doubleTap:(UITapGestureRecognizer *)doubleTap {
    
}

- (void)pictureCell:(SCPictureCell *)pictureCell longPress:(UILongPressGestureRecognizer *)longPress {
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

- (void)pictureCell:(SCPictureCell *)pictureCell pan:(UIPanGestureRecognizer *)pan {
    
    CGPoint translation = [pan translationInView:pan.view];
    CGPoint locationInView = [pan locationInView:pan.view];
    CGPoint velocity = [pan velocityInView:pan.view];
    CGFloat vectorDistance = sqrtf(powf(velocity.x, 2)+powf(velocity.y, 2));

    if (pan.state == UIGestureRecognizerStateBegan) {
        self.isDraggingImage = CGRectContainsPoint(pictureCell.imageView.frame, locationInView);
        if (self.isDraggingImage) {
            [self startImageDragging:locationInView translationOffset:UIOffsetZero pictureCell:pictureCell];
        }
    }
    else if (pan.state == UIGestureRecognizerStateChanged) {
        if (self.isDraggingImage) {
            CGPoint newAnchor = self.imageDragStartingPoint;
            newAnchor.x += translation.x + self.imageDragOffsetFromActualTranslation.horizontal;
            newAnchor.y += translation.y + self.imageDragOffsetFromActualTranslation.vertical;
            self.attachmentBehavior.anchorPoint = newAnchor;
        }
        else {
            self.isDraggingImage = CGRectContainsPoint(pictureCell.imageView.frame, locationInView);
            if (self.isDraggingImage) {
                UIOffset translationOffset = UIOffsetMake(-1*translation.x, -1*translation.y);
                [self startImageDragging:locationInView translationOffset:translationOffset pictureCell:pictureCell];
            }
        }
    }
    else {
        if (vectorDistance > kDismissalVelocity) {
            if (self.isDraggingImage) {
                [self dismissImageWithFlick:velocity pictureCell:pictureCell];
            }
        } else {
            [self cancelCurrentImageDrag:YES pictureCell:pictureCell];
        }
    }
}

- (void)cancelCurrentImageDrag:(BOOL)animated pictureCell:(SCPictureCell *)pictureCell {
    [self.animator removeAllBehaviors];
    self.attachmentBehavior = nil;
    self.isDraggingImage = NO;
    if (animated == NO) {
        pictureCell.imageView.transform = CGAffineTransformIdentity;
        pictureCell.imageView.center = CGPointMake(pictureCell.scrollView.contentSize.width/2.0f, pictureCell.scrollView.contentSize.height/2.0f);
    } else {
        [UIView
         animateWithDuration:0.5f
         delay:0.0f
         usingSpringWithDamping:0.5f
         initialSpringVelocity:0.0f
         options:UIViewAnimationOptionAllowUserInteraction |
         UIViewAnimationOptionBeginFromCurrentState
         animations:^{
             if (self.isDraggingImage == NO) {
                 pictureCell.imageView.transform = CGAffineTransformIdentity;
                 if (pictureCell.scrollView.dragging == NO && pictureCell.scrollView.decelerating == NO) {
                     pictureCell.imageView.center = CGPointMake(CGRectGetMidX(pictureCell.scrollView.frame), CGRectGetMidY(pictureCell.scrollView.frame));
                 }
             }
         } completion:nil];
    }
}

- (void)dismiss {

    self.statusBarHidden = NO;
    [self setNeedsStatusBarAppearanceUpdate];

    [self setPageControlHidden:YES];
    
    self.trashButton.alpha = 0.0f;
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.collectionView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.browsing = NO;
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void)dismissImageWithFlick:(CGPoint)velocity pictureCell:(SCPictureCell *)pictureCell {
    __weak typeof(self)weakSelf = self;
    UIPushBehavior *push = [[UIPushBehavior alloc] initWithItems:@[pictureCell.imageView] mode:UIPushBehaviorModeInstantaneous];
    push.pushDirection = CGVectorMake(velocity.x*0.1, velocity.y*0.1);
    [push setTargetOffsetFromCenter:self.imageDragOffsetFromImageCenter forItem:pictureCell.imageView];
    push.action = ^{
        if ([weakSelf imageViewIsOffscreen:pictureCell]) {
            [weakSelf.animator removeAllBehaviors];
            weakSelf.attachmentBehavior = nil;
            [weakSelf dismiss];
        }
    };
    [self.animator removeBehavior:self.attachmentBehavior];
    [self.animator addBehavior:push];
}

- (void)startImageDragging:(CGPoint)locationInView translationOffset:(UIOffset)translationOffset pictureCell:(SCPictureCell *)pictureCell {
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:pictureCell.scrollView];
    self.imageDragStartingPoint = locationInView;
    self.imageDragOffsetFromActualTranslation = translationOffset;
    CGPoint anchor = self.imageDragStartingPoint;
    CGPoint imageCenter = pictureCell.imageView.center;
    UIOffset offset = UIOffsetMake(locationInView.x-imageCenter.x, locationInView.y-imageCenter.y);
    self.imageDragOffsetFromImageCenter = offset;
    self.attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:pictureCell.imageView offsetFromCenter:offset attachedToAnchor:anchor];
    [self.animator addBehavior:self.attachmentBehavior];
    UIDynamicItemBehavior *modifier = [[UIDynamicItemBehavior alloc] initWithItems:@[pictureCell.imageView]];
    modifier.angularResistance = [self appropriateAngularResistanceForView:pictureCell.imageView];
    modifier.density = [self appropriateDensityForView:pictureCell.imageView];
    [self.animator addBehavior:modifier];
}

- (BOOL)imageViewIsOffscreen:(SCPictureCell *)pictureCell {
    CGRect visibleRect = [pictureCell.scrollView convertRect:self.view.bounds fromView:self.view];
    return ([self.animator itemsInRect:visibleRect].count == 0);
}

- (CGFloat)appropriateAngularResistanceForView:(UIView *)view {
    CGFloat height = view.bounds.size.height;
    CGFloat width = view.bounds.size.width;
    CGFloat actualArea = height * width;
    CGFloat referenceArea = self.view.bounds.size.width * self.view.bounds.size.height;
    CGFloat factor = referenceArea / actualArea;
    CGFloat defaultResistance = 4.0f; // Feels good with a 1x1 on 3.5 inch displays. We'll adjust this to match the current display.
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat resistance = defaultResistance * ((320.0 * 480.0) / (screenWidth * screenHeight));
    return resistance * factor;
}

- (CGFloat)appropriateDensityForView:(UIView *)view {
    CGFloat height = view.bounds.size.height;
    CGFloat width = view.bounds.size.width;
    CGFloat actualArea = height * width;
    CGFloat referenceArea = self.view.bounds.size.width * self.view.bounds.size.height;
    CGFloat factor = referenceArea / actualArea;
    CGFloat defaultDensity = 0.5f; // Feels good on 3.5 inch displays. We'll adjust this to match the current display.
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat appropriateDensity = defaultDensity * ((320.0 * 480.0) / (screenWidth * screenHeight));
    return appropriateDensity * factor;
}


// save picture
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (!error) {
        [SCToastView showInView:[UIApplication sharedApplication].keyWindow text:@"保存成功" duration:1.5 autoHide:YES];
    } else {
        [SCToastView showInView:[UIApplication sharedApplication].keyWindow text:@"保存失败" duration:1.5 autoHide:YES];
    }
}

@end
