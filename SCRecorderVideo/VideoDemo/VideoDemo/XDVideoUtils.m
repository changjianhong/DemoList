//
//  XDVideoUtils.m
//  Student
//
//  Created by changjianhong on 16/3/3.
//  Copyright © 2016年 creatingev. All rights reserved.
//

#import "XDVideoUtils.h"
#import <AVFoundation/AVFoundation.h>

@implementation XDVideoUtils

+ (UIImage *)getImage:(NSURL *)videoURL
{
  AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:videoURL options:nil];//
  AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
  generator.appliesPreferredTrackTransform = YES;
  generator.maximumSize = CGSizeMake(1136, 640);
  NSError *error = nil;
  CGImageRef img = [generator copyCGImageAtTime:CMTimeMake(10, 10) actualTime:NULL error:&error];
  UIImage *image = [UIImage imageWithCGImage: img];
  return image;
}

#pragma mark - helper
+ (NSURL *)convert2Mp4:(NSURL *)movUrl {
  NSURL *mp4Url = nil;
  AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movUrl options:nil];
  NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
  
  if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset
                                                                          presetName:AVAssetExportPresetHighestQuality];
    mp4Url = [movUrl copy];
    mp4Url = [mp4Url URLByDeletingPathExtension];
    mp4Url = [mp4Url URLByAppendingPathExtension:@"mp4"];
    exportSession.outputURL = mp4Url;
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputFileType = AVFileTypeMPEG4;
    dispatch_semaphore_t wait = dispatch_semaphore_create(0l);
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
      switch ([exportSession status]) {
        case AVAssetExportSessionStatusFailed: {
          NSLog(@"failed, error:%@.", exportSession.error);
        } break;
        case AVAssetExportSessionStatusCancelled: {
          NSLog(@"cancelled.");
        } break;
        case AVAssetExportSessionStatusCompleted: {
          NSLog(@"completed.");
        } break;
        default: {
          NSLog(@"others.");
        } break;
      }
      dispatch_semaphore_signal(wait);
    }];
    long timeout = dispatch_semaphore_wait(wait, DISPATCH_TIME_FOREVER);
    if (timeout) {
      NSLog(@"timeout.");
    }
    if (wait) {
      //dispatch_release(wait);
      wait = nil;
    }
  }
  
  return mp4Url;
}

@end
