//
//  ConferenceController.h
//  SimpleChat
//
//  Created by stugeek on 2021/12/1.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ConfInviteUsersViewController.h"

@class EMConferenceViewController;
@interface ConferenceController : NSObject

+ (instancetype)sharedManager;

//开始一场会议（群组/聊天室）
- (void)communicateConference:(EMConversation *)conversation rootController:(UIViewController *)controller;

@end

