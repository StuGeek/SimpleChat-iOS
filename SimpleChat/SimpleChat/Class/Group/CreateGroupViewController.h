//
//  CreateGroupViewController.h
//  SimpleChat
//
//  Created by stugeek on 2021/12/3.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class InviteGroupMemberViewController;
@interface CreateGroupViewController : UITableViewController

@property (nonatomic, copy) void (^successCompletion)(EMGroup *aGroup);

@property (nonatomic, strong) InviteGroupMemberViewController *inviteController;

- (instancetype)initWithSelectedMembers:(NSArray *)aMembers;

@end

NS_ASSUME_NONNULL_END
