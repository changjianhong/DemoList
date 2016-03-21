//
//  AppDelegate.m
//  3D-Touch
//
//  Created by changjianhong on 16/2/8.
//  Copyright © 2016年 changjianhong. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Override point for customization after application launch.
  return YES;
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
{
  ViewController * controller = (ViewController *)[[UIApplication sharedApplication] keyWindow].rootViewController;
  NSString * type = shortcutItem.type;
  if ([type isEqualToString:@"touchtype1"]) {
    controller.view.backgroundColor = [UIColor redColor];
  } else if ([type isEqualToString:@"touchtype2"]) {
    controller.view.backgroundColor = [UIColor whiteColor];
  }
}

@end
