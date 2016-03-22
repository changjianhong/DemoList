//
//  ViewController.m
//  XDKeyBoard
//
//  Created by changjianhong on 16/3/1.
//  Copyright © 2016年 changjianhong. All rights reserved.
//

#import "ViewController.h"
#import "XDToolBar.h"

@interface ViewController ()<XDToolBarDelegate>
@property (nonatomic, strong) XDToolBar *chatBar;
@property (nonatomic, strong) UILabel *label;
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 375, 200)];
  label.numberOfLines = 0;
  _label = label;
  [label setBackgroundColor:[UIColor grayColor]];
  [self.view addSubview:label];
  [self.view addSubview:self.chatBar];

}

- (XDToolBar *)chatBar {
  if (!_chatBar) {
    _chatBar = [[XDToolBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
    [_chatBar setSuperViewHeight:[UIScreen mainScreen].bounds.size.height];
    _chatBar.delegate = self;
  }
  return _chatBar;
}

- (void)toolBar:(XDToolBar *)chatBar sendMessage:(NSString *)message
{
  self.label.text = message;
}

@end
