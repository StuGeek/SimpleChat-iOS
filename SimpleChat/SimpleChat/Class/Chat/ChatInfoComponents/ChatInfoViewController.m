//
//  ChatInfoViewController.m
//  SimpleChat
//
//  Created by stugeek on 2021/12/2.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import "ChatInfoViewController.h"
#import "PersonalDataViewController.h"
#import "ChatRecordViewController.h"
#import "AccountViewController.h"
#import "UserInfoStore.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ChatInfoViewController ()

@property (nonatomic, strong) UITableViewCell *clearChatRecordCell;
@property (nonatomic, strong) EMConversation *conversation;
@property (nonatomic, strong) EaseConversationModel *conversationModel;

@end

@implementation ChatInfoViewController

- (instancetype)initWithCoversation:(EMConversation *)aConversation
{
    self = [super init];
    if (self) {
        _conversation = aConversation;
        _conversationModel = [[EaseConversationModel alloc]initWithConversation:_conversation];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    
    self.showRefreshHeader = NO;
}

- (void)initView
{
    [self addPopBackLeftItem];
    self.title = @"聊天详情";

    self.tableView.scrollEnabled = NO;
    self.tableView.rowHeight = 60;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSString *cellIdentifier = @"UITableViewCellValue1";
    if (section == 0)
        cellIdentifier = @"UITableViewCellStyleSubtitle";
    
    UISwitch *switchControl = nil;
    BOOL isSwitchCell = NO;
    if (section == 2) {
        isSwitchCell = YES;
        cellIdentifier = @"UITableViewCellSwitch";
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    // Configure the cell...
    if (cell == nil) {
        if (section == 0) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        } else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (isSwitchCell) {
            switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 65, 20, 50, 40)];
            switchControl.tag = [self _tagWithIndexPath:indexPath];
            [switchControl addTarget:self action:@selector(cellSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:switchControl];
        }
    }
    
    if (isSwitchCell)
        switchControl = [cell.contentView viewWithTag:[self _tagWithIndexPath:indexPath]];
    
    cell.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (section == 0) {
        cell.imageView.image = [UIImage imageNamed:self.conversation.type == EMConversationTypeChat ? @"defaultAvatar" : @"groupChat"];
        cell.textLabel.font = [UIFont systemFontOfSize:18.0];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
        cell.textLabel.text = self.conversation.conversationId;
        if(self.conversation.type == EMConversationTypeChat) {
            EMUserInfo* userInfo = [[UserInfoStore sharedInstance] getUserInfoById:self.conversation.conversationId];
            if(userInfo) {
                if(userInfo.avatarUrl.length > 0) {
                    NSURL * url = [NSURL URLWithString:userInfo.avatarUrl];
                    if(url) {
                        [cell.imageView sd_setImageWithURL:url completed:nil];
                    }
                }
                if(userInfo.nickName.length > 0) {
                    cell.textLabel.text = userInfo.nickName;
                    cell.detailTextLabel.text = self.conversation.conversationId;
                }
            }
        }
    }
    if (section == 1) cell.textLabel.text = @"查找聊天记录";
    /*
    if (section == 2) {
        cell.textLabel.text = @"消息免打扰";
        NSArray *ignoredUidList = [[EMClient sharedClient].pushManager noPushUIds];
        if ([ignoredUidList containsObject:self.conversation.conversationId]) {
            [switchControl setOn:(YES) animated:YES];
        } else {
            [switchControl setOn:(NO) animated:YES];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
    }*/
    if (section == 2) {
        cell.textLabel.text = @"会话置顶";
        [switchControl setOn:([self.conversationModel isTop]) animated:YES];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    if (section == 3)
        cell.textLabel.text = @"清空聊天记录";
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 2)
        return 60;
    
    return 66;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return 0.001;
    
    return 24.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 4)
        return 40;
    
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    if (section == 0) {
        //好友资料
        UIViewController* controller = nil;
        if([[EMClient sharedClient].currentUsername isEqualToString:self.conversation.conversationId]) {
            controller = [[AccountViewController alloc] init];
        }else{
            controller = [[PersonalDataViewController alloc]initWithNickName:self.conversation.conversationId];
        }
        [self.navigationController pushViewController:controller animated:YES];
        return;
    }
    if (section == 1) {
        //查找聊天记录
        ChatRecordViewController *chatRrcordController = [[ChatRecordViewController alloc]initWithCoversationModel:self.conversation];
        //ChatViewController *controller = [[ChatViewController alloc]initWithConversationId:self.conversationModel.emModel.conversationId type:EMConversationTypeChat createIfNotExist:NO isChatRecord:YES];
        [self.navigationController pushViewController:chatRrcordController animated:YES];
        return;
    }
    if (section == 3) {
        //清空聊天记录
        [self deleteChatRecord];
        return;
    }
}

//清除聊天记录
- (void)deleteChatRecord
{
    __weak typeof(self) weakself = self;
    //UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"确定删除和%@的聊天记录吗？",self.conversationModel.emModel.conversationId] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"您确认要清空所有聊天记录吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *clearAction = [UIAlertAction actionWithTitle:@"清空" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:self.conversation.conversationId type:EMConversationTypeChat createIfNotExist:NO];
        EMError *error = nil;
        [conversation deleteAllMessages:&error];
        if (weakself.clearRecordCompletion) {
            if (!error) {
                [EMAlertController showSuccessAlert:@"聊天记录已清空！"];
                weakself.clearRecordCompletion(YES);
            } else {
                [EMAlertController showErrorAlert:@"清空聊天记录失败！"];
                weakself.clearRecordCompletion(NO);
            }
        }
    }];
    [clearAction setValue:[UIColor colorWithRed:245/255.0 green:52/255.0 blue:41/255.0 alpha:1.0] forKey:@"_titleTextColor"];
    [alertController addAction:clearAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [cancelAction  setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
    [alertController addAction:cancelAction];
    alertController.modalPresentationStyle = 0;
    [self presentViewController:alertController animated:YES completion:nil];
}

//cell开关
- (void)cellSwitchValueChanged:(UISwitch *)aSwitch
{
    __weak typeof(self) weakself = self;
    NSIndexPath *indexPath = [self _indexPathWithTag:aSwitch.tag];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    /*
    if (section == 2) {
        if (aSwitch.isOn) {
            [[EMClient sharedClient].pushManager updatePushServiceForUsers:@[self.conversation.conversationId] disablePush:YES completion:^(EMError * _Nonnull aError) {
                if (aError) {
                    [weakself showHint:[NSString stringWithFormat:@"设置免打扰失败 reason：%@",aError.errorDescription]];
                    [aSwitch setOn:NO];
                }
            }];
        } else {
            [[EMClient sharedClient].pushManager updatePushServiceForUsers:@[self.conversation.conversationId] disablePush:NO completion:^(EMError * _Nonnull aError) {
                if (aError) {
                    [weakself showHint:[NSString stringWithFormat:@"设置免打扰失败 reason：%@",aError.errorDescription]];
                    [aSwitch setOn:YES];
                }
            }];
        }
    }*/
    if (section == 2) {
        if (row == 0) {
            //置顶
            if (aSwitch.isOn) {
                [self.conversationModel setIsTop:YES];
            } else {
                [self.conversationModel setIsTop:NO];
            }
        }
    }
}

#pragma mark - Private

- (NSInteger)_tagWithIndexPath:(NSIndexPath *)aIndexPath
{
    NSInteger tag = aIndexPath.section * 10 + aIndexPath.row;
    return tag;
}

- (NSIndexPath *)_indexPathWithTag:(NSInteger)aTag
{
    NSInteger section = aTag / 10;
    NSInteger row = aTag % 10;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    return indexPath;
}

@end
