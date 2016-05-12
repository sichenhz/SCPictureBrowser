//
//  SCAlertView.h
//  Higo
//
//  Created by sichenwang on 16/3/7.
//  Copyright © 2016年 Ryan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SCAlertActionStyle) {
    SCAlertActionStyleDefault = 0,
    SCAlertActionStyleCancel,
    SCAlertActionStyleConfirm
};

typedef NS_ENUM(NSInteger, SCAlertViewStyle) {
    SCAlertViewStyleAlert = 0,
    SCAlertViewStyleActionSheet
};

NS_ASSUME_NONNULL_BEGIN

@interface SCAlertAction : NSObject

+ (instancetype)actionWithTitle:(nullable NSString *)title style:(SCAlertActionStyle)style handler:(void (^ __nullable)(SCAlertAction *action))handler;

@property (nonatomic, copy, readonly, nullable) NSString *title;
@property (nonatomic, assign, readonly) SCAlertActionStyle style;

@end

@interface SCAlertView : UIView

+ (instancetype)alertViewWithTitle:(nullable NSString *)title message:(nullable NSString *)message style:(SCAlertViewStyle)style;
+ (instancetype)alertViewWithAttributedTitle:(nullable NSAttributedString *)title message:(nullable NSString *)message style:(SCAlertViewStyle)style;
+ (instancetype)alertViewWithTitle:(nullable NSString *)title attributedMessage:(nullable NSAttributedString *)message style:(SCAlertViewStyle)style;
+ (instancetype)alertViewWithAttributedTitle:(nullable NSAttributedString *)title attributedMessage:(nullable NSAttributedString *)message style:(SCAlertViewStyle)style;

- (void)addAction:(SCAlertAction *)action;

@property (nonatomic, strong, readonly) NSArray<SCAlertAction *> *actions;
@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSAttributedString *attrTitle;
@property (nonatomic, copy, nullable) NSString *message;
@property (nonatomic, copy, nullable) NSAttributedString *attrMessage;

@property (nonatomic, readonly) SCAlertViewStyle style;

- (void)show;

@end

NS_ASSUME_NONNULL_END