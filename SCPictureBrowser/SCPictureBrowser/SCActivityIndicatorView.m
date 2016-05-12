//
//  SCActivityIndicatorView.m
//  SCPictureBrowser
//
//  Created by sichenwang on 16/3/23.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import "SCActivityIndicatorView.h"

@interface UIView(Extension)

@property (nonatomic) CGSize size;

@end

@implementation UIView(Extension)

- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

@end

@interface SCActivityIndicatorView()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, getter=isAnimating) BOOL animating;

@end

@implementation SCActivityIndicatorView

- (instancetype)initWithStyle:(SCActivityIndicatorViewStyle)style {
    if (self = [super initWithFrame:CGRectZero]) {
        [self initializeSubviews];
        self.style = style;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initializeSubviews];
        self.style = SCActivityIndicatorViewStyleDefault;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initializeSubviews];
    }
    return self;
}

- (void)initializeSubviews {
    self.hidden = YES;
    self.userInteractionEnabled = NO;
    self.backgroundColor = [UIColor clearColor];
    self.imageView = [[UIImageView alloc] init];
    self.imageView.contentMode = UIViewContentModeCenter;
    [self addSubview:self.imageView];
}

- (void)setStyle:(SCActivityIndicatorViewStyle)style {
    _style = style;
    switch (style) {
        case SCActivityIndicatorViewStyleDefault:
            self.layer.cornerRadius = 5;
            self.backgroundColor = [UIColor colorWithRed:241/255.0 green:241/255.0 blue:241/255.0 alpha:1];
            self.imageView.image = [UIImage imageNamed:[@"SCPictureBrowser.bundle" stringByAppendingPathComponent:@"loading_circle.png"]];
            self.size = CGSizeMake(44, 44);
            self.imageView.center = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
            break;
        case SCActivityIndicatorViewStyleCircle:
            self.layer.cornerRadius = 0;
            self.backgroundColor = [UIColor clearColor];
            self.imageView.image = [UIImage imageNamed:[@"SCPictureBrowser.bundle" stringByAppendingPathComponent:@"loading_circle.png"]];
            self.size = self.imageView.size;
            break;
        case SCActivityIndicatorViewStyleCircleLarge:
            self.layer.cornerRadius = 0;
            self.backgroundColor = [UIColor clearColor];
            self.imageView.image = [UIImage imageNamed:[@"SCPictureBrowser.bundle" stringByAppendingPathComponent:@"loading_circle_large"]];
            self.size = self.imageView.size;
            break;
    }
}

#pragma mark - Public Method

- (void)startAnimating {
    self.hidden = NO;
    self.animating = YES;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    animation.fromValue = @(0);
    animation.toValue = @(M_PI * 2);
    animation.duration = 1.0;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.repeatCount = MAXFLOAT;
    [self.imageView.layer addAnimation:animation forKey:@"rotation"];
}

- (void)stopAnimating {
    self.hidden = YES;
    self.animating = NO;
    [self.imageView.layer removeAnimationForKey:@"rotation"];
}

@end
