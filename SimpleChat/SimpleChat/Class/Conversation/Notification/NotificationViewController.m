//
//  NotificationViewController.m
//  SimpleChat
//
//  Created by stugeek on 2021/12/2.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import "NotificationViewController.h"

#import "NotificationHelper.h"
#import "NotificationCell.h"

@interface NotificationViewController ()<EMNotificationsDelegate, NotificationCellDelegate>

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.dataArray = [[NSMutableArray alloc] init];

    [self _setupViews];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    EMConversation *conversation = [EMClient.sharedClient.chatManager getConversation:EMSYSTEMNOTIFICATIONID type:EMConversationTypeChat createIfNotExist:YES];
    [EaseIMKitManager.shared markAllMessagesAsReadWithConversation:conversation];
    [[NotificationHelper shared] markAllAsRead];
    [NotificationHelper shared].isCheckUnreadCount = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:CHAT_BACKOFF object:nil];
    [NotificationHelper shared].isCheckUnreadCount = YES;
}

- (void)dealloc
{
    [NotificationHelper shared].isCheckUnreadCount = YES;
}

#pragma mark - Subviews

- (void)_setupViews
{
    [self addPopBackLeftItem];
    self.title = @"系统通知";
    
    self.tableView.backgroundColor = kColor_LightGray;
    self.tableView.estimatedRowHeight = 150;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[NotificationHelper shared].notificationList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EMNotificationModel *model = [[NotificationHelper shared].notificationList objectAtIndex:indexPath.row];
    NSString *cellIdentifier = [NSString stringWithFormat:@"NotificationCell_%@", @(model.status)];
    NotificationCell *cell = (NotificationCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[NotificationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.delegate = self;
    }
    
    cell.model = model;
    
    return cell;
}

#pragma mark - NotificationCellDelegate

- (void)agreeNotification:(EMNotificationModel *)aModel
{
    __weak typeof(self) weakself = self;
    void (^block) (EMError *aError) = ^(EMError *aError) {
        if (!aError) {
            aModel.status = EMNotificationModelStatusAgreed;
            [[NotificationHelper shared] archive];
            
            [weakself.tableView reloadData];
        }
    };
    
    if (aModel.type == EMNotificationModelTypeContact) {
        [[EMClient sharedClient].contactManager approveFriendRequestFromUser:aModel.sender completion:^(NSString *aUsername, EMError *aError) {
            if (!aError) {
                NSString *msg = [NSString stringWithFormat:@"您已同意 %@ 的好友请求",aModel.sender];
                [self showAlertWithTitle:@"O(∩_∩)O" message:msg];
            }
            block(aError);
        }];
    } else if (aModel.type == EMNotificationModelTypeGroupInvite) {
        [[EMClient sharedClient].groupManager acceptInvitationFromGroup:aModel.groupId inviter:aModel.sender completion:^(EMGroup *aGroup, EMError *aError) {
            block(aError);
            if (!aError) {
                NSString *msg = [NSString stringWithFormat:@"您已加入群 「%@」",aGroup.groupName];
                [self showAlertWithTitle:@"O(∩_∩)O" message:msg];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_ADD_SOCIAL_CONTACT object:@{CONVERSATION_ID:aModel.groupId,CONVERSATION_OBJECT:EMClient.sharedClient.currentUsername}];
            }
        }];
    } else if (aModel.type == EMNotificationModelTypeGroupJoin) {
        [[EMClient sharedClient].groupManager approveJoinGroupRequest:aModel.groupId sender:aModel.sender completion:^(EMGroup *aGroup, EMError *aError) {
            block(aError);
        }];
    }
}

- (void)declineNotification:(EMNotificationModel *)aModel
{
    __weak typeof(self) weakself = self;
    void (^block) (EMError *aError) = ^(EMError *aError) {
        if (!aError) {
            aModel.status = EMNotificationModelStatusDeclined;
        } else {
            if (aError.code == EMErrorGroupInvalidId) {
                aModel.status = EMNotificationModelStatusExpired;
            }
        }
        
        [[NotificationHelper shared] archive];
        [weakself.tableView reloadData];
    };
    
    if (aModel.type == EMNotificationModelTypeContact) {
        [[EMClient sharedClient].contactManager declineFriendRequestFromUser:aModel.sender completion:^(NSString *aUsername, EMError *aError) {
            if (!aError) {
                NSString *msg = [NSString stringWithFormat:@"您已拒绝 %@ 的好友请求",aModel.sender];
                [self showAlertWithTitle:@"O(∩_∩)O" message:msg];
            }
            block(aError);
        }];
    } else if (aModel.type == EMNotificationModelTypeGroupInvite) {
        [[EMClient sharedClient].groupManager declineGroupInvitation:aModel.groupId inviter:aModel.sender reason:nil completion:^(EMError *aError) {
            block(aError);

        }];
    } else if (aModel.type == EMNotificationModelTypeGroupJoin) {
        [[EMClient sharedClient].groupManager declineJoinGroupRequest:aModel.groupId sender:aModel.sender reason:nil completion:^(EMGroup *aGroup, EMError *aError) {
            block(aError);
           
        }];
    }
}

@end
