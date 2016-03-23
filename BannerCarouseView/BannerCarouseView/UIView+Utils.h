//
//  Created by changjianhong on 16/3/21.
//  Copyright © 2016年 changjianhong. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface UIView (Utils)

@property (nonatomic) CGFloat left;

@property (nonatomic) CGFloat top;

@property (nonatomic) CGFloat right;

@property (nonatomic) CGFloat bottom;

@property (nonatomic) CGFloat width;

@property (nonatomic) CGFloat height;

@property (nonatomic) CGFloat centerX;

@property (nonatomic) CGFloat centerY;

@property (nonatomic, readonly) CGFloat screenX;

@property (nonatomic, readonly) CGFloat screenY;

@property (nonatomic, readonly) CGFloat screenViewX;

@property (nonatomic, readonly) CGFloat screenViewY;

@property (nonatomic, readonly) CGRect screenFrame;

@property (nonatomic) CGPoint origin;

@property (nonatomic) CGSize size;

@property (nonatomic, readonly) CGFloat orientationWidth;

@property (nonatomic, readonly) CGFloat orientationHeight;

- (UIView*)descendantOrSelfWithClass:(Class)cls;

- (UIView*)ancestorOrSelfWithClass:(Class)cls;

- (void)removeAllSubviews;

- (void)setTapActionWithBlock:(void (^)(void))block;

- (void)setLongPressActionWithBlock:(void (^)(void))block;

@end