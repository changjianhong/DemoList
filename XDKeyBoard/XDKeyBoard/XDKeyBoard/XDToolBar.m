//
//  XDToolBar.m
//  XDKeyBoard
//
//  Created by changjianhong on 16/3/1.
//  Copyright © 2016年 changjianhong. All rights reserved.
//

#define kMaxHeight 60.0f
#define kMinHeight 44.0f
#define kFunctionViewHeight 180.0f

#import "XDToolBar.h"
#import "XMProgressHUD.h"
#import "Masonry.h"
#import "EaseFaceView.h"
#import "EaseEmotionManager.h"
#import "EaseEmoji.h"
#import "EaseEmotionEscape.h"

@interface XDToolBar()<UITextViewDelegate,UINavigationControllerDelegate,EMFaceDelegate>

@property (strong, nonatomic) UIButton *voiceButton; /**< 切换录音模式按钮 */
@property (strong, nonatomic) UIButton *voiceRecordButton; /**< 录音按钮 */

@property (strong, nonatomic) UIButton *faceButton; /**< 表情按钮 */

@property (strong, nonatomic) UITextView *textView;

@property (assign, nonatomic, readonly) CGFloat bottomHeight;
@property (strong, nonatomic, readonly) UIViewController *rootViewController;

@property (assign, nonatomic) CGRect keyboardFrame;
@property (copy, nonatomic) NSString *inputText;
@property (strong, nonatomic) EaseFaceView * faceView;

@end

@implementation XDToolBar

- (instancetype)initWithFrame:(CGRect)frame{
  if ([super initWithFrame:frame]) {
    [self setup];
  }
  return self;
}

- (void)updateConstraints{
  [super updateConstraints];
  [self.voiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.mas_left).with.offset(10);
    make.top.equalTo(self.mas_top).with.offset(8);
    make.width.equalTo(self.voiceButton.mas_height);
  }];
  
  [self.faceButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.right.equalTo(self).with.offset(-10);
    make.top.equalTo(self.mas_top).with.offset(8);
    make.width.equalTo(self.faceButton.mas_height);
  }];
  
  [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.voiceButton.mas_right).with.offset(10);
    make.right.equalTo(self.faceButton.mas_left).with.offset(-10);
    make.top.equalTo(self.mas_top).with.offset(4);
    make.bottom.equalTo(self.mas_bottom).with.offset(-4);
  }];
}

- (void)dealloc{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
  
  if ([text isEqualToString:@"\n"]) {
    [self sendTextMessage:textView.text];
    return NO;
  }else if (text.length == 0){
    //判断删除的文字是否符合表情文字规则
    NSString *deleteText = [textView.text substringWithRange:range];
    if ([deleteText isEqualToString:@"]"]) {
      NSUInteger location = range.location;
      NSUInteger length = range.length;
      NSString *subText;
      while (YES) {
        if (location == 0) {
          return YES;
        }
        location -- ;
        length ++ ;
        subText = [textView.text substringWithRange:NSMakeRange(location, length)];
        if (([subText hasPrefix:@"["] && [subText hasSuffix:@"]"])) {
          break;
        }
      }
      textView.text = [textView.text stringByReplacingCharactersInRange:NSMakeRange(location, length) withString:@""];
      [textView setSelectedRange:NSMakeRange(location, 0)];
      [self textViewDidChange:self.textView];
      return NO;
    }
  }
  return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
  self.faceButton.selected = self.voiceButton.selected = NO;
  [self showFaceView:NO];
  [self showVoiceView:NO];
  return YES;
}

- (void)textViewDidChange:(UITextView *)textView{
  
  CGRect textViewFrame = self.textView.frame;
  
  CGSize textSize = [self.textView sizeThatFits:CGSizeMake(CGRectGetWidth(textViewFrame), 1000.0f)];
  
  CGFloat offset = 10;
  textView.scrollEnabled = (textSize.height + 0.1 > kMaxHeight-offset);
  textViewFrame.size.height = MAX(34, MIN(kMaxHeight, textSize.height));
  
  CGRect addBarFrame = self.frame;
  addBarFrame.size.height = textViewFrame.size.height+offset;
  addBarFrame.origin.y = self.superViewHeight - self.bottomHeight - addBarFrame.size.height;
  [self setFrame:addBarFrame animated:NO];
  if (textView.scrollEnabled) {
    [textView scrollRangeToVisible:NSMakeRange(textView.text.length - 2, 1)];
  }
  
}

#pragma mark - MP3RecordedDelegate

- (void)endConvertWithMP3FileName:(NSString *)fileName {
  if (fileName) {
    [XMProgressHUD dismissWithProgressState:XMProgressSuccess];
    [self sendVoiceMessage:fileName seconds:[XMProgressHUD seconds]];
  }else{
    [XMProgressHUD dismissWithProgressState:XMProgressError];
  }
}

- (void)failRecord{
  [XMProgressHUD dismissWithProgressState:XMProgressError];
}

- (void)beginConvert{
  NSLog(@"开始转换");
  [XMProgressHUD changeSubTitle:@"正在转换..."];
}

#pragma mark - Public Methods

- (void)endInputing{
  [self showViewWithType:XDFunctionViewShowNothing];
}

#pragma mark - Private Methods

- (void)keyboardWillHide:(NSNotification *)notification{
  self.keyboardFrame = CGRectZero;
  [self textViewDidChange:self.textView];
}

- (void)keyboardFrameWillChange:(NSNotification *)notification{
  self.keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
  [self textViewDidChange:self.textView];
}

- (void)setup{
  
  //    self.MP3 = [[Mp3Recorder alloc] initWithDelegate:self];
  [self addSubview:self.voiceButton];
  [self addSubview:self.faceButton];
  [self addSubview:self.textView];
  [self.textView addSubview:self.voiceRecordButton];
  
  UIImageView *topLine = [[UIImageView alloc] init];
  topLine.backgroundColor = [UIColor colorWithRed:184/255.0f green:184/255.0f blue:184/255.0f alpha:1.0f];
  [self addSubview:topLine];
  
  [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.mas_left);
    make.right.equalTo(self.mas_right);
    make.top.equalTo(self.mas_top);
    make.height.mas_equalTo(@.5f);
  }];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
  
  self.backgroundColor = [UIColor colorWithRed:235/255.0f green:236/255.0f blue:238/255.0f alpha:1.0f];
  [self updateConstraintsIfNeeded];
  
  //FIX 修复首次初始化页面 页面显示不正确 textView不显示bug
  [self layoutIfNeeded];
}


//开始录音
- (void)startRecordVoice{
  [XMProgressHUD show];
  //    [self.MP3 startRecord];
}


//取消录音
- (void)cancelRecordVoice{
  [XMProgressHUD dismissWithMessage:@"取消录音"];
  //    [self.MP3 cancelRecord];
}


// 录音结束
- (void)confirmRecordVoice{
  //    [self.MP3 stopRecord];
}

- (void)updateCancelRecordVoice{
  [XMProgressHUD changeSubTitle:@"松开取消录音"];
}

- (void)updateContinueRecordVoice{
  [XMProgressHUD changeSubTitle:@"向上滑动取消录音"];
}


- (void)showViewWithType:(XDFunctionViewShowType)showType{
  [self showVoiceView:showType == XDFunctionViewShowVoice && self.voiceButton.selected];
  [self showFaceView:showType == XDFunctionViewShowFace && self.faceButton.selected];
  
  switch (showType) {
    case XDFunctionViewShowNothing:
    case XDFunctionViewShowVoice:
    {
      self.inputText = self.textView.text;
      self.textView.text = nil;
      [self setFrame:CGRectMake(0, self.superViewHeight - kMinHeight, self.frame.size.width, kMinHeight) animated:NO];
      [self.textView resignFirstResponder];
    }
      break;
    case XDFunctionViewShowMore:
    case XDFunctionViewShowFace:
      self.inputText = self.textView.text;
      [self setFrame:CGRectMake(0, self.superViewHeight - kFunctionViewHeight - self.textView.frame.size.height - 10, self.frame.size.width, self.textView.frame.size.height + 10) animated:NO];
      [self.textView resignFirstResponder];
      [self textViewDidChange:self.textView];
      break;
    case XDFunctionViewShowKeyboard:
      self.textView.text = self.inputText;
      [self textViewDidChange:self.textView];
      self.inputText = nil;
      break;
    default:
      break;
  }
  
}

- (void)buttonAction:(UIButton *)button{
  self.inputText = self.textView.text;
  XDFunctionViewShowType showType = button.tag;
  
  //更改对应按钮的状态
  if (button == self.faceButton) {
    [self.faceButton setSelected:!self.faceButton.selected];
    [self.voiceButton setSelected:NO];
  }else if (button == self.voiceButton){
    [self.faceButton setSelected:NO];
    [self.voiceButton setSelected:!self.voiceButton.selected];
  }
  
  if (!button.selected) {
    showType = XDFunctionViewShowKeyboard;
    [self.textView becomeFirstResponder];
  }else{
    self.inputText = self.textView.text;
  }
  
  [self showViewWithType:showType];
}

- (void)showFaceView:(BOOL)show{
  if (show) {
    
    [self.superview addSubview:self.faceView];
    [UIView animateWithDuration:.3 animations:^{
      [self.faceView setFrame:CGRectMake(0, self.superViewHeight - kFunctionViewHeight, self.frame.size.width, kFunctionViewHeight)];
    } completion:nil];
  }else{
    [UIView animateWithDuration:.3 animations:^{
      [self.faceView setFrame:CGRectMake(0, self.superViewHeight, self.frame.size.width, kFunctionViewHeight)];
    } completion:^(BOOL finished) {
      [self.faceView removeFromSuperview];
    }];
  }
}

- (void)showVoiceView:(BOOL)show{
  self.voiceButton.selected = show;
  self.voiceRecordButton.selected = show;
  self.voiceRecordButton.hidden = !show;
}


- (void)sendTextMessage:(NSString *)text{
  if (!text || text.length == 0) {
    return;
  }
  if (self.delegate && [self.delegate respondsToSelector:@selector(toolBar:sendMessage:)]) {
    [self.delegate toolBar:self sendMessage:text];
  }
  self.inputText = @"";
  self.textView.text = @"";
  [self showViewWithType:XDFunctionViewShowNothing];
}

- (void)sendVoiceMessage:(NSString *)voiceFileName seconds:(NSTimeInterval)seconds{
  if (self.delegate && [self.delegate respondsToSelector:@selector(toolBar:sendVoice:seconds:)]) {
    [self.delegate toolBar:self sendVoice:voiceFileName seconds:seconds];
  }
}

#pragma mark - Getters

- (UIView *)faceView
{
  if (_faceView == nil) {
    _faceView = [[EaseFaceView alloc] initWithFrame:CGRectMake(0, self.superViewHeight , self.frame.size.width, kFunctionViewHeight)];
    [_faceView setDelegate:self];
    _faceView.backgroundColor = [UIColor colorWithRed:240 / 255.0 green:242 / 255.0 blue:247 / 255.0 alpha:1.0];
    _faceView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self setupEmotion];
  }
  return _faceView;
}


- (void)setupEmotion
{
  NSMutableArray *emotions = [NSMutableArray array];
  for (NSString *name in [EaseEmoji allEmoji]) {
    EaseEmotion *emotion = [[EaseEmotion alloc] initWithName:@"" emotionId:name emotionThumbnail:name emotionOriginal:name emotionOriginalURL:@"" emotionType:EMEmotionDefault];
    [emotions addObject:emotion];
  }
  EaseEmotion *emotion = [emotions objectAtIndex:0];
  EaseEmotionManager *manager= [[EaseEmotionManager alloc] initWithType:EMEmotionDefault emotionRow:3 emotionCol:7 emotions:emotions tagImage:[UIImage imageNamed:emotion.emotionId]];
  [_faceView setEmotionManagers:@[manager]];
}


#pragma mark - FaceDelegate

- (void)selectedFacialView:(NSString *)str isDelete:(BOOL)isDelete
{
  NSString *chatText = self.textView.text;
  
  NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
  
  if (!isDelete && str.length > 0) {
    NSRange range = [self.textView selectedRange];
    [attr insertAttributedString:[[EaseEmotionEscape sharedInstance] attStringFromTextForInputView:str textFont:self.textView.font] atIndex:range.location];
    self.textView.attributedText = attr;
  }
  else {
    if (chatText.length > 0) {
      NSInteger length = 1;
      if (chatText.length >= 2) {
        NSString *subStr = [chatText substringFromIndex:chatText.length-2];
        if ([EaseEmoji stringContainsEmoji:subStr]) {
          length = 2;
        }
      }
      self.textView.attributedText = [self backspaceText:attr length:length];
    }
  }
  [self textViewDidChange:self.textView];
}

-(NSMutableAttributedString*)backspaceText:(NSMutableAttributedString*) attr length:(NSInteger)length
{
  NSRange range = [self.textView selectedRange];
  if (range.location == 0) {
    return attr;
  }
  [attr deleteCharactersInRange:NSMakeRange(range.location - length, length)];
  return attr;
}

- (void)sendFace
{
  NSString *chatText = self.textView.text;
  if (chatText.length > 0) {
    if ([self.delegate respondsToSelector:@selector(toolBar:sendMessage:)]) {
      
      if (![_textView.text isEqualToString:@""]) {
        
        //转义回来
        NSMutableString *attStr = [[NSMutableString alloc] initWithString:self.textView.attributedText.string];
        [_textView.attributedText enumerateAttribute:NSAttachmentAttributeName
                                             inRange:NSMakeRange(0, self.textView.attributedText.length)                                                  options:NSAttributedStringEnumerationReverse
                                          usingBlock:^(id value, NSRange range, BOOL *stop)
         {
           if (value) {
             EMTextAttachment* attachment = (EMTextAttachment*)value;
             NSString *str = [NSString stringWithFormat:@"%@",attachment.imageName];
             [attStr replaceCharactersInRange:range withString:str];
           }
         }];
        [self.delegate toolBar:self sendMessage:attStr];
        self.inputText = @"";
        self.textView.text = @"";
        [self showViewWithType:XDFunctionViewShowNothing];
      }
    }
  }
}

- (UITextView *)textView{
  if (!_textView) {
    _textView = [[UITextView alloc] init];
    _textView.font = [UIFont systemFontOfSize:16.0f];
    _textView.delegate = self;
    _textView.layer.cornerRadius = 4.0f;
    _textView.layer.borderColor = [UIColor colorWithRed:204.0/255.0f green:204.0/255.0f blue:204.0/255.0f alpha:1.0f].CGColor;
    _textView.returnKeyType = UIReturnKeySend;
    _textView.layer.borderWidth = .5f;
    _textView.layer.masksToBounds = YES;
  }
  return _textView;
}

- (UIButton *)voiceButton{
  if (!_voiceButton) {
    _voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _voiceButton.tag = XDFunctionViewShowVoice;
    [_voiceButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_voice_normal"] forState:UIControlStateNormal];
    [_voiceButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_input_normal"] forState:UIControlStateSelected];
    [_voiceButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_voiceButton sizeToFit];
  }
  return _voiceButton;
}

- (UIButton *)voiceRecordButton{
  if (!_voiceRecordButton) {
    _voiceRecordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _voiceRecordButton.hidden = YES;
    _voiceRecordButton.frame = self.textView.bounds;
    _voiceRecordButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_voiceRecordButton setBackgroundColor:[UIColor lightGrayColor]];
    _voiceRecordButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [_voiceRecordButton setTitle:@"按住录音" forState:UIControlStateNormal];
    [_voiceRecordButton addTarget:self action:@selector(startRecordVoice) forControlEvents:UIControlEventTouchDown];
    [_voiceRecordButton addTarget:self action:@selector(cancelRecordVoice) forControlEvents:UIControlEventTouchUpOutside];
    [_voiceRecordButton addTarget:self action:@selector(confirmRecordVoice) forControlEvents:UIControlEventTouchUpInside];
    [_voiceRecordButton addTarget:self action:@selector(updateCancelRecordVoice) forControlEvents:UIControlEventTouchDragExit];
    [_voiceRecordButton addTarget:self action:@selector(updateContinueRecordVoice) forControlEvents:UIControlEventTouchDragEnter];
  }
  return _voiceRecordButton;
}

- (UIButton *)faceButton{
  if (!_faceButton) {
    _faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _faceButton.tag = XDFunctionViewShowFace;
    [_faceButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_face_normal"] forState:UIControlStateNormal];
    [_faceButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_input_normal"] forState:UIControlStateSelected];
    [_faceButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_faceButton sizeToFit];
  }
  return _faceButton;
}

- (CGFloat)bottomHeight{
  
  if (self.faceView.superview) {
    return MAX(self.keyboardFrame.size.height, self.faceView.frame.size.height);
  }else{
    return MAX(self.keyboardFrame.size.height, CGFLOAT_MIN);
  }
  
}

- (UIViewController *)rootViewController{
  return [[UIApplication sharedApplication] keyWindow].rootViewController;
}

#pragma mark - Getters

- (void)setFrame:(CGRect)frame animated:(BOOL)animated{
  if (animated) {
    [UIView animateWithDuration:.3 animations:^{
      [self setFrame:frame];
    }];
  }else{
    [self setFrame:frame];
  }
  if (self.delegate && [self.delegate respondsToSelector:@selector(toolBarFrameDidChange:frame:)]) {
    [self.delegate toolBarFrameDidChange:self frame:frame];
  }
}


@end
