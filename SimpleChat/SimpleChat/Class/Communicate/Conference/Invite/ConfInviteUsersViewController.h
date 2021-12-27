//
//  ConfInviteUsersViewController.h
//  SimpleChat
//
//  Created by stugeek on 2021/12/1.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import "EMRefreshViewController.h"

typedef enum {
    ConfInviteTypeUser = 0,
    ConfInviteTypeGroup
} ConfInviteType;

@interface ConfInviteUsersViewController : EMRefreshViewController

@property (copy) void (^doneCompletion)(NSArray *aInviteUsers);

- (instancetype)initWithType:(ConfInviteType)aType
                    isCreate:(BOOL)aIsCreate
                excludeUsers:(NSArray *)aExcludeUsers
           groupOrChatroomId:(NSString *)aGorcId;

@end
