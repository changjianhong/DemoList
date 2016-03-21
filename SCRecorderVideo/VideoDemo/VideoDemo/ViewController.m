//
//  ViewController.m
//  VideoDemo
//
//  Created by changjianhong on 16/3/21.
//  Copyright © 2016年 changjianhong. All rights reserved.
//

#import "ViewController.h"
#import "XDVideoViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}
- (IBAction)start:(id)sender {
  XDVideoViewController * controller = [[XDVideoViewController alloc] init];
  UINavigationController * navi = [[UINavigationController alloc] initWithRootViewController:controller];
  [self presentViewController:navi animated:YES completion:nil];
}

@end
