//
//  MBProgressHUD+WithString.h
//  MTX
//
//  Created by lvdongdong on 12/17/14.
//  Copyright (c) 2014 creatingev. All rights reserved.
//

#import "MBProgressHUD.h"

typedef void(^MBCompletionBlock)();

@interface MBProgressHUD(WithString)

@property (nonatomic, strong) MBCompletionBlock block;

+ (MBProgressHUD *)showHUDAddedTo:(UIView *)view withString:(NSString*)message;

+ (MBProgressHUD *)showSuccessedHUDAddedTo:(UIView *)view withString:(NSString *)message;

+ (MBProgressHUD *)showSuccessedHUDAddedTo:(UIView *)view withString:(NSString *)message disappareCompletion:(void(^)())completion;

- (BOOL)isOnscreen;

@end
