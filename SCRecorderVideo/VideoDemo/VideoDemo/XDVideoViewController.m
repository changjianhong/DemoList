//
//  XDVideoViewController.m
//  CustomVideo
//
//  Created by changjianhong on 16/3/2.
//  Copyright © 2016年 changjianhong. All rights reserved.
//

#define VIDEO_MAX_TIME       300.0
#define VIDEO_VALID_MINTIME  10.0

#import "XDVideoViewController.h"
#import "SCRecordSessionManager.h"
#import "XDLocalVideoViewController.h"
#import "MBProgressHUD+WithString.h"
#import "SCRecorder.h"
#import "MBProgressHUD.h"
#import "XDVideoUtils.h"
#import "NSFileManager+XD.h"
#import "XDDurationUtils.h"

#define CACHE_FILE_PATH [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]
static NSString *VIDEO_DEFAULTNAME = @"videoReadyToUpload.mp4";

@interface XDVideoViewController()<SCRecorderDelegate, SCAssetExportSessionDelegate>
@property (weak, nonatomic) IBOutlet UIView *scanPreview;
@property (weak, nonatomic) IBOutlet UIView *toolView;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *reRecord;
@property (weak, nonatomic) IBOutlet UILabel *localLabel;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UILabel *currentDuration;
@property (weak, nonatomic) IBOutlet UIButton *localButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIView *progressView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressWidth;
@property (strong, nonatomic) MBProgressHUD *progressHUD;

@property (strong, nonatomic) SCRecorderToolsView *focusView;

@end

@implementation XDVideoViewController
{
  BOOL isVideoValid;
  BOOL isRecording;
  
  NSTimer *recordedTime;
  SCRecorder *_recorder;
  SCPlayer *_player;
  SCRecordSession *_recordSession;
  NSURL *VIDEO_OUTPUTFILE;
}
- (void)viewDidLoad
{
  [super viewDidLoad];
  [self setup];
  [self configRecorder];
}

- (void)setup
{
  VIDEO_OUTPUTFILE = [NSURL fileURLWithPath:[CACHE_FILE_PATH stringByAppendingPathComponent:VIDEO_DEFAULTNAME]];
  isVideoValid = NO;
  isRecording = NO;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.navigationController setNavigationBarHidden:YES animated:YES];
  [self prepareSession];
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  [_recorder previewViewFrameChanged];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [_recorder startRunning];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  [_recorder stopRunning];
}

- (void)dealloc {
  _recorder.previewView = nil;
  [_player pause];
  _player = nil;
}

- (void)initProgressView
{
  self.progressWidth.constant = 0;
}

- (void)refreshProgressViewLengthByTime:(CMTime)duration {
  CGFloat durationTime = CMTimeGetSeconds(duration);
  NSString *durationStr = [XDDurationUtils time_M_S_BySeconds:durationTime];
  [self.currentDuration setText:durationStr];
  CGFloat progressWidthConstant = durationTime / VIDEO_MAX_TIME * 375;
  self.progressWidth.constant = progressWidthConstant;
}

- (void)recordFinishWithRecordValid:(BOOL)isRecordValid
{
  [_recorder pause:^{
    if (isVideoValid) {
      [self setupButton:YES];
      [self configPreviewMode];
    } else {//不符合 重新录制
      [self showTip:NO];
      [self setupButton:NO];
      [NSFileManager deleteFileAtFileURL:_recorder.session.outputUrl];
      SCRecordSession *recordSession = _recorder.session;
      if (recordSession != nil) {
        _recorder.session = nil;
        if ([[SCRecordSessionManager sharedInstance] isSaved:recordSession]) {
          [recordSession endSegmentWithInfo:nil completionHandler:nil];
        } else {
          [recordSession cancelSession:nil];
        }
      }
      [self prepareSession];
    }
  }];
}

- (void)showTip:(BOOL)isShow
{
  if (isShow) return;
  [MBProgressHUD showSuccessedHUDAddedTo:self.view withString:@"时间不小于10.0s"];
}

#pragma mark - View Config
- (void)configRecorder {
  _recorder = [SCRecorder recorder];
  _recorder.captureSessionPreset = [SCRecorderTools bestCaptureSessionPresetCompatibleWithAllDevices];
  _recorder.maxRecordDuration = CMTimeMake(30 * 300, 30);
  _recorder.delegate = self;
  _recorder.autoSetVideoOrientation = YES;
  UIView *previewView = self.scanPreview;
  _recorder.previewView = previewView;
  self.focusView = [[SCRecorderToolsView alloc] initWithFrame:previewView.bounds];
  self.focusView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
  self.focusView.recorder = _recorder;
  [previewView addSubview:self.focusView];
  self.focusView.outsideFocusTargetImage = [UIImage imageNamed:@"video_scan"];
  _recorder.initializeSessionLazily = NO;
  NSError *error;
  if (![_recorder prepare:&error]) {
    NSLog(@"Prepare error: %@", error.localizedDescription);
  }
}

- (void)prepareSession {
  if (_recorder.session == nil) {
    SCRecordSession *session = [SCRecordSession recordSession];
    session.fileType = AVFileTypeQuickTimeMovie;
    _recorder.session = session;
    SCVideoConfiguration *video = _recorder.videoConfiguration;
    video.scalingMode = AVVideoScalingModeResizeAspect;
  }
}

- (void)configPreviewMode {
  _player = [SCPlayer player];
  SCVideoPlayerView *playerView = [[SCVideoPlayerView alloc] initWithPlayer:_player];
  playerView.tag = 400;
  playerView.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
  playerView.frame = self.scanPreview.bounds;
  playerView.autoresizingMask = self.scanPreview.autoresizingMask;
  [self.scanPreview addSubview:playerView];
  _player.loopEnabled = YES;
  [_player setItemByAsset:_recorder.session.assetRepresentingSegments];
}

- (void)removePreviewMode {
  [_player pause];
  _player = nil;
  for (UIView *subview in self.scanPreview.subviews) {
    if (subview.tag == 400) {
      [subview removeFromSuperview];
    }
  }
  [self recordFinishWithRecordValid:NO];
}

- (void)saveVideo {
  [_player pause];
  
  [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
  SCAssetExportSession *exportSession = [[SCAssetExportSession alloc] initWithAsset:_recorder.session.assetRepresentingSegments];
  exportSession.videoConfiguration.preset = SCPresetLowQuality;
  exportSession.audioConfiguration.preset = SCPresetMediumQuality;
  exportSession.videoConfiguration.maxFrameRate = 35;
  exportSession.outputUrl = VIDEO_OUTPUTFILE;
  exportSession.outputFileType = AVFileTypeMPEG4;
  exportSession.delegate = self;
  
  self.progressHUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
  self.progressHUD.mode = MBProgressHUDModeDeterminate;
  [exportSession exportAsynchronouslyWithCompletionHandler:^{
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    [self exportOutputFinish];
  }];
}

- (void)exportOutputFinish
{
  [NSFileManager deleteFileAtFileURL:_recorder.session.outputUrl];
  self.progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_save_success"]];
  self.progressHUD.mode = MBProgressHUDModeCustomView;
  [self.progressHUD hide:YES afterDelay:0.3];
  UIImage *shotImage = [XDVideoUtils getImage:VIDEO_OUTPUTFILE];
  NSLog(@"%lld",[[NSFileManager defaultManager] fileSizeAtPath:VIDEO_OUTPUTFILE.path]);
  
  //action
  if ([self.delegate respondsToSelector:@selector(videoViewController:didFinishPickingVideo:image:)]) {
    [self.delegate videoViewController:self.navigationController didFinishPickingVideo:VIDEO_OUTPUTFILE image:shotImage];
  }
}

#pragma mark SCRecorderDelegate
- (void)recorder:(SCRecorder *)recorder didAppendVideoSampleBufferInSession:(SCRecordSession *)recordSession {
  [self refreshProgressViewLengthByTime:recordSession.duration];
}

- (void)recorder:(SCRecorder *__nonnull)recorder didCompleteSession:(SCRecordSession *__nonnull)session {
  if (isVideoValid) {
    [self recordFinishWithRecordValid:YES];
  } else {
    [self recordFinishWithRecordValid:NO];
  }
}

#pragma mark - SCAssetExportSessionDelegate
- (void)assetExportSessionDidProgress:(SCAssetExportSession *)assetExportSession {
  dispatch_async(dispatch_get_main_queue(), ^{
    float progress = assetExportSession.progress;
    self.progressHUD.progress = progress;
  });
}


#pragma mark action
- (IBAction)closeAction:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)startAction:(id)sender {
//  [self configPreviewMode ];
  self.startButton.selected = !self.startButton.selected;
  [self judgeMinTime];
  if (!isRecording) {
    [_recorder record];
    isRecording = YES;
  } else {
    [self recordFinishWithRecordValid:isVideoValid];
    isRecording = NO;
  }
}

- (IBAction)localAction:(id)sender {
  XDLocalVideoViewController * controller = [[XDLocalVideoViewController alloc] init];
  [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)saveAction:(id)sender {
  [self saveVideo];
}

- (IBAction)reRecordAction:(id)sender {
  isVideoValid = NO;
  [self initProgressView];
  [self removePreviewMode];
}

- (void)setupButton:(BOOL)isShow
{
  [self.saveButton setHidden:!isShow];
  [self.reRecord setHidden:!isShow];
  [self.playButton setHidden:!isShow];
  
  [self.startButton setHidden:isShow];
  [self.localLabel setHidden:isShow];
  [self.localButton setHidden:isShow];
}

//min time
- (void)judgeMinTime
{
  if (recordedTime) {
    [recordedTime invalidate];
    recordedTime = nil;
  } else {
    recordedTime = [NSTimer scheduledTimerWithTimeInterval:VIDEO_VALID_MINTIME target:self selector:@selector(videoStatusSuccess) userInfo:nil repeats:NO];
  }
}
- (IBAction)playAction:(UIButton *)sender {
  sender.selected = !sender.selected;
  if ([_player isPlaying]) {
    [_player pause];
  } else {
    [_player play];
  }
}

- (void)videoStatusSuccess
{
  isVideoValid = YES;
}


@end
