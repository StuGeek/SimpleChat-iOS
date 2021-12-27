//
//  SimpleChatHelper.h
//  SimpleChat
//
//  Created by stugeek on 2021/12/1.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SimpleChatHelper : NSObject<EMContactManagerDelegate, EMGroupManagerDelegate, EMChatManagerDelegate>

+ (instancetype)shareHelper;

@end
