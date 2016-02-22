//
//  XDSegmentViewController.m
//  SegmentController
//
//  Created by changjianhong on 16/2/20.
//  Copyright © 2016年 changjianhong. All rights reserved.
//

#import "XDSegmentViewController.h"
#import "XDSegmentView.h"

CGFloat const kSegmentHeight = 44;

@interface XDSegmentViewController()<UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIScrollViewDelegate>
@property (nonatomic, strong) UIPageViewController * pageViewController;
@property (nonatomic, strong) XDSegmentView *segmentView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) NSInteger currentIndex;
@end

@implementation XDSegmentViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self.view setBackgroundColor:[UIColor whiteColor]];
  [self addChildViewController:self.pageViewController];
  [self.view addSubview:self.segmentView];

  self.currentIndex = 0;
}

- (void)viewDidLayoutSubviews
{
  [super viewDidLayoutSubviews];
  
}

- (XDSegmentView *)segmentView
{
  if (!_segmentView) {
    _segmentView = [[XDSegmentView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, kSegmentHeight)];
    [_segmentView setItems:self.segmentItems];
    __weak XDSegmentViewController * weakSelf = self;
    _segmentView.selectIndex = ^(NSInteger index){
      NSInteger nowIndex = weakSelf.currentIndex;
      if (index > nowIndex) {
        for (int i = (int)nowIndex+1; i<=index; i++) {
          [weakSelf.pageViewController setViewControllers:@[[weakSelf.viewControllerArray objectAtIndex:i]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL complete){
            if (complete) {
              [weakSelf setCurrentIndex:i];
            }
          }];
        }
      }
      else if (index < nowIndex) {
        for (int i = (int)nowIndex-1; i >= index; i--) {
          [weakSelf.pageViewController setViewControllers:@[[weakSelf.viewControllerArray objectAtIndex:i]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL complete){
            if (complete) {
              [weakSelf setCurrentIndex:i];
            }
          }];
        }
      }
    };
  }
  return _segmentView;
}

- (UIPageViewController *)pageViewController
{
  if (!_pageViewController) {
    NSDictionary *options =[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin]
                                                       forKey: UIPageViewControllerOptionSpineLocationKey];
    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options];
    _pageViewController.delegate = self;
    _pageViewController.dataSource = self;
    [_pageViewController setViewControllers:@[[self.viewControllerArray objectAtIndex:0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
    }];
    [_pageViewController.view setFrame:CGRectMake(0, kSegmentHeight, self.view.frame.size.width, self.view.frame.size.height - kSegmentHeight)];
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [_pageViewController didMoveToParentViewController:self];
    
    //一定在addChildViewController后执行，否则navigation栈会乱
    [_pageViewController setViewControllers:@[[self.viewControllerArray objectAtIndex:0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
    }];    [self _std_setupPageScrollView];
  }
  return _pageViewController;
}

//0 375 750
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
  CGFloat offsetX = self.view.frame.size.width-scrollView.contentOffset.x;
  CGFloat divisionX = self.view.frame.size.width / self.viewControllerArray.count * self.currentIndex;
  CGFloat x = divisionX - offsetX/self.viewControllerArray.count;
  CGFloat segmentOffsetX = x * self.segmentView.frame.size.width / self.view.frame.size.width;
  CGPoint offset = CGPointMake(segmentOffsetX, 0);
  [self.segmentView setBottomViewOffset:offset];
}

#pragma mark DataSource

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
  NSInteger index = [self.viewControllerArray indexOfObject:viewController];
  index--;
  if (index < 0) {
    return nil;
  }
  return self.viewControllerArray[index];
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
  NSInteger index = [self.viewControllerArray indexOfObject:viewController];
  index ++;
  if (index == self.viewControllerArray.count) {
    return nil;
  }
  return self.viewControllerArray[index];
}

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
  if (completed) {
    UIViewController * controller = self.pageViewController.viewControllers.firstObject;
    NSInteger nowIndex = [self.viewControllerArray indexOfObject:controller];
    self.currentIndex = nowIndex;
    [self.segmentView setSelectedIndex:nowIndex];
  }
}

#pragma private method

- (void)_std_setupPageScrollView
{
  for (UIView * view in self.pageViewController.view.subviews) {
    if ([view isKindOfClass:[UIScrollView class]]) {
      UIScrollView * scrollView = (UIScrollView *)view;
      _scrollView = scrollView;
      scrollView.delegate = self;
    }
  }
}


@end
