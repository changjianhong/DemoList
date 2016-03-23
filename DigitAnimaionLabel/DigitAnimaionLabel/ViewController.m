//
//  ViewController.m
//  DigitAnimaionLabel
//
//  Created by changjianhong on 16/3/23.
//  Copyright © 2016年 changjianhong. All rights reserved.
//

#import "ViewController.h"
#import "DigitAnimaitionLabel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  DigitAnimaitionLabel *label = [[DigitAnimaitionLabel alloc] initWithFrame:CGRectMake(100, 100, 200, 40)];
  label.backgroundColor = [UIColor grayColor];
  label.textColor = [UIColor whiteColor];
  label.textAlignment = NSTextAlignmentCenter;
  label.font = [UIFont boldSystemFontOfSize:24];
  label.bigNum = 19999;
  [self.view addSubview:label];
}
@end
