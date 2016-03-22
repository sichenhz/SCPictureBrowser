//
//  SCPictureBrowser.h
//  SCPictureBrowser
//
//  Created by sichenwang on 16/3/21.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCPicture : NSObject

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) UIView *sourceView;

@end

@interface SCPictureBrowser : UIViewController

@property (nonatomic, strong) NSArray <SCPicture *> *pictures;
@property (nonatomic) NSInteger index;

- (void)show;

@end
