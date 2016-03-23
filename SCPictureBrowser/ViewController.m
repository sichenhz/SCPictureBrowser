//
//  ViewController.m
//  SCPictureBrowser
//
//  Created by sichenwang on 16/3/21.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import "ViewController.h"
#import "SCPictureBrowser.h"

@interface ViewController ()

@property (nonatomic, strong) NSArray *pictures;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSArray *urls = @[@"http://pic.lehe.com/pic/_o/69/ba/5d627fc316f70ecf085a96c202e6_380_672.cz.jpg",
                      @"http://pic.lehe.com/pic/_o/28/8c/322383173465a602cbb3a8bc5048_448_260.cz.jpg"];
    NSInteger columns = 3;

    NSMutableArray *arrM = [NSMutableArray array];
    
    for (NSInteger i = 0; i < 9; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        NSString *imageStr = [NSString stringWithFormat:@"icon%zd.jpg", i % 2];
        [button setImage:[UIImage imageNamed:imageStr] forState:UIControlStateNormal];
        [button sizeToFit];
        CGFloat w = button.frame.size.width;
        CGFloat h = button.frame.size.height;
        CGFloat x = w * (i % columns) + 20;
        CGFloat y = h * (i / columns) + 100;
        button.frame = CGRectMake(x, y, w, h);
        button.tag = i;
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        SCPicture *picture = [[SCPicture alloc] init];
        picture.url = [NSURL URLWithString:urls[i % 2]];
        picture.sourceView = button;
        [arrM addObject:picture];
    }
    
    self.pictures = [arrM copy];
}

- (void)buttonPressed:(UIButton *)sender {
    SCPictureBrowser *pictureBrowser = [[SCPictureBrowser alloc] init];
    pictureBrowser.pictures = self.pictures;
    pictureBrowser.index = sender.tag;
    [pictureBrowser show];
}

@end
