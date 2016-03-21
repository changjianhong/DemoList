//
//  XDVideoViewController.h
//  CustomVideo
//
//  Created by changjianhong on 16/3/2.
//  Copyright © 2016年 changjianhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XDVideoViewControllerDelegate;

@interface XDVideoViewController : UIViewController

@property (nonatomic, weak) id<XDVideoViewControllerDelegate> delegate;

@end

@protocol XDVideoViewControllerDelegate <NSObject>

- (void)videoViewController:(UINavigationController *)navigatonController didFinishPickingVideo:(NSURL *)localPath image:(UIImage *)image;

@end