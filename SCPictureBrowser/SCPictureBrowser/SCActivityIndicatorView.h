//
//  SCActivityIndicatorView.h
//  SCPictureBrowser
//
//  Created by sichenwang on 16/3/23.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SCActivityIndicatorViewStyle) {
    SCActivityIndicatorViewStyleDefault = 0,
    SCActivityIndicatorViewStyleCircle,
    SCActivityIndicatorViewStyleCircleLarge
};

@interface SCActivityIndicatorView : UIView

- (instancetype)initWithStyle:(SCActivityIndicatorViewStyle)style NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithFrame:(CGRect)frame NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

#if TARGET_INTERFACE_BUILDER
@property (nonatomic) IBInspectable NSInteger style;
#else
@property (nonatomic) SCActivityIndicatorViewStyle style;
#endif

- (void)startAnimating;
- (void)stopAnimating;
- (BOOL)isAnimating;

@end
