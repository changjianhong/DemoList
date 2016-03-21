//
//  NSFileManager+XD.m
//  Student
//
//  Created by changjianhong on 16/2/23.
//  Copyright © 2016年 creatingev. All rights reserved.
//

#import "NSFileManager+XD.h"

@implementation NSFileManager (XD)

- (long long) fileSizeAtPath:(NSString*) filePath{
  NSFileManager* manager = [NSFileManager defaultManager];
  if ([manager fileExistsAtPath:filePath]){
    return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
  }
  return 0;
}
- (float ) folderSizeAtPath:(NSString*) folderPath{
  NSFileManager* manager = [NSFileManager defaultManager];
  if (![manager fileExistsAtPath:folderPath]) return 0;
  NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
  NSString* fileName;
  long long folderSize = 0;
  while ((fileName = [childFilesEnumerator nextObject]) != nil){
    NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
    folderSize += [self fileSizeAtPath:fileAbsolutePath];
  }
  return folderSize/(1024.0*1024.0);
}

+ (void)deleteFileAtPath:(NSString *)path
{
  NSFileManager* manager = [NSFileManager defaultManager];
  if ([manager fileExistsAtPath:path]) {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
      NSError *error = nil;
      BOOL flag = [manager removeItemAtURL:[NSURL fileURLWithPath:path] error:&error];
      dispatch_async(dispatch_get_main_queue(), ^{
        if (!flag) {
          NSLog(@"failed to remove file, error:%@.", [error localizedFailureReason]);
        }
      });
    });
  }
}

+ (void)deleteFileAtFileURL:(NSURL *)url
{
  [self deleteFileAtPath:url.path];
}

@end
