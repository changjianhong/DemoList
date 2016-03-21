//
//  XDDurationUtils.m
//  Student
//
//  Created by changjianhong on 16/3/8.
//  Copyright © 2016年 creatingev. All rights reserved.
//

#import "XDDurationUtils.h"

@implementation XDDurationUtils

+ (NSString *)time_M_S_BySeconds:(NSTimeInterval)seconds
{
  int duration = (int)seconds;
  int s = duration % 60;
  int m = duration / 60;
  return [NSString stringWithFormat:@"%d:%.2d",m,s];
}

@end
