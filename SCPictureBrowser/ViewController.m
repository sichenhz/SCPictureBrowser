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

@interface ViewController ()

@property (nonatomic, strong) NSArray *items;

@end

@implementation ViewController
{
    NSArray *_urls;
    NSArray *_pictures;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _urls = @[@"http://ww4.sinaimg.cn/thumbnail/7f8c1087gw1e9g06pc68ug20ag05y4qq.gif",
                      @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr0nly5j20pf0gygo6.jpg",
                      @"http://ww4.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr1d0vyj20pf0gytcj.jpg",
                      @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr1xydcj20gy0o9q6s.jpg",
                      @"http://ww2.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr2n1jjj20gy0o9tcc.jpg",
                      @"http://ww2.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr39ht9j20gy0o6q74.jpg",
                      @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr3xvtlj20gy0obadv.jpg",
                      @"http://ww4.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr4nndfj20gy0o9q6i.jpg",
                      @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr57tn9j20gy0obn0f.jpg"];
    NSInteger columns = 3;

    NSMutableArray *arrM = [NSMutableArray array];
    
    for (NSInteger i = 0; i < 9; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.userInteractionEnabled = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [imageView sd_setImageWithURL:[NSURL URLWithString:_urls[i]]];
        CGFloat w = 60;
        CGFloat h = 60;
        CGFloat x = (w + 20) * (i % columns) + 50;
        CGFloat y = (h + 20) * (i / columns) + 200;
        imageView.frame = CGRectMake(x, y, w, h);
        imageView.tag = i;
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewPressed:)];
        [imageView addGestureRecognizer:gesture];
        [self.view addSubview:imageView];
        
        NSString *url = [_urls[i] stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
        SCPictureItem *picture = [SCPictureItem itemWithURL:[NSURL URLWithString:url] sourceView:imageView];
        [arrM addObject:picture];
    }
    
    self.items = [arrM copy];
}

- (void)imageViewPressed:(UITapGestureRecognizer *)gesture {
    SCPictureBrowser *pictureBrowser = [SCPictureBrowser browserWithItems:self.items currentPage:gesture.view.tag numberOfPrefetchURLs:2];
    [pictureBrowser show];
}

@end
