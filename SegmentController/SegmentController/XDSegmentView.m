//
//  XDSegmentView.m
//  SegmentController
//
//  Created by changjianhong on 16/2/19.
//  Copyright © 2016年 changjianhong. All rights reserved.
//

#import "XDSegmentView.h"

#define HexColor(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define kButtonWidth self.bounds.size.width/self.buttons.count

@interface XDSegmentView()
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) UIView *bottomLine;
@property (nonatomic, strong) UIView *bottomView;
@end

@implementation XDSegmentView

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    [self setBackgroundColor:[UIColor whiteColor]];
    _bottomLine = [[UIView alloc] init];
    [_bottomLine setBackgroundColor:HexColor(0xE0E0E0)];
    [self addSubview:_bottomLine];
    _bottomView = [[UIView alloc] init];
    [_bottomView setBackgroundColor:[UIColor redColor]];
    [self addSubview:_bottomView];
    _buttons = [NSMutableArray array];
  }
  return self;
}

- (instancetype)initWithItems:(NSArray *)items
{
  if (self = [super init]) {
    self.items = items;
  }
  return self;
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  [_bottomLine setFrame:CGRectMake(0, self.bounds.size.height - 1, self.bounds.size.width, 1)];
  if (self.buttons.count) {
    [_bottomView setFrame:CGRectMake(0, self.bounds.size.height - 2, kButtonWidth, 2)];
    CGFloat x = 0;
    for (UIButton *btn in self.buttons) {
      [btn setFrame:CGRectMake(x, 0, kButtonWidth, self.bounds.size.height)];
      x += kButtonWidth;
    }
  }
}

- (void)setItems:(NSArray *)items
{
  _items = [items copy];
  [items enumerateObjectsUsingBlock:^(NSString *  _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:item forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [button setTitleColor:HexColor(0xc0c0c0) forState:UIControlStateNormal];
    [button setTitleColor:HexColor(0xef6049) forState:UIControlStateSelected];
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [button setTag:idx+100];
    [button addTarget:self action:@selector(_std_btnSelected:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    [self.buttons addObject:button];
  }];
}

- (void)_std_btnSelected:(UIButton *)btn
{
  NSInteger index = btn.tag - 100;
  [self setSelectedIndex:index];
  if (self.selectIndex) {
    self.selectIndex(index);
  }
}

- (void)setBottomViewOffset:(CGPoint)offset
{
  [_bottomView setFrame:CGRectMake(offset.x, 42+offset.y, kButtonWidth, 2)];
}

- (void)setSelectedIndex:(NSInteger)index
{
  [self.buttons enumerateObjectsUsingBlock:^(UIButton *  _Nonnull button, NSUInteger idx, BOOL * _Nonnull stop) {
    if (idx == index) {
      [button setSelected:YES];
    } else {
      [button setSelected:NO];
    }
  }];
}

@end
