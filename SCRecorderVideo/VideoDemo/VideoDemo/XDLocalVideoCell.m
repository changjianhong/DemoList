//
//  XDLocalVideoCell.m
//  Student
//
//  Created by changjianhong on 16/3/4.
//  Copyright © 2016年 creatingev. All rights reserved.
//

#import "XDLocalVideoCell.h"
#import "UIView+Utils.h"

@interface XDLocalVideoCell()
@end

@implementation XDLocalVideoCell

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    _imageView = [[UIImageView alloc] init];
    [_imageView setBackgroundColor:[UIColor whiteColor]];
    [self.contentView addSubview:_imageView];
    
    _signView = [[UILabel alloc] init];
    [_signView setFont:[UIFont systemFontOfSize:10]];
    [_signView setTextColor:[UIColor whiteColor]];
    [_signView setTextAlignment:NSTextAlignmentRight];
    [self.contentView addSubview:_signView];
    
  }
  return self;
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  [_imageView setFrame:self.bounds];
  [_signView setFrame:CGRectMake(0, self.height - 10, self.width, 10)];
}

@end
