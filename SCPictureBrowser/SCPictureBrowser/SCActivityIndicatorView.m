//
//  SCActivityIndicatorView.m
//  SCPictureBrowser
//
//  Created by sichenwang on 16/3/23.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import "SCActivityIndicatorView.h"

@implementation SCActivityIndicatorView
{
    UIImageView *_imageView;
    BOOL _isAnimating;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, 30, 30)]) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _imageView.image = [UIImage imageNamed:@"loading_circle"];
        [self addSubview:_imageView];
        
        self.hidden = YES;
    }
    return self;
}

- (void)startAnimating {
    self.hidden = NO;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    animation.fromValue = @(0);
    animation.toValue = @(M_PI * 2);
    animation.duration = 1.0;
    animation.fillMode=kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.repeatCount = MAXFLOAT;
    [_imageView.layer addAnimation:animation forKey:@"rotation"];
    _isAnimating = YES;
}

- (void)stopAnimating {
    self.hidden = YES;
    _isAnimating = NO;
    [_imageView.layer removeAnimationForKey:@"rotation"];
}

- (BOOL)isAnimating {
    return _isAnimating;
}

@end
