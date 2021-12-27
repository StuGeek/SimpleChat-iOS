//
//  SimpleChatHelper.h
//  SimpleChat
//
//  Created by stugeek on 2021/12/1.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import "SimpleChatHelper.h"

#import "GlobalVariables.h"

#import "ChatViewController.h"
#import "GroupsViewController.h"
#import "GroupInfoViewController.h"
#import "RemindManager.h"
#import "EMAlertController.h"

static SimpleChatHelper *helper = nil;


@implementation SimpleChatHelper

+ (instancetype)shareHelper
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[SimpleChatHelper alloc] init];
    });
    return helper;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self _initHelper];
    }
    return self;
}

- (void)dealloc
{
    [[EMClient sharedClient] removeDelegate:self];
    [[EMClient sharedClient].groupManager removeDelegate:self];
    [[EMClient sharedClient].contactManager removeDelegate:self];
    [[EMClient sharedClient].chatManager removeDelegate:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - init

- (void)_initHelper
{
    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].contactManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePushChatController:) name:CHAT_PUSHVIEWCONTROLLER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePushGroupsController:) name:GROUP_LIST_PUSHVIEWCONTROLLER object:nil];
}

#pragma mark - EMChatManagerDelegate

- (void)messagesDidReceive:(NSArray *)aMessages
{
    for (EMMessage *msg in aMessages) {
        if (msg.body.type == EMMessageBodyTypeText && [((EMTextMessageBody *)msg.body).text isEqualToString:EMCOMMUNICATE_CALLINVITE]) //通话邀请
            continue;
        [RemindManager remindMessage:msg];
    }
}

#pragma mark - EMGroupManagerDelegate

- (void)didJoinGroup:(EMGroup *)aGroup inviter:(NSString *)aInviter message:(NSString *)aMessage
{
    NSString *message = [NSString stringWithFormat:@"您已加入群 %@",[NSString stringWithFormat:@"「%@」",aGroup.groupName]];
    EMAlertView *alertView = [[EMAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:message];
    [alertView show];
}

- (void)didJoinedGroup:(EMGroup *)aGroup
               inviter:(NSString *)aInviter
               message:(NSString *)aMessage
{
    EMAlertView *alertView = [[EMAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:[NSString stringWithFormat:NSLocalizedString(@"group.somebodyInvite", nil), aInviter, [NSString stringWithFormat:@"「%@」",aGroup.groupName]]];
    [alertView show];
}

- (void)groupInvitationDidDecline:(EMGroup *)aGroup
                          invitee:(NSString *)aInvitee
                           reason:(NSString *)aReason
{
    NSString *message = [NSString stringWithFormat:@"%@ 已拒绝了您的加群「%@」邀请", aInvitee, aGroup.groupName];
    EMAlertView *alertView = [[EMAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:message];
    [alertView show];
}

- (void)groupInvitationDidAccept:(EMGroup *)aGroup
                         invitee:(NSString *)aInvitee
{
    NSString *message = [NSString stringWithFormat:@"您在群「%@」的加群邀请已经被 %@ 同意", aGroup.groupName, aInvitee];
    EMAlertView *alertView = [[EMAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:message];
    [alertView show];
}

- (void)joinGroupRequestDidDecline:(NSString *)aGroupId reason:(NSString *)aReason
{
    if (!aReason || aReason.length == 0) {
        aReason = [NSString stringWithFormat:NSLocalizedString(@"group.beRefusedToJoin", @"be refused to join the group\'%@\'"), aGroupId];
    }
    EMAlertView *alertView = [[EMAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:aReason];
    [alertView show];
}

- (void)joinGroupRequestDidApprove:(EMGroup *)aGroup
{
    NSString *message = [NSString stringWithFormat:@"群主同意您加入群 %@",[NSString stringWithFormat:@"「%@」",aGroup.groupName]];
    EMAlertView *alertView = [[EMAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:message];
    [alertView show];
}

- (void)groupMuteListDidUpdate:(EMGroup *)aGroup
             addedMutedMembers:(NSArray *)aMutedMembers
                    muteExpire:(NSInteger)aMuteExpire
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateGroupDetail" object:aGroup];
    NSString *message = NSLocalizedString(@"group.toMute", @"Mute");
    if ([aMutedMembers containsObject:EMClient.sharedClient.currentUsername])
        message = [NSString stringWithFormat:@"您在群 %@ 已被禁言",[NSString stringWithFormat:@"「%@」",aGroup.groupName]];
    EMAlertView *alertView = [[EMAlertView alloc]initWithTitle:NSLocalizedString(@"group.update", @"Group update") message:message];
    [alertView show];
}

- (void)groupMuteListDidUpdate:(EMGroup *)aGroup
           removedMutedMembers:(NSArray *)aMutedMembers
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateGroupDetail" object:aGroup];
    NSString *message = NSLocalizedString(@"group.toMute", @"Mute");
    if ([aMutedMembers containsObject:EMClient.sharedClient.currentUsername])
        message = [NSString stringWithFormat:@"您在群 %@ 恢复发言",[NSString stringWithFormat:@"「%@」",aGroup.groupName]];
    EMAlertView *alertView = [[EMAlertView alloc]initWithTitle:NSLocalizedString(@"group.update", @"Group update") message:message];
    [alertView show];
}

- (void)groupAllMemberMuteChanged:(EMGroup *)aGroup isAllMemberMuted:(BOOL)aMuted
{
    NSString * message = [NSString stringWithFormat:@"您所在在群 %@ 群主已%@全员禁言",[NSString stringWithFormat:@"「%@」",aGroup.groupName],aMuted ? @"开启" : @"关闭"];
    EMAlertView *alertView = [[EMAlertView alloc]initWithTitle:NSLocalizedString(@"group.update", @"Group update") message:message];
    [alertView show];
}

- (void)groupWhiteListDidUpdate:(EMGroup *)aGroup addedWhiteListMembers:(NSArray *)aMembers
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateGroupDetail" object:aGroup];
    if ([aMembers containsObject:EMClient.sharedClient.currentUsername]) {
        NSString * message = [NSString stringWithFormat:@"您在群 %@ 被添加进白名单",[NSString stringWithFormat:@"「%@」",aGroup.groupName]];
        EMAlertView *alertView = [[EMAlertView alloc]initWithTitle:NSLocalizedString(@"group.update", @"Group update") message:message];
        [alertView show];
    }
}

- (void)groupWhiteListDidUpdate:(EMGroup *)aGroup removedWhiteListMembers:(NSArray *)aMembers
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateGroupDetail" object:aGroup];
    if ([aMembers containsObject:EMClient.sharedClient.currentUsername]) {
        NSString * message = [NSString stringWithFormat:@"您在群 %@ 被移出进白名单",[NSString stringWithFormat:@"「%@」",aGroup.groupName]];
        EMAlertView *alertView = [[EMAlertView alloc]initWithTitle:NSLocalizedString(@"group.update", @"Group update") message:message];
        [alertView show];
    }
}

- (void)groupAdminListDidUpdate:(EMGroup *)aGroup
                     addedAdmin:(NSString *)aAdmin
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateGroupDetail" object:aGroup];
    
    NSString *msg = [NSString stringWithFormat:@"%@ 在群 %@ 已被群主指定为管理员", aAdmin, [NSString stringWithFormat:@"「%@」",aGroup.groupName]];
    EMAlertView *alertView = [[EMAlertView alloc]initWithTitle:NSLocalizedString(@"group.adminUpdate", @"Group Admin Update") message:msg];
    [alertView show];
    [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_INFO_REFRESH object:nil];
}

- (void)groupAdminListDidUpdate:(EMGroup *)aGroup
                   removedAdmin:(NSString *)aAdmin
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateGroupDetail" object:aGroup];
    
    NSString *msg = [NSString stringWithFormat:@"%@ 在群 %@ 已被群主取消管理员权限", aAdmin, [NSString stringWithFormat:@"「%@」",aGroup.groupName]];
    EMAlertView *alertView = [[EMAlertView alloc]initWithTitle:NSLocalizedString(@"group.adminUpdate", @"Group Admin Update") message:msg];
    [alertView show];
    [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_INFO_REFRESH object:nil];
}

- (void)groupOwnerDidUpdate:(EMGroup *)aGroup
                   newOwner:(NSString *)aNewOwner
                   oldOwner:(NSString *)aOldOwner
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateGroupDetail" object:aGroup];

    NSString *msg = [NSString stringWithFormat:@"%@ 在群 %@ 已将群主移交给 %@", aOldOwner, [NSString stringWithFormat:@"「%@」",aGroup.groupName], aNewOwner];
    EMAlertView *alertView = [[EMAlertView alloc]initWithTitle:NSLocalizedString(@"group.ownerUpdate", @"Group Owner Update") message:msg];
    [alertView show];
    [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_INFO_REFRESH object:aGroup];
}

- (void)userDidJoinGroup:(EMGroup *)aGroup
                    user:(NSString *)aUsername
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateGroupDetail" object:aGroup];
    
    NSString *msg = [NSString stringWithFormat:@"%@ %@ %@", aUsername, NSLocalizedString(@"group.join", @"Join the group"), [NSString stringWithFormat:@"「%@」",aGroup.groupName]];
    EMAlertView *alertView = [[EMAlertView alloc]initWithTitle:NSLocalizedString(@"group.membersUpdate", @"Group Members Update") message:msg];
    [alertView show];
}

- (void)userDidLeaveGroup:(EMGroup *)aGroup
                     user:(NSString *)aUsername
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateGroupDetail" object:aGroup];
    
    NSString *msg = [NSString stringWithFormat:@"%@ %@ %@", aUsername, NSLocalizedString(@"group.leave", @"Leave group"), [NSString stringWithFormat:@"「%@」",aGroup.groupName]];
    EMAlertView *alertView = [[EMAlertView alloc]initWithTitle:NSLocalizedString(@"group.membersUpdate", @"Group Members Update") message:msg];
    [alertView show];
}

- (void)didLeaveGroup:(EMGroup *)aGroup reason:(EMGroupLeaveReason)aReason
{
    EMAlertView *alertView = nil;
    if (aReason == EMGroupLeaveReasonBeRemoved) {
        alertView = [[EMAlertView alloc]initWithTitle:NSLocalizedString(@"group.leave", @"Leave group") message:[NSString stringWithFormat:@"您已被群管理员移出群组: %@", aGroup.groupName]];
        [EMClient.sharedClient.chatManager deleteConversation:aGroup.groupId isDeleteMessages:NO completion:nil];
    }
    if (aReason == EMGroupLeaveReasonDestroyed) {
        alertView = [[EMAlertView alloc]initWithTitle:NSLocalizedString(@"group.leave", @"Leave group") message:[NSString stringWithFormat:@"群组 %@ 已解散", aGroup.groupName]];
        [EMClient.sharedClient.chatManager deleteConversation:aGroup.groupId isDeleteMessages:YES completion:nil];
    }
    [alertView show];
}

- (void)groupAnnouncementDidUpdate:(EMGroup *)aGroup
                      announcement:(NSString *)aAnnouncement
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateGroupDetail" object:aGroup];
    
    NSString *msg = [NSString stringWithFormat:@"群组「%@」 公告内容已更新，请查看",aGroup.groupName];
    EMAlertView *alertView = [[EMAlertView alloc]initWithTitle:NSLocalizedString(@"group.announcementUpdate", @"Group Announcement Update") message:msg];
    [alertView show];
}

- (void)groupFileListDidUpdate:(EMGroup *)aGroup
               addedSharedFile:(EMGroupSharedFile *)aSharedFile
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateGroupSharedFile" object:aGroup];
    
    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"group.uploadSharedFile", @"Group:%@ Upload file ID: %@"), [NSString stringWithFormat:@"「%@」",aGroup.groupName], aSharedFile.fileId];
    EMAlertView *alertView = [[EMAlertView alloc]initWithTitle:NSLocalizedString(@"group.sharedFileUpdate", @"Group SharedFile Update") message:msg];
    [alertView show];
}

- (void)groupFileListDidUpdate:(EMGroup *)aGroup
             removedSharedFile:(NSString *)aFileId
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateGroupSharedFile" object:aGroup];
    
    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"group.removeSharedFile", @"Group:%@ Remove file ID: %@"), [NSString stringWithFormat:@"「%@」",aGroup.groupName], aFileId];
    EMAlertView *alertView = [[EMAlertView alloc]initWithTitle:NSLocalizedString(@"group.sharedFileUpdate", @"Group SharedFile Update") message:msg];
    [alertView show];
}

#pragma mark - EMContactManagerDelegate

- (void)friendRequestDidApproveByUser:(NSString *)aUsername
{
    NSString *msg = [NSString stringWithFormat:@"'%@'同意了您的好友请求", aUsername];
    [self showAlertWithTitle:@"O(∩_∩)O" message:msg];
}

- (void)friendRequestDidDeclineByUser:(NSString *)aUsername
{
    NSString *msg = [NSString stringWithFormat:@"'%@'拒绝了您的好友请求", aUsername];
    [self showAlertWithTitle:@"O(∩_∩)O" message:msg];
}

#pragma mark - private

- (BOOL)_needShowNotification:(NSString *)fromChatter
{
    BOOL ret = YES;
    NSArray *igGroupIds = [[EMClient sharedClient].groupManager getGroupsWithoutPushNotification:nil];
    for (NSString *str in igGroupIds) {
        if ([str isEqualToString:fromChatter]) {
            ret = NO;
            break;
        }
    }
    return ret;
}

#pragma mark - NSNotification

- (void)handlePushChatController:(NSNotification *)aNotif
{
    id object = aNotif.object;
    EMConversationType type = -1;
    NSString *conversationId = nil;
    if ([object isKindOfClass:[NSString class]]) {
        conversationId = (NSString *)object;
        type = EMConversationTypeChat;
    } else if ([object isKindOfClass:[EMGroup class]]) {
        EMGroup *group = (EMGroup *)object;
        conversationId = group.groupId;
        type = EMConversationTypeGroupChat;
    } else if ([object isKindOfClass:[EaseConversationModel class]]) {
        EaseConversationModel *model = (EaseConversationModel *)object;
        conversationId = model.easeId;
        type = model.type;
    }
    ChatViewController *controller = [[ChatViewController alloc]initWithConversationId:conversationId conversationType:type];
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIViewController *rootViewController = window.rootViewController;
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)rootViewController;
        [nav pushViewController:controller animated:YES];
    }
}

- (void)handlePushGroupsController:(NSNotification *)aNotif
{
    NSDictionary *dic = aNotif.object;
    UINavigationController *navController = [dic objectForKey:NOTIF_NAVICONTROLLER];
    if (navController == nil) {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        navController = (UINavigationController *)window.rootViewController;
    }
    
    GroupsViewController *controller = [[GroupsViewController alloc] init];
    [navController pushViewController:controller animated:YES];
}

@end
