//
//  XDToolBar.h
//  XDKeyBoard
//
//  Created by changjianhong on 16/3/1.
//  Copyright © 2016年 changjianhong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, XDFunctionViewShowType){
  XDFunctionViewShowNothing /**< 不显示functionView */,
  XDFunctionViewShowFace /**< 显示表情View */,
  XDFunctionViewShowVoice /**< 显示录音view */,
  XDFunctionViewShowMore /**< 显示更多view */,
  XDFunctionViewShowKeyboard /**< 显示键盘 */,
};

@protocol XDToolBarDelegate;

@interface XDToolBar : UIView

@property (assign, nonatomic) CGFloat superViewHeight;

@property (weak, nonatomic) id<XDToolBarDelegate> delegate;

/**
 *  结束输入状态
 */
- (void)endInputing;

@end

/**
 *  XMChatBar代理事件,发送图片,地理位置,文字,语音信息等
 */
@protocol XDToolBarDelegate <NSObject>

@optional

/**
 *  chatBarFrame改变回调
 *
 *  @param chatBar
 */
- (void)toolBarFrameDidChange:(XDToolBar *)toolBar frame:(CGRect)frame;

/**
 *  发送普通的文字信息,可能带有表情
 *
 *  @param chatBar
 *  @param message 需要发送的文字信息
 */
- (void)toolBar:(XDToolBar *)toolBar sendMessage:(NSString *)message;

/**
 *  发送语音信息
 *
 *  @param chatBar
 *  @param voiceData 语音data数据
 *  @param seconds   语音时长
 */
- (void)toolBar:(XDToolBar *)toolBar sendVoice:(NSString *)voiceFileName seconds:(NSTimeInterval)seconds;

@end
