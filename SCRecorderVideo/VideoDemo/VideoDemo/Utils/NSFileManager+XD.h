//
//  NSFileManager+XD.h
//  Student
//
//  Created by changjianhong on 16/2/23.
//  Copyright © 2016年 creatingev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (XD)

- (long long) fileSizeAtPath:(NSString*) filePath;
- (float ) folderSizeAtPath:(NSString*) folderPath;
+ (void)deleteFileAtPath:(NSString *)path;
+ (void)deleteFileAtFileURL:(NSURL *)url;

@end
