//
//  XDSegmentView.h
//  SegmentController
//
//  Created by changjianhong on 16/2/19.
//  Copyright © 2016年 changjianhong. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface XDSegmentView : UIView

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, copy) void(^selectIndex)(NSInteger index);

- (void)setSelectedIndex:(NSInteger)index;
- (void)setBottomViewOffset:(CGPoint)offset;

@end
