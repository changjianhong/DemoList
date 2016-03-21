//
//  Created by changjianhong on 16/3/21.
//  Copyright © 2016年 changjianhong. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UIColorFromRGBHex(hexValue) [UIColor \
colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 \
green:((float)((hexValue & 0xFF00) >> 8))/255.0 \
blue:((float)(hexValue & 0xFF))/255.0 alpha:1.0]

@interface UIColor (Hex)

+ (UIColor *)colorWithARGBHex:(NSInteger)hexValue;

+ (UIColor *)colorWithRGBHex:(NSInteger)hexValue;

+ (UIColor *)whiteColorWithAlpha:(CGFloat)alphaValue;

+ (UIColor *)blackColorWithAlpha:(CGFloat)alphaValue;

+ (UIColor *)colorWithRGBHex:(NSInteger)hexValue alpha:(CGFloat)alpha;

- (UIColor *)blackOrWhiteContrastingColor;

- (CGFloat)luminosity;

@end
