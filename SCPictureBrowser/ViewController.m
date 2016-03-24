//
//  ViewController.m
//  SCPictureBrowser
//
//  Created by sichenwang on 16/3/21.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import "ViewController.h"
#import "SCPictureBrowser.h"
#import "UIImageView+WebCache.h"

@interface ViewController()<SCPictureBrowserDelegate>

@end

@implementation ViewController
{
    NSMutableArray *_items;
    NSArray *_urls;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _urls = @[
              @"http://ww4.sinaimg.cn/thumbnail/7f8c1087gw1e9g06pc68ug20ag05y4qq.gif",
              @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr0nly5j20pf0gygo6.jpg",
              @"http://ww4.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr1d0vyj20pf0gytcj.jpg",
              @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr1xydcj20gy0o9q6s.jpg",
              @"http://ww2.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr2n1jjj20gy0o9tcc.jpg",
              @"http://ww2.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr39ht9j20gy0o6q74.jpg",
              @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr3xvtlj20gy0obadv.jpg",
              @"http://ww4.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr4nndfj20gy0o9q6i.jpg",
              @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr57tn9j20gy0obn0f.jpg"
              ];

    _items = [NSMutableArray array];
    for (NSInteger i = 0; i < _urls.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.userInteractionEnabled = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [imageView sd_setImageWithURL:[NSURL URLWithString:_urls[i]]];
        CGFloat w = 60;
        CGFloat h = 60;
        NSInteger columns = 3;
        NSInteger rows = (_urls.count + columns - 1) / columns;
        CGFloat gap = 20;
        CGFloat marginLeft = ([UIScreen mainScreen].bounds.size.width - w * columns - gap * (columns - 1)) / 2;
        CGFloat marginTop = ([UIScreen mainScreen].bounds.size.height - h * rows - gap * (rows - 1)) / 2;
        CGFloat x = (w + gap) * (i % columns) + marginLeft;
        CGFloat y = (h + gap) * (i / columns) + marginTop;
        imageView.frame = CGRectMake(x, y, w, h);
        imageView.tag = i;
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewPressed:)];
        [imageView addGestureRecognizer:gesture];
        [self.view addSubview:imageView];
        
        NSString *url = [_urls[i] stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
        SCPictureItem *item = [[SCPictureItem alloc] init];
        item.url = [NSURL URLWithString:url];
        item.sourceView = imageView;
        [_items addObject:item];
    }
}

- (void)imageViewPressed:(UITapGestureRecognizer *)gesture {
    SCPictureBrowser *browser = [[SCPictureBrowser alloc] init];
    browser.delegate = self;
    browser.items = _items;
    browser.currentPage = gesture.view.tag;
    browser.numberOfPrefetchURLs = 0;
    [browser show];
}

- (void)pictureBrowser:(SCPictureBrowser *)browser didChangePageAtIndex:(NSInteger)index {
    if (index == 8 && _items.count == 9) {
        NSString *url = [_urls[1] stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
        SCPictureItem *item = [[SCPictureItem alloc] init];
        item.url = [NSURL URLWithString:url];
        [_items addObject:item];
        browser.items = _items;
    }
}

@end
