//
//  ConversationUserDataModel.m
//  SimpleChat
//
//  Created by stugeek on 2021/12/2.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import "ConversationUserDataModel.h"

@implementation ConversationUserDataModel

- (instancetype)initWithEaseId:(NSString*)easeId conversationType:(EMConversationType)type
{
    if (self = [super init]) {
        _easeId = easeId;
        _showName = easeId;
        if (type == EMConversationTypeChat) {
            if ([easeId isEqualToString:EMSYSTEMNOTIFICATIONID]) {
                _showName = @"系统通知";
            }
        }
        if(type == EMConversationTypeGroupChat) {
            EMGroup* group = [EMGroup groupWithId:easeId];
            _showName = [group groupName];
        }
        _defaultAvatar = [self _getDefaultAvatarImage:easeId conversationType:type];
    }
    return self;
}

- (UIImage*)_getDefaultAvatarImage:(NSString*)easeId conversationType:(EMConversationType)type
{
    if (type == EMConversationTypeChat) {
        if ([easeId isEqualToString:EMSYSTEMNOTIFICATIONID]) {
            return [UIImage imageNamed:@"systemNotify"];
        }
        return [UIImage imageNamed:@"defaultAvatar"];
    }
    if (type == EMConversationTypeGroupChat) {
        return [UIImage imageNamed:@"groupConversation"];
    }
    return [UIImage imageNamed:@"defaultAvatar"];
}

@end
