//
//  ChatViewController.h
//  SimpleChat
//
//  Created by stugeek on 2021/12/2.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatViewController : UIViewController
@property (nonatomic, strong) EMConversation *conversation;
@property (nonatomic, strong) EaseChatViewController *chatController;

- (instancetype)initWithConversationId:(NSString *)conversationId conversationType:(EMConversationType)conType;
//本地通话记录
- (void)insertLocationCallRecord:(NSNotification*)noti;

- (NSArray *)formatMessages:(NSArray<EMMessage *> *)aMessages;

@end

NS_ASSUME_NONNULL_END
