//
//  GroupMembersViewController.m
//  SimpleChat
//
//  Created by stugeek on 2021/12/3.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import "GroupMembersViewController.h"
#import "EMAvatarNameCell+UserInfo.h"
#import "PersonalDataViewController.h"
#import "UserInfoStore.h"
#import "AccountViewController.h"

@interface GroupMembersViewController ()

@property (nonatomic, strong) EMGroup *group;
@property (nonatomic, strong) NSString *cursor;
@property (nonatomic, strong) NSMutableArray *mutesList;
@property (nonatomic) BOOL isUpdated;

@end

@implementation GroupMembersViewController

- (instancetype)initWithGroup:(EMGroup *)aGroup
{
    self = [super init];
    if (self) {
        self.group = aGroup;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.cursor = nil;
    self.isUpdated = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView) name:USERINFO_UPDATE object:nil];
    
    [self initView];
    [self _fetchGroupMembersWithIsHeader:YES isShowHUD:YES];
    self.mutesList = [[NSMutableArray alloc]init];
    [self _fetchGroupMutes:1];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Subviews

- (void)initView
{
    [self addPopBackLeftItemWithTarget:self action:@selector(backAction)];
    self.title = @"群组普通成员";
    self.showRefreshHeader = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.rowHeight = 60;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EMAvatarNameCell *cell = (EMAvatarNameCell *)[tableView dequeueReusableCellWithIdentifier:@"EMAvatarNameCell"];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[EMAvatarNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EMAvatarNameCell"];
    }
    cell.avatarView.image = [UIImage imageNamed:@"defaultAvatar"];
    cell.nameLabel.text = [self.dataArray objectAtIndex:indexPath.row];
    [cell refreshUserInfo:[self.dataArray objectAtIndex:indexPath.row]];
    
    
    cell.indexPath = indexPath;
    
    if (self.group.permissionType == EMGroupPermissionTypeOwner || self.group.permissionType == EMGroupPermissionTypeAdmin) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self personalData:[self.dataArray objectAtIndex:indexPath.row]];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return (self.group.permissionType == EMGroupPermissionTypeOwner || self.group.permissionType == EMGroupPermissionTypeAdmin) ? YES : NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //这样写才能实现既能禁止滑动删除Cell，又允许在编辑状态下进行删除
    if (!tableView.editing)
        return UITableViewCellEditingStyleNone;
    else {
        return UITableViewCellEditingStyleDelete;
    }
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *userName = [self.dataArray objectAtIndex:indexPath.row];
    
    __weak typeof(self) weakself = self;
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"移除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [weakself _deleteMember:userName];
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    
    UITableViewRowAction *blackAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"拉黑" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [weakself _blockMember:userName];
    }];
    blackAction.backgroundColor = [UIColor colorWithRed: 50 / 255.0 green: 63 / 255.0 blue: 72 / 255.0 alpha:1.0];
    
    UITableViewRowAction *muteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:[weakself.mutesList containsObject:userName] ? @"取消禁言" : @"禁言" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        if ([weakself.mutesList containsObject:userName]) {
            [weakself _unMuteMemeber:userName];
        } else {
            [weakself _muteMember:userName];
        }
    }];
    muteAction.backgroundColor = [UIColor colorWithRed: 116 / 255.0 green: 134 / 255.0 blue: 147 / 255.0 alpha:1.0];
    if (self.group.permissionType == EMGroupPermissionTypeOwner) {
        UITableViewRowAction *adminAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"升权" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            [weakself _memberToAdmin:userName];
        }];
        adminAction.backgroundColor = [UIColor blackColor];
        
        return @[deleteAction, blackAction, muteAction, adminAction];
    }
    
    return @[deleteAction, blackAction, muteAction];
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos)
{
    NSString *userName = [self.dataArray objectAtIndex:indexPath.row];
    NSMutableArray *swipeActions = [[NSMutableArray alloc] init];
    __weak typeof(self) weakself = self;
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive
                                                                               title:@"移除"
                                                                             handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL))
                                        {
        [weakself _deleteMember:userName];
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    
    UIContextualAction *blackAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
                                                                               title:@"拉黑"
                                                                             handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL))
                                        {
        [weakself _blockMember:userName];
    }];
    blackAction.backgroundColor = [UIColor colorWithRed: 50 / 255.0 green: 63 / 255.0 blue: 72 / 255.0 alpha:1.0];
    
    UIContextualAction *muteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
                                                                             title:[weakself.mutesList containsObject:userName] ? @"取消禁言" : @"禁言"
                                                                             handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL))
                                        {
        if ([weakself.mutesList containsObject:userName]) {
            [weakself _unMuteMemeber:userName];
        } else {
            [weakself _muteMember:userName];
        }
    }];
    muteAction.backgroundColor = [UIColor colorWithRed: 116 / 255.0 green: 134 / 255.0 blue: 147 / 255.0 alpha:1.0];
    
    [swipeActions addObject:deleteAction];
    [swipeActions addObject:blackAction];
    [swipeActions addObject:muteAction];
    
    if (self.group.permissionType == EMGroupPermissionTypeOwner) {
        UIContextualAction *adminAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
                                                                                   title:@"升权"
                                                                                 handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL))
                                            {
            [weakself _memberToAdmin:userName];
        }];
        adminAction.backgroundColor = [UIColor blackColor];
        [swipeActions addObject:adminAction];
    }
    UISwipeActionsConfiguration *actions = [UISwipeActionsConfiguration configurationWithActions:swipeActions];
    actions.performsFirstActionWithFullSwipe = NO;
    return actions;
}

#pragma mark - Data

- (void)_fetchGroupMembersWithIsHeader:(BOOL)aIsHeader
                             isShowHUD:(BOOL)aIsShowHUD
{
    if (aIsShowHUD) {
        [self showHudInView:self.view hint:@"获取群组普通成员..."];
    }
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].groupManager getGroupMemberListFromServerWithId:self.group.groupId cursor:self.cursor pageSize:50 completion:^(EMCursorResult *aResult, EMError *aError) {
        if (aIsShowHUD) {
            [weakself hideHud];
        }
        
        if (aError) {
            [EMAlertController showErrorAlert:aError.errorDescription];
        } else {
            if (aIsHeader) {
                [weakself.dataArray removeAllObjects];
            }
            
            weakself.cursor = aResult.cursor;
            [weakself.dataArray addObjectsFromArray:aResult.list];
            
            if ([aResult.list count] == 0 || [aResult.cursor length] == 0) {
                weakself.showRefreshFooter = NO;
            } else {
                weakself.showRefreshFooter = YES;
            }
            
            [weakself.tableView reloadData];
        }
        
        [weakself tableViewDidFinishTriggerHeader:aIsHeader reload:NO];
    }];
}

- (void)_fetchGroupMutes:(int)aPage
{
    if (self.group.permissionType == EMGroupPermissionTypeMember || self.group.permissionType == EMGroupPermissionTypeNone) {
        return;
    }
    if (aPage == 1) {
        [self.mutesList removeAllObjects];
    }
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].groupManager getGroupMuteListFromServerWithId:self.group.groupId pageNumber:aPage pageSize:200 completion:^(NSArray *aList, EMError *aError) {
        if (aError) {
            [EMAlertController showErrorAlert:aError.errorDescription];
        } else {
            [weakself.mutesList addObjectsFromArray:aList];
        }
        if ([aList count] == 200) {
            [weakself _fetchGroupMutes:(aPage + 1)];
        }
    }];
}

- (void)tableViewDidTriggerHeaderRefresh
{
    self.cursor = nil;
    [self _fetchGroupMembersWithIsHeader:YES isShowHUD:NO];
}

- (void)tableViewDidTriggerFooterRefresh
{
    [self _fetchGroupMembersWithIsHeader:NO isShowHUD:NO];
}

#pragma mark - Action

- (void)_deleteMember:(NSString *)aUsername
{
    [self showHudInView:self.view hint:[NSString stringWithFormat:@"删除群成员 %@",aUsername]];
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].groupManager removeMembers:@[aUsername] fromGroup:self.group.groupId completion:^(EMGroup *aGroup, EMError *aError) {
        [weakself hideHud];
        if (aError) {
            [EMAlertController showErrorAlert:@"删除群成员失败"];
        } else {
            weakself.isUpdated = YES;
            [EMAlertController showSuccessAlert:@"删除群成员成功"];
            [weakself.dataArray removeObject:aUsername];
            [weakself.tableView reloadData];
        }
    }];
}

- (void)_blockMember:(NSString *)aUsername
{
    [self showHudInView:self.view hint:[NSString stringWithFormat:@"%@ 移至黑名单",aUsername]];
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].groupManager blockMembers:@[aUsername] fromGroup:self.group.groupId completion:^(EMGroup *aGroup, EMError *aError) {
        [weakself hideHud];
        if (aError) {
            [EMAlertController showErrorAlert:@"移至黑名单失败"];
        } else {
            weakself.isUpdated = YES;
            [EMAlertController showSuccessAlert:@"移至黑名单成功"];
            [weakself.dataArray removeObject:aUsername];
            [weakself.tableView reloadData];
        }
    }];
}

- (void)_muteMember:(NSString *)aUsername
{
    [self showHudInView:self.view hint:[NSString stringWithFormat:@"禁言群成员 %@",aUsername]];
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].groupManager muteMembers:@[aUsername] muteMilliseconds:-1 fromGroup:self.group.groupId completion:^(EMGroup *aGroup, EMError *aError) {
        [weakself hideHud];
        if (aError) {
            [EMAlertController showErrorAlert:@"禁言失败"];
        } else {
            weakself.isUpdated = YES;
            [EMAlertController showSuccessAlert:@"禁言成功"];
            [weakself.tableView reloadData];
            [weakself _fetchGroupMutes:1];
        }
    }];
}

- (void)_unMuteMemeber:(NSString *)aUsername
{
    [self showHudInView:self.view hint:[NSString stringWithFormat:@"解除禁言 %@",aUsername]];
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].groupManager unmuteMembers:@[aUsername] fromGroup:self.group.groupId completion:^(EMGroup *aGroup, EMError *aError) {
        [weakself hideHud];
        if (aError) {
            [EMAlertController showErrorAlert:@"解除禁言失败"];
        } else {
            weakself.isUpdated = YES;
            [EMAlertController showSuccessAlert:@"解除禁言成功"];
            [weakself _fetchGroupMutes:1];
            [weakself.tableView reloadData];
        }
    }];
}

- (void)_memberToAdmin:(NSString *)aUsername
{
    [self showHudInView:self.view hint:[NSString stringWithFormat:@"%@ 升级为管理员",aUsername]];
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].groupManager addAdmin:aUsername toGroup:self.group.groupId completion:^(EMGroup *aGroup, EMError *aError) {
        [weakself hideHud];
        if (aError) {
            [EMAlertController showErrorAlert:@"升级为管理员失败"];
        } else {
            weakself.isUpdated = YES;
            [EMAlertController showSuccessAlert:@"升级为管理员成功"];
            [weakself.dataArray removeObject:aUsername];
            [weakself.tableView reloadData];
        }
    }];
}

- (void)backAction
{
    if (self.isUpdated) {
        [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_INFO_UPDATED object:self.group];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}
//个人资料卡
- (void)personalData:(NSString *)nickName
{
    UIViewController* controller = nil;
    if([[EMClient sharedClient].currentUsername isEqualToString:nickName]) {
        controller = [[AccountViewController alloc] init];
    }else{
        controller = [[PersonalDataViewController alloc]initWithNickName:nickName];
    }
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIViewController *rootViewController = window.rootViewController;
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)rootViewController;
        [nav pushViewController:controller animated:YES];
    }
}

- (void)refreshTableView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.view.window)
            [self.tableView reloadData];
    });
}

@end
