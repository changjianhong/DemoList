//
//  XDVideoUtils.h
//  Student
//
//  Created by changjianhong on 16/3/3.
//  Copyright © 2016年 creatingev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface XDVideoUtils : NSObject

+ (UIImage *)getImage:(NSURL *)videoURL;
+ (NSURL *)convert2Mp4:(NSURL *)movUrl;

@end
