//
//  CopyLabel.m
//  Student
//
//  Created by changjianhong on 15/12/8.
//  Copyright © 2015年 creatingev. All rights reserved.
//

#import "CopyLabel.h"

@implementation CopyLabel

- (BOOL)canBecomeFirstResponder
{
  return YES;
}

- (BOOL)canResignFirstResponder
{
  return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
  return action == @selector(copy:) || action == @selector(collect:);
}

- (void)copy:(id)sender
{
  UIPasteboard * board = [UIPasteboard generalPasteboard];
  board.string = self.text;
}

- (void)collect:(id)sender
{
  NSLog(@"collect");
}

- (void)attachTapHandler
{
  self.userInteractionEnabled = YES;
  UITapGestureRecognizer *touch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
  touch.numberOfTapsRequired = 2;
  [self addGestureRecognizer:touch];
}

-(void)handleTap:(UIGestureRecognizer*) recognizer
{
  [self becomeFirstResponder];
  UIMenuItem *copyLink = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copy:)];
  UIMenuItem *collectLink = [[UIMenuItem alloc] initWithTitle:@"收藏" action:@selector(collect:)];
  [[UIMenuController sharedMenuController] setMenuItems:@[copyLink, collectLink]];
  [[UIMenuController sharedMenuController] setTargetRect:self.frame inView:self.superview];
  [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
}

- (id)initWithFrame:(CGRect)frame  {
  self = [super initWithFrame:frame];
  if (self)   {
    [self attachTapHandler];
  }
  return self;
}

- (void)awakeFromNib{
  [super awakeFromNib];
  [self attachTapHandler];
}


@end
