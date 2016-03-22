//
//  ViewController.m
//  CopyLabel
//
//  Created by changjianhong on 15/12/8.
//  Copyright © 2015年 changjianhong. All rights reserved.
//

#import "ViewController.h"
#import "CopyLabel.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet CopyLabel *myLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  _myLabel.text = @"aaaaaaaaaaaaaaa";
  
}


@end
