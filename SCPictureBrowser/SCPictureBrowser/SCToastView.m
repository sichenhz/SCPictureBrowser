//
//  SCToastView.m
//  SCPictureBrowser
//
//  Created by sichenwang on 16/4/5.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import "SCToastView.h"
#import <objc/runtime.h>

static void *toastKey = &toastKey;

@interface SCToastView()

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation SCToastView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = NO;
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        self.alpha = 0;

        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = [UIColor blackColor];
        _backgroundView.alpha = .65;
        [self addSubview:_backgroundView];
        
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:14.0f];
        _contentLabel.numberOfLines = 0;
        _contentLabel.textColor = [UIColor whiteColor];
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_contentLabel];
    }
    return self;
}

+ (void)showInView:(nonnull UIView *)view text:(nonnull NSString *)text duration:(CGFloat)duration autoHide:(BOOL)autoHide {
    if (!view || !text) {
        return;
    }
    
    SCToastView *toastView = objc_getAssociatedObject(view, toastKey);
    if (!toastView) {
        toastView = [[SCToastView alloc] init];
        objc_setAssociatedObject(view, toastKey, toastView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    toastView.contentLabel.text = text;
    
    // layout
    CGSize size = [text boundingRectWithSize:CGSizeMake(240, 320)
                                     options:NSStringDrawingTruncatesLastVisibleLine |
                   NSStringDrawingUsesLineFragmentOrigin |
                   NSStringDrawingUsesFontLeading
                                  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f]}
                                     context:nil].size;
    toastView.contentLabel.frame = CGRectMake(0, 0, size.width, size.height);
    toastView.bounds = CGRectMake(0, 0, size.width + 30, size.height + 15);
    toastView.center = CGPointMake(view.frame.size.width / 2, view.frame.size.height / 2);
    toastView.backgroundView.frame = toastView.bounds;
    toastView.contentLabel.center = CGPointMake(CGRectGetMidX(toastView.bounds), CGRectGetMidY(toastView.bounds));
    
    if (toastView.superview) {
        [toastView removeFromSuperview];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [view addSubview:toastView];
        [UIView animateWithDuration:0.3
                         animations:^{
                             toastView.alpha = 1;
                         }
                         completion:^(BOOL finished) {
                             if (autoHide) {
                                 [UIView animateWithDuration:0.3
                                                       delay:duration
                                                     options:0
                                                  animations:^{
                                                      toastView.alpha = 0;
                                                  }
                                                  completion:^(BOOL finished) {
                                                      [toastView removeFromSuperview];
                                                  }];
                             }
                         }];
    });
}

+ (void)hideInView:(nonnull UIView *)view {
    SCToastView *toastView = objc_getAssociatedObject(view, toastKey);
    if (!view || !toastView) {
        return;
    }
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         toastView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [toastView removeFromSuperview];
                     }];
}

+ (BOOL)isShowingInView:(nonnull UIView *)view {
    SCToastView *toastView = objc_getAssociatedObject(view, toastKey);
    if (!view || !toastView || !toastView.superview) {
        return NO;
    }
    return YES;
}


@end
