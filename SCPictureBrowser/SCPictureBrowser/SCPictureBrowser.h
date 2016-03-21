//
//  SCPictureBrowser.h
//  SCPictureBrowser
//
//  Created by sichenwang on 16/3/21.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCPicture.h"

@interface SCPictureBrowser : UIViewController

@property (nonatomic, strong) NSArray <SCPicture *> *pictures;

@property (nonatomic) NSInteger index;

- (void)show;

@end
