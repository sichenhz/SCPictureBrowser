//
//  SCAlertView.m
//  Higo
//
//  Created by sichenwang on 16/3/7.
//  Copyright © 2016年 Ryan. All rights reserved.
//

#import "SCAlertView.h"

@interface SCAlertAction()

@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, assign, readwrite) SCAlertActionStyle style;
@property (nonatomic, copy) void (^handler)(SCAlertAction *action);

@end

@implementation SCAlertAction

+ (instancetype)actionWithTitle:(NSString *)title style:(SCAlertActionStyle)style handler:(void (^)(SCAlertAction *action))handler {
    SCAlertAction *alertAction = [[SCAlertAction alloc] init];
    alertAction.title = title;
    alertAction.style = style;
    alertAction.handler = handler;
    return alertAction;
}

@end

@interface SCAlertView()

@property (nonatomic, readwrite) NSArray<SCAlertAction *> *actions;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *messageLabel;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) NSMutableArray *lines;
@property (nonatomic) BOOL isShowing;
@property (nonatomic, weak) UIView *backgroundView;
@property (nonatomic, readwrite) SCAlertViewStyle style;
@property (nonatomic) CGFloat buttonHeight;

@end

@implementation SCAlertView
{
    CGFloat _buttonHeight;
}

#pragma mark - Public Method

+ (instancetype)alertViewWithTitle:(NSString *)title message:(NSString *)message style:(SCAlertViewStyle)style {
    SCAlertView *alertView = [self alertViewWithStyle:style];
    alertView.title = title;
    alertView.message = message;
    return alertView;
}

+ (instancetype)alertViewWithAttributedTitle:(NSAttributedString *)title message:(NSString *)message style:(SCAlertViewStyle)style {
    SCAlertView *alertView = [self alertViewWithStyle:style];
    alertView.attrTitle = title;
    alertView.message = message;
    return alertView;
}

+ (instancetype)alertViewWithTitle:(NSString *)title attributedMessage:(NSAttributedString *)message style:(SCAlertViewStyle)style {
    SCAlertView *alertView = [self alertViewWithStyle:style];
    alertView.title = title;
    alertView.attrMessage = message;
    return alertView;
}

+ (instancetype)alertViewWithAttributedTitle:(NSAttributedString *)title attributedMessage:(NSAttributedString *)message style:(SCAlertViewStyle)style {
    SCAlertView *alertView = [self alertViewWithStyle:style];
    alertView.attrTitle = title;
    alertView.attrMessage = message;
    return alertView;
}

- (void)addAction:(SCAlertAction *)action {
    NSMutableArray *arrM = [NSMutableArray arrayWithArray:self.actions];
    [arrM addObject:action];
    self.actions = [arrM copy];
    [self layoutAlertView];
}

- (void)show {
    if (self.isShowing) {
        return;
    }
    self.isShowing = YES;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.frame = window.bounds;
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.alpha = 0;
    [backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundViewTap:)]];
    [window addSubview:backgroundView];
    _backgroundView = backgroundView;
    [window addSubview:self];
    
    if (self.style == SCAlertViewStyleAlert) {
        self.alpha = 0;
        self.transform = CGAffineTransformMakeScale(1.15, 1.15);
        [UIView animateWithDuration:0.2 animations:^{
            backgroundView.alpha = 0.4;
            self.alpha = 1;
            self.transform = CGAffineTransformMakeScale(1, 1);
        }];
    } else {
        self.transform = CGAffineTransformMakeTranslation(0, self.frame.size.height);
        [UIView animateWithDuration:0.2 animations:^{
            backgroundView.alpha = 0.4;
            self.transform = CGAffineTransformMakeTranslation(0, 0);
        }];
    }
}

- (void)setTitle:(NSString *)title {
    if (_title != title) {
        _title = title;
        self.titleLabel.text = title;
        
        [self layoutAlertView];
    }
}

- (void)setAttrTitle:(NSAttributedString *)attrTitle {
    if (_attrTitle != attrTitle) {
        _attrTitle = attrTitle;
        self.titleLabel.attributedText = attrTitle;
        
        [self layoutAlertView];
    }
}

- (void)setMessage:(NSString *)message {
    if (_message != message) {
        _message = message;
        self.messageLabel.text = message;
        
        [self layoutAlertView];
    }
}

- (void)setAttrMessage:(NSAttributedString *)attrMessage {
    if (_attrMessage != attrMessage) {
        _attrMessage = attrMessage;
        self.messageLabel.attributedText = attrMessage;
        
        [self layoutAlertView];
    }
}

#pragma mark - Private Method

+ (instancetype)alertViewWithStyle:(SCAlertViewStyle)style {
    SCAlertView *alertView = [[SCAlertView alloc] init];
    alertView.backgroundColor = [UIColor colorWithRed:241/255.0 green:241/255.0 blue:237/255.0 alpha:1];
    alertView.style = style;
    if (style == SCAlertViewStyleAlert) {
        alertView.buttonHeight = 44;
        CGFloat width = 270;
        CGFloat x = ([UIScreen mainScreen].bounds.size.width - width) / 2.0;
        alertView.frame = CGRectMake(x, 0, width, 0);
        alertView.layer.cornerRadius = 12;
        alertView.clipsToBounds = YES;
    } else {
        alertView.buttonHeight = 50;
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        alertView.frame = CGRectMake(0, 0, width, 0);
    }
    return alertView;
}

- (void)layoutAlertView {
    if (self.style == SCAlertViewStyleAlert) {
        [self layoutAlert];
    } else {
        [self layoutActionSheet];
    }
}

- (void)layoutActionSheet {
    CGFloat height = 0;
    CGFloat labelWidth = self.frame.size.width - 32;
    if (self.title || self.attrTitle) {
        height += 14;
        CGRect frame = self.titleLabel.frame;
        frame.origin.y = height;
        frame.size.height = [self.titleLabel sizeThatFits:CGSizeMake(labelWidth, MAXFLOAT)].height;
        self.titleLabel.frame = frame;
        height += frame.size.height;
    }
    
    if (self.message || self.attrMessage) {
        if (self.title || self.attrTitle) {
            height += 2;
        } else {
            height += 14;
        }
        CGRect frame = self.messageLabel.frame;
        frame.origin.y = height;
        frame.size.height = [self.messageLabel sizeThatFits:CGSizeMake(labelWidth, MAXFLOAT)].height;
        self.messageLabel.frame = frame;
        height += frame.size.height;
    }
    
    if ((self.title || self.attrTitle) || (self.message || self.attrMessage)) {
        height += 14;
    }
    
    if (self.actions.count) {
        NSInteger indexOfCancel = -1;
        for (SCAlertAction *action in self.actions) {
            NSInteger index = [self.actions indexOfObject:action];
            if (action.style != SCAlertActionStyleCancel) {
                UIView *line = [self layoutLine:action index:index height:height];
                height += line.frame.size.height;
                UIButton *button = [self layoutButton:action index:index height:height];
                height += button.frame.size.height;
            } else {
                NSAssert(indexOfCancel == -1, @"SCAlertView can only have one action with a style of SCAlertActionStyleCancel");
                indexOfCancel = index;
            }
        }
        if (indexOfCancel >= 0) {
            UIView *line = [self layoutLine:self.actions[indexOfCancel] index:indexOfCancel height:height];
            height += line.frame.size.height;
            UIButton *button = [self layoutButton:self.actions[indexOfCancel] index:indexOfCancel height:height];
            height += button.frame.size.height;
        }
    }

    CGRect frame = self.frame;
    frame.size.height = height;
    frame.origin.y = [UIScreen mainScreen].bounds.size.height - height;
    self.frame = frame;
}

- (void)layoutAlert {
    CGFloat height = 0;
    CGFloat labelWidth = self.frame.size.width - 32;
    if (self.title || self.attrTitle) {
        height += 22;
        CGRect frame = self.titleLabel.frame;
        frame.origin.y = height;
        frame.size.height = [self.titleLabel sizeThatFits:CGSizeMake(labelWidth, MAXFLOAT)].height;
        self.titleLabel.frame = frame;
        height += frame.size.height;
    }
    
    if (self.message || self.attrMessage) {
        if (self.title || self.attrTitle) {
            height += 5;
        } else {
            height += 22;
        }
        CGRect frame = self.messageLabel.frame;
        frame.origin.y = height;
        frame.size.height = [self.messageLabel sizeThatFits:CGSizeMake(labelWidth, MAXFLOAT)].height;
        self.messageLabel.frame = frame;
        height += frame.size.height;
    }
    
    if ((self.title || self.attrTitle) || (self.message || self.attrMessage)) {
        height += 20;
    }
    
    if (self.actions.count) {
        if (self.actions.count == 2) {
            UIView *line = [self layoutLine:self.actions[0] index:0 height:height];
            height += line.frame.size.height;
            UIButton *button = [self createButton:self.actions[0] index:0];
            button.frame = CGRectMake(0, height, self.frame.size.width / 2, self.buttonHeight);
            
            line = [self layoutLine:self.actions[1] index:1 height:height];
            line.frame = CGRectMake(self.frame.size.width / 2, height, 0.5, self.buttonHeight);
            button = [self createButton:self.actions[1] index:1];
            button.frame = CGRectMake(self.frame.size.width / 2, height, self.frame.size.width / 2, self.buttonHeight);
            height += button.frame.size.height;
            
        } else {
            NSInteger indexOfCancel = -1;
            for (SCAlertAction *action in self.actions) {
                NSInteger index = [self.actions indexOfObject:action];
                if (action.style != SCAlertActionStyleCancel) {
                    UIView *line = [self layoutLine:action index:index height:height];
                    height += line.frame.size.height;
                    UIButton *button = [self layoutButton:action index:index height:height];
                    height += button.frame.size.height;
                } else {
                    NSAssert(indexOfCancel == -1, @"SCAlertView can only have one action with a style of SCAlertActionStyleCancel");
                    indexOfCancel = index;
                }
            }
            if (indexOfCancel >= 0) {
                UIView *line = [self layoutLine:self.actions[indexOfCancel] index:indexOfCancel height:height];
                height += line.frame.size.height;
                UIButton *button = [self layoutButton:self.actions[indexOfCancel] index:indexOfCancel height:height];
                height += button.frame.size.height;
            }
        }
    }
    
    CGRect frame = self.frame;
    frame.size.height = height;
    frame.origin.y = ([UIScreen mainScreen].bounds.size.height - height) / 2;
    self.frame = frame;
}

- (UIView *)layoutLine:(SCAlertAction *)action index:(NSInteger)index height:(CGFloat)height {
    UIView *line = [self createLine:action index:index];
    CGRect frame = line.frame;
    frame.origin.y = height;
    line.frame = frame;
    return line;
}

- (UIButton *)layoutButton:(SCAlertAction *)action index:(NSInteger)index height:(CGFloat)height {
    UIButton *button = [self createButton:action index:index];
    button.frame = CGRectMake(0, height, self.frame.size.width, self.buttonHeight);
    return button;
}

- (UIImage *)cornerRadiusBackgroundImage {
    UIGraphicsBeginImageContext(CGSizeMake(1, 1));
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:1].CGColor);
    CGContextFillRect(ctx, CGRectMake(0, 0, 1, 1));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIButton *)createButton:(SCAlertAction *)action index:(NSInteger)index {
    UIButton *button;
    if (self.buttons.count > index) {
        button = self.buttons[index];
    } else {
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[self cornerRadiusBackgroundImage] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = index + 1000;
        [self addSubview:button];
        [self.buttons addObject:button];
    }
    if (action.style == SCAlertActionStyleConfirm) {
        [button setTitleColor:[UIColor colorWithRed:255/255.0 green:102/255.0 blue:102/255.0 alpha:1] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    } else if (action.style == SCAlertActionStyleCancel) {
        [button setTitleColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    } else {
        [button setTitleColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:17];
    }
    [button setTitle:action.title forState:UIControlStateNormal];
    return button;
}

- (UIView *)createLine:(SCAlertAction *)action index:(NSInteger)inedx {
    UIView *line;
    if (self.lines.count > inedx) {
        line = self.lines[inedx];
    } else {
        line = [[UIView alloc] init];
        [self addSubview:line];
        [self.lines addObject:line];
    }
    if (self.style == SCAlertViewStyleActionSheet && action.style == SCAlertActionStyleCancel) {
        line.frame = CGRectMake(0, 0, self.frame.size.width, 5);
        line.backgroundColor = [UIColor colorWithRed:130/255.0 green:130/255.0 blue:130/255.0 alpha:1];
    } else {
        line.frame = CGRectMake(0, 0, self.frame.size.width, 0.5);
        line.backgroundColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1];
    }
    return line;
}

- (void)buttonPressed:(UIButton *)sender {
    [self dismiss];
    SCAlertAction *action = self.actions[sender.tag - 1000];
    if (action.handler) {
        action.handler(action);
    }
}

- (void)backgroundViewTap:(id)sender {
    if (self.style == SCAlertViewStyleActionSheet) {
        [self dismiss];
    }
}

- (void)dismiss {
    if (!self.isShowing) {
        return;
    }
    self.isShowing = NO;
    
    if (self.style == SCAlertViewStyleAlert) {
        [UIView animateWithDuration:0.3 animations:^{
            self.backgroundView.alpha = 0;
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self.backgroundView removeFromSuperview];
            [self removeFromSuperview];
        }];
    } else {
        self.transform = CGAffineTransformMakeTranslation(0, 0);
        [UIView animateWithDuration:0.3 animations:^{
            self.backgroundView.alpha = 0;
            self.transform = CGAffineTransformMakeTranslation(0, self.frame.size.height);
        } completion:^(BOOL finished) {
            [self.backgroundView removeFromSuperview];
            [self removeFromSuperview];
        }];
    }
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *label = [[UILabel alloc] init];
        CGFloat width = self.frame.size.width - 32;
        CGFloat x = (self.frame.size.width - width) / 2;
        label.frame = CGRectMake(x, 0, width, 0);
        label.font = [UIFont boldSystemFontOfSize:17];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        label.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [self addSubview:label];
        _titleLabel = label;
    }
    return _titleLabel;
}

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        UILabel *label = [[UILabel alloc] init];
        CGFloat width = self.frame.size.width - 32;
        CGFloat x = (self.frame.size.width - width) / 2;
        label.frame = CGRectMake(x, 0, width, 0);
        label.font = [UIFont systemFontOfSize:13];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        label.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1];
        [self addSubview:label];
        _messageLabel = label;
    }
    return _messageLabel;
}

- (NSMutableArray *)buttons {
    if (!_buttons) {
        _buttons = [NSMutableArray array];
    }
    return _buttons;
}

- (NSMutableArray *)lines {
    if (!_lines) {
        _lines = [NSMutableArray array];
    }
    return _lines;
}

@end
