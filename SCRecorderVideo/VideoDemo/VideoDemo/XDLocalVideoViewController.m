//
//  XDLocalVideoViewController.m
//  Student
//
//  Created by changjianhong on 16/3/4.
//  Copyright © 2016年 creatingev. All rights reserved.
//

#import "XDLocalVideoViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MBProgressHUD.h>
#import "XDLocalVideoCell.h"
#import "UIView+Utils.h"
#import "UIColor+Hex.h"
#import "SCRecordSessionManager.h"
#import <ReactiveCocoa/ReactiveCocoa.h>


static NSString *VIDEO_DEFAULTNAME = @"videoReadyToUpload.mp4";
#define CACHE_FILE_PATH [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]


@interface XDLocalVideoViewController()<UICollectionViewDelegate, UICollectionViewDataSource, SCAssetExportSessionDelegate>
@property (nonatomic, strong) NSMutableArray *groupArray;
@property (nonatomic, strong) NSMutableArray *lengthArray;
@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, strong) NSMutableArray *urlArray;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (strong, nonatomic) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UILabel *label;
@end

@implementation XDLocalVideoViewController
{
  NSURL *VIDEO_OUTPUTFILE;
}
- (void)viewDidLoad
{
  [super viewDidLoad];
  [self.view setBackgroundColor:[UIColor whiteColor]];
  [self getlibraryVideo];
  [self setupUI];
  VIDEO_OUTPUTFILE = [NSURL fileURLWithPath:[CACHE_FILE_PATH stringByAppendingPathComponent:VIDEO_DEFAULTNAME]];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)setupUI
{
  [self.view addSubview:self.collectionView];
  _label = [[UILabel alloc] init];
  [_label setText:@"只显示5分钟之内的视频"];
  [_label setTextAlignment:NSTextAlignmentCenter];
  [_label setFont:[UIFont systemFontOfSize:14]];
  [_label setTextColor:[UIColor colorWithRGBHex:0x4A4A4A]];
  [self.view addSubview:_label];
}

- (void)viewDidLayoutSubviews
{
  [super viewDidLayoutSubviews];
  [self.label setFrame:CGRectMake(0, 0, self.view.width, 44)];
  [self.collectionView setFrame:CGRectMake(0, 44, self.view.width, self.view.height -44)];
}

- (UICollectionView *)collectionView
{
  if (!_collectionView) {
    UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat itemSpacing = 2;
    NSInteger itemCount = 4;
    flowLayout.minimumLineSpacing = itemSpacing;
    flowLayout.minimumInteritemSpacing = itemSpacing;
    CGFloat width = (self.view.width - 3 * itemSpacing)/itemCount;
    flowLayout.itemSize = CGSizeMake(width, width);
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    [_collectionView setBackgroundColor:[UIColor whiteColor]];
    [_collectionView registerClass:[XDLocalVideoCell class] forCellWithReuseIdentifier:NSStringFromClass([XDLocalVideoCell class])];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
  }
  return _collectionView;
}

#pragma mark Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
  return self.imageArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  XDLocalVideoCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([XDLocalVideoCell class]) forIndexPath:indexPath];
  UIImage * image = self.imageArray[indexPath.row];
  [cell.imageView setImage:image];
  NSNumber * length = self.lengthArray[indexPath.row];
  [cell.signView setText:[NSString stringWithFormat:@"%lds",length.integerValue]];
  return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  UIImage *image = self.imageArray[indexPath.row];
  NSURL *url = self.urlArray[indexPath.row];
  AVAsset *avasset = [AVAsset assetWithURL:url];
  [self saveVideo:avasset image:image];
}

- (void)saveVideo:(AVAsset *)asset image:(UIImage *)image {
  
  [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
  
  SCAssetExportSession *exportSession = [[SCAssetExportSession alloc] initWithAsset:asset];
  exportSession.videoConfiguration.preset = SCPresetLowQuality;
  exportSession.audioConfiguration.preset = SCPresetMediumQuality;
  exportSession.videoConfiguration.maxFrameRate = 35;
  exportSession.outputUrl = VIDEO_OUTPUTFILE;
  exportSession.outputFileType = AVFileTypeMPEG4;
  exportSession.delegate = self;
  
  self.progressHUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
  self.progressHUD.mode = MBProgressHUDModeDeterminate;
  
  @weakify(self);
  [exportSession exportAsynchronouslyWithCompletionHandler:^{
    @strongify(self);
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    [self exportOutputFinish:image];
  }];
}

- (void)exportOutputFinish:(UIImage *)image
{
  self.progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_save_success"]];
  self.progressHUD.mode = MBProgressHUDModeCustomView;
  [self.progressHUD hide:YES afterDelay:0.3];
  
  //action
}

#pragma mark - SCAssetExportSessionDelegate
- (void)assetExportSessionDidProgress:(SCAssetExportSession *)assetExportSession {
  dispatch_async(dispatch_get_main_queue(), ^{
    float progress = assetExportSession.progress;
    self.progressHUD.progress = progress;
  });
}


- (void)getlibraryVideo
{
  self.groupArray = [NSMutableArray array];
  self.imageArray = [NSMutableArray array];
  self.urlArray = [NSMutableArray array];
  self.lengthArray = [NSMutableArray array];
  ALAssetsLibrary * library = [[ALAssetsLibrary alloc] init];
  dispatch_async(dispatch_get_global_queue(0,0), ^{
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
      [group setAssetsFilter:[ALAssetsFilter allVideos]];
      if (group != nil) {
        [self.groupArray addObject:group];
      } else {
        [self.groupArray enumerateObjectsUsingBlock:^(ALAssetsGroup *obj, NSUInteger idx, BOOL * _Nonnull stop) {
          [obj enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result != nil) {
              CGImageRef imageRef = result.thumbnail;
              double value = [[result valueForProperty:ALAssetPropertyDuration] doubleValue];
              if (value > 10.0 && value < 300.0) {
                UIImage * image = [UIImage imageWithCGImage:imageRef];
                NSURL *url = [[result defaultRepresentation] url];
                [self.urlArray addObject:url];
                [self.imageArray addObject:image];
                [self.lengthArray addObject:@(value)];
              }
            }
          }];
          dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
          });
        }];
      }
    };
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
      NSString *errorMessage = nil;
      switch ([error code]) {
        case ALAssetsLibraryAccessUserDeniedError:
        case ALAssetsLibraryAccessGloballyDeniedError:
          errorMessage = @"用户拒绝访问相册,请在<隐私>中开启";
          break;
        default:
          errorMessage = @"Reason unknown.";
          break;
      }
      
      dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"错误,无法访问!"
                                                           message:errorMessage
                                                          delegate:self
                                                 cancelButtonTitle:@"确定"
                                                 otherButtonTitles:nil, nil];
        [alertView show];
      });
    };
    [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:listGroupBlock failureBlock:failureBlock];
  });
}
@end
