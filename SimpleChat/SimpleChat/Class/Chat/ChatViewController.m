//
//  ChatViewController.m
//  SimpleChat
//
//  Created by stugeek on 2021/12/2.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatInfoViewController.h"
#import "GroupInfoViewController.h"
#import "PersonalDataViewController.h"
#import "AtGroupMembersViewController.h"
#import "ForwardMessage.h"
#import "UserDataModel.h"
#import "MessageCell.h"
#import "DateHelper.h"
#import "Options.h"
#import "SelectUserViewController.h"
#import "UserCardMsgView.h"
#import "UserInfoStore.h"
#import "ConfirmUserCardView.h"
#import "AccountViewController.h"

@interface ChatViewController ()<EaseChatViewControllerDelegate, EMGroupManagerDelegate, MessageCellDelegate, ConfirmUserCardViewDelegate>
@property (nonatomic, strong) EaseConversationModel *conversationModel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *titleDetailLabel;
@property (nonatomic, strong) NSString *moreMsgId;  //第一条消息的消息id
@property (nonatomic, strong) UIView* fullScreenView;
@end

@implementation ChatViewController

- (instancetype)initWithConversationId:(NSString *)conversationId conversationType:(EMConversationType)conType {
    if (self = [super init]) {
        _conversation = [EMClient.sharedClient.chatManager getConversation:conversationId type:conType createIfNotExist:YES];
        _conversationModel = [[EaseConversationModel alloc]initWithConversation:_conversation];
        
        EaseChatViewModel *viewModel = [[EaseChatViewModel alloc]init];
        _chatController = [EaseChatViewController initWithConversationId:conversationId
                                                    conversationType:conType
                                                        chatViewModel:viewModel];
        [_chatController setEditingStatusVisible:[Options sharedOptions].isChatTyping];
        _chatController.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //单聊主叫方才能发送通话记录信息(本地通话记录)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(insertLocationCallRecord:) name:EMCOMMMUNICATE_RECORD object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendUserCard:) name:CONFIRM_USERCARD object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView) name:USERINFO_UPDATE object:nil];
    [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
    [self _setupChatSubviews];
    if (_conversation.unreadMessagesCount > 0) {
        [[EMClient sharedClient].chatManager ackConversationRead:_conversation.conversationId completion:nil];
    }
}

- (void)dealloc
{
    [[EMClient sharedClient].groupManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([Options sharedOptions].isPriorityGetMsgFromServer) {
        [[EaseIMKitManager shared] markAllMessagesAsReadWithConversation:_conversation];
    }
}

- (void)_setupChatSubviews
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"backleft"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    [self _setupNavigationBarTitle];
    [self _setupNavigationBarRightItem];
    [self addChildViewController:_chatController];
    [self.view addSubview:_chatController.view];
    _chatController.view.frame = self.view.bounds;
    [self loadData:YES];
    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
}

- (void)_setupNavigationBarRightItem
{
    if (self.conversation.type == EMConversationTypeChat) {
        UIImage *image = [[UIImage imageNamed:@"userData"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(chatInfoAction)];
    }
    if (self.conversation.type == EMConversationTypeGroupChat) {
        UIImage *image = [[UIImage imageNamed:@"groupInfo"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(groupInfoAction)];
    }
}

- (void)_setupNavigationBarTitle
{
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width * 06, 40)];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:18];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.text = _conversationModel.showName;
    if(self.conversation.type == EMConversationTypeChat) {
        EMUserInfo* userInfo = [[UserInfoStore sharedInstance] getUserInfoById:self.conversation.conversationId];
        if(userInfo && userInfo.nickName.length > 0)
            self.titleLabel.text = userInfo.nickName;
    }
    [titleView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleView);
        make.left.equalTo(titleView).offset(5);
        make.right.equalTo(titleView).offset(-5);
    }];
    
    self.titleDetailLabel = [[UILabel alloc] init];
    self.titleDetailLabel.font = [UIFont systemFontOfSize:15];
    self.titleDetailLabel.textColor = [UIColor grayColor];
    self.titleDetailLabel.textAlignment = NSTextAlignmentCenter;
    [titleView addSubview:self.titleDetailLabel];
    [self.titleDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom);
        make.left.equalTo(self.titleLabel);
        make.right.equalTo(self.titleLabel);
        make.bottom.equalTo(titleView);
    }];
    
    self.navigationItem.titleView = titleView;
}

#pragma mark - EaseChatViewControllerDelegate

//自定义通话记录cell
- (UITableViewCell *)cellForItem:(UITableView *)tableView messageModel:(EaseMessageModel *)messageModel
{
    if(messageModel.message.body.type == EMMessageBodyTypeCustom) {
        EMCustomMessageBody* body = (EMCustomMessageBody*)messageModel.message.body;
        if([body.event isEqualToString:@"userCard"]){
            UserCardMsgView* userCardMsgView = [[UserCardMsgView alloc] init];
            userCardMsgView.backgroundColor = [UIColor whiteColor];
            [userCardMsgView setModel:messageModel];
            MessageCell* userCardCell = [[MessageCell alloc] initWithDirection:messageModel.direction type:messageModel.type msgView:userCardMsgView];
            userCardCell.model = messageModel;
            userCardCell.delegate = self;
            return userCardCell;
        }
    }
    return nil;
}
//对方输入状态
- (void)beginTyping
{
    self.titleDetailLabel.text = @"对方正在输入";
}
- (void)endTyping
{
    self.titleDetailLabel.text = nil;
}
//userdata
- (id<EaseUserDelegate>)userData:(NSString *)userId
{
    UserDataModel *model = [[UserDataModel alloc] initWithEaseId:userId];
    EMUserInfo* userInfo = [[UserInfoStore sharedInstance] getUserInfoById:userId];
    if(userInfo) {
        if(userInfo.avatarUrl.length > 0) {
            model.avatarURL = userInfo.avatarUrl;
        }
        if(userInfo.nickName.length > 0) {
            model.showName = userInfo.nickName;
        }
    }else{
        [[UserInfoStore sharedInstance] fetchUserInfosFromServer:@[userId]];
    }
    return model;
}

//头像点击
- (void)avatarDidSelected:(id<EaseUserDelegate>)userData
{
    if (userData && userData.easeId) {
        [self personData:userData.easeId];
    }
}

//@群成员
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"@"] && self.conversation.type == EMConversationTypeGroupChat) {
        [self _willInputAt:textView];
    }
    return YES;
}
//添加转发消息
- (NSMutableArray<EaseExtMenuModel *> *)messageLongPressExtMenuItemArray:(NSMutableArray<EaseExtMenuModel *> *)defaultLongPressItems message:(EMMessage *)message
{
    NSMutableArray<EaseExtMenuModel *> *menuArray = [[NSMutableArray<EaseExtMenuModel *> alloc]init];
    if (message.body.type == EMMessageTypeText) {
        [menuArray addObject:defaultLongPressItems[0]];
    }
    [menuArray addObject:defaultLongPressItems[1]];
    //转发
    __weak typeof(self) weakself = self;
    if (message.body.type == EMMessageBodyTypeText || message.body.type == EMMessageBodyTypeImage || message.body.type == EMMessageBodyTypeLocation || message.body.type == EMMessageBodyTypeVideo) {
        EaseExtMenuModel *forwardMenu = [[EaseExtMenuModel alloc]initWithData:[UIImage imageNamed:@"forward"] funcDesc:@"转发" handle:^(NSString * _Nonnull itemDesc, BOOL isExecuted) {
            if (isExecuted) {
                [weakself forwardMenuItemAction:message];
            }
        }];
        [menuArray addObject:forwardMenu];
    }
    if ([defaultLongPressItems count] >= 3 && [message.from isEqualToString:EMClient.sharedClient.currentUsername]) {
        [menuArray addObject:defaultLongPressItems[2]];
    }
    return menuArray;
}

- (NSMutableArray<EaseExtMenuModel *> *)inputBarExtMenuItemArray:(NSMutableArray<EaseExtMenuModel *> *)defaultInputBarItems conversationType:(EMConversationType)conversationType
{
    NSMutableArray<EaseExtMenuModel *> *menuArray = [[NSMutableArray<EaseExtMenuModel *> alloc]init];
    //相册
    [menuArray addObject:[defaultInputBarItems objectAtIndex:0]];
    //相机
    [menuArray addObject:[defaultInputBarItems objectAtIndex:1]];
    //音视频
    __weak typeof(self) weakself = self;
    if (conversationType != EMConversationTypeChatRoom) {
        EaseExtMenuModel *rtcMenu = [[EaseExtMenuModel alloc]initWithData:[UIImage imageNamed:@"video_conf"] funcDesc:@"音视频" handle:^(NSString * _Nonnull itemDesc, BOOL isExecuted) {
            if (isExecuted) {
                [weakself chatSealRtcAction];
            }
        }];
        [menuArray addObject:rtcMenu];
    }
    //位置
    [menuArray addObject:[defaultInputBarItems objectAtIndex:2]];
    //文件
    [menuArray addObject:[defaultInputBarItems objectAtIndex:3]];
    // 用户名片
    {
        EaseExtMenuModel *userCardExtModal = [[EaseExtMenuModel alloc] initWithData:[UIImage imageNamed:@"userinfo"] funcDesc:@"用户名片" handle:^(NSString * _Nonnull itemDesc, BOOL isExecuted) {
            [weakself userCardAction];
        }];
        [menuArray addObject:userCardExtModal];
    }
    
    return menuArray;
}

- (void)loadMoreMessageData:(NSString *)firstMessageId currentMessageList:(NSArray<EMMessage *> *)messageList
{
    self.moreMsgId = firstMessageId;
    [self loadData:NO];
}

- (void)didSendMessage:(EMMessage *)message error:(EMError *)error
{
    if (error) {
        [self showHint:error.errorDescription];
    }
}

#pragma mark - MessageCellDelegate

//通话记录点击事件
- (void)messageCellDidSelected:(MessageCell *)aCell
{
    if (!aCell.model.message.isReadAcked) {
        [[EMClient sharedClient].chatManager sendMessageReadAck:aCell.model.message.messageId toUser:aCell.model.message.conversationId completion:nil];
    }
    if(aCell.model.message.body.type == EMMessageBodyTypeCustom) {
        EMCustomMessageBody* body = (EMCustomMessageBody*)aCell.model.message.body;
        if([body.event isEqualToString:@"userCard"]) {
            NSString* uid = [body.customExt objectForKey:@"uid"];
            if(uid.length > 0)
                [self personData:uid];
        }
    }
    NSString *callType = nil;
    NSDictionary *dic = aCell.model.message.ext;
    if ([[dic objectForKey:EMCOMMUNICATE_TYPE] isEqualToString:EMCOMMUNICATE_TYPE_VOICE])
        callType = EMCOMMUNICATE_TYPE_VOICE;
    if ([[dic objectForKey:EMCOMMUNICATE_TYPE] isEqualToString:EMCOMMUNICATE_TYPE_VIDEO])
        callType = EMCOMMUNICATE_TYPE_VIDEO;
    if ([callType isEqualToString:EMCOMMUNICATE_TYPE_VOICE])
        [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MAKE1V1 object:@{CALL_CHATTER:aCell.model.message.conversationId, CALL_TYPE:@(EaseCallType1v1Audio)}];
    if ([callType isEqualToString:EMCOMMUNICATE_TYPE_VIDEO])
        [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MAKE1V1 object:@{CALL_CHATTER:aCell.model.message.conversationId,   CALL_TYPE:@(EaseCallType1v1Video)}];
}
//通话记录cell头像点击事件
- (void)messageAvatarDidSelected:(EaseMessageModel *)model
{
    [self personData:model.message.from];
}

#pragma mark - data

- (void)loadData:(BOOL)isScrollBottom
{
    __weak typeof(self) weakself = self;
    void (^block)(NSArray *aMessages, EMError *aError) = ^(NSArray *aMessages, EMError *aError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.chatController refreshTableViewWithData:aMessages isInsertBottom:NO isScrollBottom:isScrollBottom];
        });
    };
    
    if ([Options sharedOptions].isPriorityGetMsgFromServer) {
        EMConversation *conversation = self.conversation;
        [EMClient.sharedClient.chatManager asyncFetchHistoryMessagesFromServer:conversation.conversationId conversationType:conversation.type startMessageId:self.moreMsgId pageSize:10 completion:^(EMCursorResult *aResult, EMError *aError) {
            [self.conversation loadMessagesStartFromId:self.moreMsgId count:10 searchDirection:EMMessageSearchDirectionUp completion:block];
         }];
    } else {
        [self.conversation loadMessagesStartFromId:self.moreMsgId count:50 searchDirection:EMMessageSearchDirectionUp completion:block];
    }
}

#pragma mark - EMMoreFunctionViewDelegate

// 用户名片
- (void)userCardAction
{
    SelectUserViewController* selectUserVC = [[SelectUserViewController alloc] init];
    [self.navigationController pushViewController:selectUserVC animated:NO];
}


//本地通话记录
- (void)insertLocationCallRecord:(NSNotification*)noti
{
    NSArray<EMMessage *> * messages = (NSArray *)[noti.object objectForKey:@"msg"];
//    EMTextMessageBody *body = (EMTextMessageBody*)message.body;
//    if ([body.text isEqualToString:EMCOMMUNICATE_CALLED_MISSEDCALL]) {
//        if ([message.from isEqualToString:[EMClient sharedClient].currentUsername]) {
//            [self showHint:@"对方拒绝通话"];
//        } else {
//            [self showHint:@"对方已取消"];
//        }
//    }
    if(messages && messages.count > 0) {
        NSArray *formated = [self formatMessages:messages];
        [self.chatController.dataArray addObjectsFromArray:formated];
        if (!self.chatController.moreMsgId)
            //新会话的第一条消息
            self.chatController.moreMsgId = [messages objectAtIndex:0].messageId;
        [self.chatController refreshTableView:YES];
    }
}

- (void)refreshTableView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.view.window)
            [self.chatController triggerUserInfoCallBack:YES];
    });
}

// 确认发送名片消息
- (void)sendUserCard:(NSNotification*)noti
{
    NSString*user = (NSString *)[noti.object objectForKey:@"user"];
    if(user.length > 0) {
        EMUserInfo* userInfo = [[UserInfoStore sharedInstance] getUserInfoById:user];
        if(userInfo) {
            
            self.fullScreenView = [[UIView alloc] initWithFrame:self.view.frame];
            self.fullScreenView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.8];
            [self.view.window addSubview:self.fullScreenView];
            ConfirmUserCardView* cuView = [[ConfirmUserCardView alloc] initWithRemoteName:self.conversation.conversationId avatarUrl:userInfo.avatarUrl showName:userInfo.nickName uid:user delegate:self];
            [self.fullScreenView addSubview:cuView];
            [cuView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self.view);
                make.width.equalTo(@340);
                make.height.equalTo(@250);
            }];
        }
    }
}

#pragma mark - ConfirmUserCardViewDelegate
- (void)clickOK:(NSString*)aUid nickName:(NSString*)aNickName avatarUrl:(NSString*)aUrl
{
    if(aUid && aUid.length > 0) {
        if (!aNickName) aNickName = @"";
        if (!aUrl) aUrl = @"";
        EMCustomMessageBody* body = [[EMCustomMessageBody alloc] initWithEvent:@"userCard" ext:@{@"uid":aUid ,@"nickname":aNickName,@"avatar":aUrl}];
        [self.chatController sendMessageWithBody:body ext:nil];
    }
    [self.fullScreenView removeFromSuperview];
}

- (void)clickCancel
{
    [self.fullScreenView removeFromSuperview];
}

- (NSArray *)formatMessages:(NSArray<EMMessage *> *)aMessages
{
    NSMutableArray *formated = [[NSMutableArray alloc] init];

    for (int i = 0; i < [aMessages count]; i++) {
        EMMessage *msg = aMessages[i];
        if (msg.chatType == EMChatTypeChat && msg.isReadAcked && (msg.body.type == EMMessageBodyTypeText || msg.body.type == EMMessageBodyTypeLocation)) {
            [[EMClient sharedClient].chatManager sendMessageReadAck:msg.messageId toUser:msg.conversationId completion:nil];
        }
        
        CGFloat interval = (self.chatController.msgTimelTag - msg.timestamp) / 1000;
        if (self.chatController.msgTimelTag < 0 || interval > 60 || interval < -60) {
            NSString *timeStr = [DateHelper formattedTimeFromTimeInterval:msg.timestamp];
            [formated addObject:timeStr];
            self.chatController.msgTimelTag = msg.timestamp;
        }
        EaseMessageModel *model = nil;
        model = [[EaseMessageModel alloc] initWithEMMessage:msg];
        if (!model) {
            model = [[EaseMessageModel alloc]init];
        }
        model.userDataDelegate = [self userData:msg.from];
        [formated addObject:model];
    }
    
    return formated;
}

//音视频
- (void)chatSealRtcAction
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakself = self;
    if (self.conversation.type == EMConversationTypeChat) {
        [alertController addAction:[UIAlertAction actionWithTitle:@"视频通话" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MAKE1V1 object:@{CALL_CHATTER:weakself.conversation.conversationId, CALL_TYPE:@(EaseCallType1v1Video)}];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"语音通话" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MAKE1V1 object:@{CALL_CHATTER:weakself.conversation.conversationId, CALL_TYPE:@(EaseCallType1v1Audio)}];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }]];
        for (UIAlertAction *alertAction in alertController.actions)
            [alertAction setValue:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0] forKey:@"_titleTextColor"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didAlert" object:@{@"alert":alertController}];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    //群聊/聊天室 多人会议
    [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MAKECONFERENCE object:@{CALL_TYPE:@(EaseCallTypeMulti), CALL_MODEL:weakself.conversation, NOTIF_NAVICONTROLLER:self.navigationController}];
}

//@群成员
- (void)_willInputAt:(UITextView *)aInputView
{
    do {
        NSString *text = [NSString stringWithFormat:@"%@%@",aInputView.text,@"@"];
        EMGroup *group = [EMGroup groupWithId:self.conversation.conversationId];
        if (!group) {
            break;
        }
        [self.view endEditing:YES];
        //选择 @ 某群成员
        AtGroupMembersViewController *controller = [[AtGroupMembersViewController alloc] initWithGroup:group];
        [self.navigationController pushViewController:controller animated:NO];
        [controller setSelectedCompletion:^(NSString * _Nonnull aName) {
            NSString *newStr = [NSString stringWithFormat:@"%@%@ ", text, aName];
            [aInputView setText:newStr];
            aInputView.selectedRange = NSMakeRange(newStr.length, 0);
            [aInputView becomeFirstResponder];
        }];
        
    } while (0);
}

//个人资料页
- (void)personData:(NSString*)contanct
{
    UIViewController* controller = nil;
    if([[EMClient sharedClient].currentUsername isEqualToString:contanct]) {
        controller = [[AccountViewController alloc] init];
    }else{
        controller = [[PersonalDataViewController alloc]initWithNickName:contanct];
    }
    [self.navigationController pushViewController:controller animated:YES];
}

//单聊详情页
- (void)chatInfoAction
{
    if (self.conversation.type == EMConversationTypeChat) {
        [self.chatController cleanPopupControllerView];
        __weak typeof(self) weakself = self;
        ChatInfoViewController *chatInfoController = [[ChatInfoViewController alloc]initWithCoversation:self.conversation];
        [chatInfoController setClearRecordCompletion:^(BOOL isClearRecord) {
            if (isClearRecord) {
                [weakself.chatController.dataArray removeAllObjects];
                [weakself.chatController.tableView reloadData];
            }
        }];
        [self.navigationController pushViewController:chatInfoController animated:YES];
    }
}

//群组 详情页
- (void)groupInfoAction {
    if (self.conversation.type == EMConversationTypeGroupChat) {
        [self.chatController cleanPopupControllerView];
        __weak typeof(self) weakself = self;
        GroupInfoViewController *groupInfocontroller = [[GroupInfoViewController alloc] initWithConversation:self.conversation];
        [groupInfocontroller setLeaveOrDestroyCompletion:^{
            [weakself.navigationController popViewControllerAnimated:YES];
        }];
        [groupInfocontroller setClearRecordCompletion:^(BOOL isClearRecord) {
            if (isClearRecord) {
                [weakself.chatController.dataArray removeAllObjects];
                [weakself.chatController.tableView reloadData];
            }
        }];
        [self.navigationController pushViewController:groupInfocontroller animated:YES];
    }
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
