//
//  OneViewController.m
//  SegmentController
//
//  Created by changjianhong on 16/2/18.
//  Copyright © 2016年 changjianhong. All rights reserved.
//

#import "OneViewController.h"

@interface OneViewController()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation OneViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  NSLog(@"viewdidload");
  [self.view addSubview:self.tableView];
}

- (void)viewDidLayoutSubviews
{
  [super viewDidLayoutSubviews];
  [self.tableView setFrame:self.view.bounds];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  NSLog(@"viewwillappear");
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  NSLog(@"viewwilldisappear");
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  NSLog(@"viewdidAppear");
}

- (void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
  NSLog(@"viewdiddisapear");
}


- (UITableView *)tableView
{
  if (!_tableView) {
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.delegate = self;
    _tableView.dataSource = self;
  }
  return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
  }
  [cell.textLabel setText:@"test"];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  OneViewController * vc = [[OneViewController alloc] init];
  NSLog(@"%@",self.navigationController);
  [self.navigationController pushViewController:vc animated:YES];
}

@end
