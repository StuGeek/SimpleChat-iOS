//
//  RemindManager.m
//  SimpleChat
//
//  Created by qtdmz on 2019/8/21.
//  Copyright © 2019 qtdmz. All rights reserved.
//

#import "RemindManager.h"

@interface RemindManager ()

@end

@implementation RemindManager
+ (void)remindMessage:(EMMessage *)aMessage {
    [[RemindManager shared] remindMessage:aMessage];
}

+ (void)updateApplicationIconBadgeNumber:(NSInteger)aBadgeNumber {
    [[RemindManager shared] updateApplicationIconBadgeNumber:aBadgeNumber];
}

#pragma - mark private
+ (RemindManager *)shared {
    static RemindManager *remindManager_;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        remindManager_ = [[RemindManager alloc] init];
    });
    
    return remindManager_;
}

- (void)updateApplicationIconBadgeNumber:(NSInteger)aBadgeNumber {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:aBadgeNumber];
    });
}

- (void)remindMessage:(EMMessage *)aMessage {
    if ([aMessage.from isEqualToString:EMClient.sharedClient.currentUsername]) {
        return;
    }
    Options *options = [Options sharedOptions];
    if (!options.isReceiveNewMsgNotice)
        return;;
    
    // 是否是群免打扰的消息
    if (aMessage.chatType != EMChatTypeChat) {
        if (![self _needRemind:aMessage.conversationId]) {
            return;
        }
    }
    
    BOOL isBackground = NO;
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateBackground) {
        isBackground = YES;
    }
    
    // App 是否在后台
    if (isBackground) {
        [self _localNotification:aMessage
                        needInfo:EMClient.sharedClient.pushOptions.displayStyle != EMPushDisplayStyleSimpleBanner];
    }
}

// 本地通知 needInfo: 是否显示通知详情
- (void)_localNotification:(EMMessage *)message
                  needInfo:(BOOL)isNeed {
    NSString *alertBody = nil;
    if (isNeed) {
        EMMessageBody *messageBody = message.body;
        NSString *messageStr = nil;
        switch (messageBody.type) {
            case EMMessageBodyTypeText:
            {
                messageStr = ((EMTextMessageBody *)messageBody).text;
            }
                break;
            case EMMessageBodyTypeImage:
            {
                messageStr = @"图片";
            }
                break;
            case EMMessageBodyTypeLocation:
            {
                messageStr = @"位置";
            }
                break;
            case EMMessageBodyTypeVoice:
            {
                messageStr = @"音频";
            }
                break;
            case EMMessageBodyTypeVideo:{
                messageStr = @"视频";
            }
                break;
            case EMMessageBodyTypeFile:{
                messageStr = @"文件";
            }
                break;
            default:
                break;
        }
        
        if (message.chatType == EMChatTypeChat) {
            alertBody = [NSString stringWithFormat:@"%@:%@", message.from, messageStr];
        }else {
            alertBody = [NSString stringWithFormat:@"%@(%@):%@", message.conversationId, message.from, messageStr];
        }
    }
    else{
        alertBody = @"您有一条新消息";
    }

    //发送本地推送
    if (NSClassFromString(@"UNUserNotificationCenter")) {
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.01 repeats:NO];
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.body = alertBody;
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:message.messageId content:content trigger:trigger];
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];
    }
    else {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.fireDate = [NSDate date]; //触发通知的时间
        notification.alertBody = alertBody;
        notification.alertAction = @"打开";
        notification.timeZone = [NSTimeZone defaultTimeZone];
        
        //发送通知
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

- (BOOL)_needRemind:(NSString *)fromChatter
{
    BOOL ret = NO;
    do {
        NSArray *igGroupIds = [[EMClient sharedClient].groupManager getGroupsWithoutPushNotification:nil];
        for (NSString *str in igGroupIds) {
            if ([str isEqualToString:fromChatter]) {
                return NO;
            }
        }
        ret = YES;
    } while (0);
    return ret;
}

@end
