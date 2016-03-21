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
    
    NSMutableArray *arrM = [NSMutableArray array];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button1 setImage:[UIImage imageNamed:@"icon2"] forState:UIControlStateNormal];
    [button1 sizeToFit];
    CGRect frame = button1.frame;
    frame.origin.x = 55;
    frame.origin.y = 55;
    button1.frame = frame;
    button1.tag = 0;
    [button1 addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    SCPicture *picture = [[SCPicture alloc] init];
    picture.url = [NSURL URLWithString:@"http://pic.lehe.com/pic/_o/28/8c/322383173465a602cbb3a8bc5048_448_260.cz.jpg"];
    picture.sourceView = button1;
    [arrM addObject:picture];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button2 setImage:[UIImage imageNamed:@"icon1"] forState:UIControlStateNormal];
    [button2 sizeToFit];
    frame = button2.frame;
    frame.origin.x = 50;
    frame.origin.y = 150;
    button2.frame = frame;
    button2.tag = 1;
    [button2 addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
    picture = [[SCPicture alloc] init];
    picture.url = [NSURL URLWithString:@"http://pic.lehe.com/pic/_o/69/ba/5d627fc316f70ecf085a96c202e6_380_672.cz.jpg"];
    picture.sourceView = button2;
    [arrM addObject:picture];
    
    self.pictures = [arrM copy];
}

- (void)buttonPressed:(UIButton *)sender {
    SCPictureBrowser *pictureBrowser = [[SCPictureBrowser alloc] init];
    pictureBrowser.pictures = self.pictures;
    pictureBrowser.index = sender.tag;
    [pictureBrowser show];
}

@end
