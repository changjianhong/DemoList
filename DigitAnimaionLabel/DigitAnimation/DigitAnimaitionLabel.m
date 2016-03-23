//
//  DigitAnimaitionLabel.m
//  DigitAnimaionLabel
//
//  Created by changjianhong on 16/3/23.
//  Copyright © 2016年 changjianhong. All rights reserved.
//

#import "DigitAnimaitionLabel.h"
#import <CoreText/CoreText.h>
#import <POP.h>

static const CGFloat kItemSpacing = 3;

@implementation DigitAnimaitionLabel

- (void)setBigNum:(NSInteger)bigNum
{
  POPAnimatableProperty *numProp = [POPAnimatableProperty propertyWithName:@"bigNum" initializer:^(POPMutableAnimatableProperty *prop) {
    prop.writeBlock = ^(UILabel *label, const CGFloat values[]) {
      _bigNum = (NSInteger)values[0];
      [self setNeedsDisplay];
    };
  }];
  
  POPBasicAnimation *anim = [POPBasicAnimation animation];
  anim.fromValue = @(_bigNum);
  anim.toValue   = @(bigNum);
  anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
  anim.property = numProp;
  anim.duration = 5.0f;
  [self pop_addAnimation:anim forKey:nil];
}

- (void)drawTextInRect:(CGRect)rect
{
  self.text = [NSString stringWithFormat:@"%ld",(long)self.bigNum];
  NSUInteger length = self.text.length;
  
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  CGContextSaveGState(ctx);
  
  //get drawing font.
  CTFontRef ctFont = CTFontCreateWithName((__bridge CFStringRef)[[self font] fontName], [[self font] pointSize], NULL);
  CGFontRef font = CTFontCopyGraphicsFont(ctFont, NULL);
  CGContextSetFont(ctx, font);
  CGContextSetFontSize(ctx, [[self font] pointSize]);
  CGContextSetCharacterSpacing(ctx, kItemSpacing);
  
  unichar chars[length];
  CGGlyph glyphs[length];
  [[self text] getCharacters:chars range:NSMakeRange(0, length)];
  CTFontGetGlyphsForCharacters(ctFont, chars, glyphs, length);
  
  //得到text的位置
  CGContextSetTextDrawingMode(ctx, kCGTextFill);
  CGContextSetTextPosition(ctx, 0, 0);
  CGContextShowGlyphs(ctx, glyphs, length);

  CGPoint textPosition = CGContextGetTextPosition(ctx);
  CGPoint anchor = CGPointMake(textPosition.x * (-0.5), [[self font] pointSize] * (-0.25));
  CGPoint p = CGPointApplyAffineTransform(anchor, CGAffineTransformMake(1, 0, 0, -1, 0, 1));
  CGContextSetTextMatrix(ctx, CGAffineTransformMakeScale(1, -1));

  
  CGPoint alignment;
  alignment.x = ([self bounds].size.width - textPosition.x) / 2;
  alignment.y = [self bounds].size.height * 0.5 + p.y;

  CGFloat        underLineWidth  = 8.f;
  CGFloat        underLineHeight = 1.5f;
  NSMutableArray *fontXArray = [NSMutableArray array];
  CGPoint points[length];
  CGFloat fontX = 0;
  CGFloat underLineX = 0;
  for (NSInteger i = 0; i < length; i++) {
    NSString *per     = [NSString stringWithCharacters:&chars[i] length:1];
    CGSize   fontSize = [per sizeWithAttributes:@{NSFontAttributeName : self.font}];
    underLineX = fontX + (fontSize.width - underLineWidth) / 2;
    [fontXArray addObject:@(underLineX)];
    
    CGPoint point = CGPointMake(fontX + alignment.x, -alignment.y);
    points[i] = point;
    fontX += fontSize.width + kItemSpacing - 0.5;
  }
 
  CGContextSaveGState(ctx);
  CGContextSetTextDrawingMode(ctx, kCGTextFill);
  CGContextSetFillColorWithColor(ctx, [self textColor].CGColor);
  CGContextSetShadowWithColor(ctx, [self shadowOffset], 0, [self shadowColor].CGColor);
  CGContextShowGlyphsAtPositions(ctx, glyphs, points, length);
  
  for (NSInteger i = 0; i < length;  i++) {
    UIRectFill(CGRectMake(alignment.x + ((NSNumber *)fontXArray[i]).floatValue, alignment.y + 4, underLineWidth, underLineHeight));
  }
  CGContextRestoreGState(ctx);
  CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
  CGContextRestoreGState(ctx);
  
  CFRelease(font);
  CFRelease(ctFont);
}
@end
