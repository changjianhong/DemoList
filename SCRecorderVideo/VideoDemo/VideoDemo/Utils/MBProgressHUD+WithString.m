//
//  MBProgressHUD+WithString.m
//  MTX
//
//  Created by lvdongdong on 12/17/14.
//  Copyright (c) 2014 creatingev. All rights reserved.
//

#import "MBProgressHUD+WithString.h"
#import <objc/runtime.h>
static const NSString * BLOCK = @"mbprogress_block";

@implementation MBProgressHUD(WithString)
+ (MBProgressHUD *)showHUDAddedTo:(UIView *)view withString:(NSString*)message {
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    hud.labelText = message;
    [view addSubview:hud];
    [hud show:YES];
#if __has_feature(objc_arc)
    return hud;
#else
    return [hud autorelease];
#endif
    
}

+(MBProgressHUD *)showSuccessedHUDAddedTo:(UIView *)view withString:(NSString *)message{
    return [self showSuccessedHUDAddedTo:view withString:message disappareCompletion:nil];
}

+(MBProgressHUD *)showSuccessedHUDAddedTo:(UIView *)view withString:(NSString *)message disappareCompletion:(void(^)())completion{
    MBProgressHUD* successMark = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:successMark];
    successMark.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] ;
    successMark.mode = MBProgressHUDModeCustomView;
    successMark.labelText = message;
    successMark.block = completion;
    [successMark show:YES];
    [successMark hide:YES afterDelay:1];
    [successMark performSelector:@selector(playCompletionBlock) withObject:nil afterDelay:1];
    return successMark;
}

-(void)setBlock:(MBCompletionBlock)block{
    objc_setAssociatedObject(self, &BLOCK, block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(MBCompletionBlock)block{
    return (MBCompletionBlock)objc_getAssociatedObject(self, &BLOCK);
}

-(void)playCompletionBlock{
    if (self.block) {
        self.block();
    }
}

- (BOOL)isOnscreen{
    return self.alpha > 0.5;
}

@end
