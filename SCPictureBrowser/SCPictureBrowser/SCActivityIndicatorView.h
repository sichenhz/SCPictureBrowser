//
//  SCActivityIndicatorView.h
//  SCPictureBrowser
//
//  Created by sichenwang on 16/3/23.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCActivityIndicatorView : UIView

- (void)startAnimating;
- (void)stopAnimating;
- (BOOL)isAnimating;

@end
