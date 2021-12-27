//
//  ConversationsViewController.m
//  SimpleChat
//
//  Created by stugeek on 2021/12/2.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import "ConversationsViewController.h"
#import "ChatViewController.h"
#import "RealtimeSearch.h"
#import "PellTableViewSelect.h"
#import "EMSearchResultController.h"
#import "InviteGroupMemberViewController.h"
#import "CreateGroupViewController.h"
#import "InviteFriendViewController.h"
#import "NotificationViewController.h"
#import "ConversationUserDataModel.h"
#import "UserInfoStore.h"

@interface ConversationsViewController() <EaseConversationsViewControllerDelegate, EMSearchControllerDelegate>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *searchLabel;
@property (nonatomic, strong) UIButton *addImageBtn;
@property (nonatomic, strong) InviteGroupMemberViewController *inviteController;
@property (nonatomic, strong) EaseConversationsViewController *easeConvsVC;
@property (nonatomic, strong) EaseConversationViewModel *viewModel;
@property (nonatomic, strong) UINavigationController *resultNavigationController;
@property (nonatomic, strong) EMSearchResultController *resultController;
@end

@implementation ConversationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView) name:CHAT_BACKOFF object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView) name:GROUP_LIST_FETCHFINISHED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView) name:USERINFO_UPDATE object:nil];
    [self initView];
    if (![Options sharedOptions].isFirstLaunch) {
        [Options sharedOptions].isFirstLaunch = YES;
        [[Options sharedOptions] archive];
        [self refreshTableViewWithData];
    }
    // [self refreshTableViewWithData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    Options *options = [Options sharedOptions];
    if (!options.isEnlargerFontMode) {
        self.titleLabel.font = [UIFont systemFontOfSize:18];
        self.searchLabel.font = [UIFont systemFontOfSize:16];
    }
    else {
        self.titleLabel.font = [UIFont systemFontOfSize:28];
        self.searchLabel.font = [UIFont systemFontOfSize:26];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initView
{
    UIColor* lightBlue=[UIColor colorWithRed:220.0f/255.0f green:236.0f/255.0f blue:250.0f/255.0f alpha:0.5];
    self.view.backgroundColor = lightBlue;
    
    if (self.titleLabel == nil) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.text = @"会话";
        self.titleLabel.textColor = [UIColor blackColor];
        [self.view addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(self.view).offset(EMVIEWTOPMARGIN + 35);
            make.height.equalTo(@25);
        }];
    }
    
    self.addImageBtn = [[UIButton alloc]init];
    [self.addImageBtn setImage:[UIImage imageNamed:@"icon-add"] forState:UIControlStateNormal];
    [self.addImageBtn addTarget:self action:@selector(moreAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addImageBtn];
    [self.addImageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@35);
        make.centerY.equalTo(self.titleLabel);
        make.right.equalTo(self.view).offset(-16);
    }];
    
    self.viewModel = [[EaseConversationViewModel alloc] init];
    self.viewModel.canRefresh = YES;
    self.viewModel.badgeLabelPosition = EMAvatarTopRight;
    
    self.easeConvsVC = [[EaseConversationsViewController alloc] initWithModel:self.viewModel];
    self.easeConvsVC.delegate = self;
    [self addChildViewController:self.easeConvsVC];
    [self.view addSubview:self.easeConvsVC.view];
    [self.easeConvsVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(15);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    [self _updateConversationViewTableHeader];
}

- (void)_updateConversationViewTableHeader {
    UIColor* LightSkyBlue=[UIColor colorWithRed:185.0f/255.0f green:236.0f/255.0f blue:250.0f/255.0f alpha:0.5];
    self.easeConvsVC.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.easeConvsVC.tableView.tableHeaderView.backgroundColor = LightSkyBlue;
    UIControl *control = [[UIControl alloc] initWithFrame:CGRectZero];
    control.clipsToBounds = YES;
    control.layer.cornerRadius = 18;
    control.backgroundColor = UIColor.whiteColor;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchButtonAction)];
    [control addGestureRecognizer:tap];
    
    [self.easeConvsVC.tableView.tableHeaderView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.easeConvsVC.tableView);
        make.width.equalTo(self.easeConvsVC.tableView);
        make.top.equalTo(self.easeConvsVC.tableView);
        make.height.mas_equalTo(52);
    }];
    
    [self.easeConvsVC.tableView.tableHeaderView addSubview:control];
    [control mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_offset(36);
        make.top.equalTo(self.easeConvsVC.tableView.tableHeaderView).offset(8);
        make.bottom.equalTo(self.easeConvsVC.tableView.tableHeaderView).offset(-8);
        make.left.equalTo(self.easeConvsVC.tableView.tableHeaderView.mas_left).offset(17);
        make.right.equalTo(self.easeConvsVC.tableView.tableHeaderView).offset(-16);
    }];
    
    UIView *subView = [[UIView alloc] init];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search"]];
    [subView addSubview:imageView];
    [imageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(15);
        make.left.equalTo(subView);
        make.top.equalTo(subView);
        make.bottom.equalTo(subView);
    }];
    
    if (self.searchLabel == nil) {
        self.searchLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.searchLabel.text = @"搜索";
        self.searchLabel.textColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1];
        [self.searchLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [subView addSubview:self.searchLabel];
        [self.searchLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(imageView.mas_right).offset(3);
            make.right.equalTo(subView);
            make.top.equalTo(subView).offset(-10);
            make.bottom.equalTo(subView).offset(10);
        }];
    }
    
    [control addSubview:subView];
    
    [subView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(control);
    }];
}

- (void)_setupSearchResultController
{
    __weak typeof(self) weakself = self;
    self.resultController.tableView.rowHeight = 70;
    self.resultController.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.resultController setCellForRowAtIndexPathCompletion:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
        NSString *cellIdentifier = @"EaseConversationCell";
        EaseConversationCell *cell = (EaseConversationCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [EaseConversationCell tableView:tableView cellViewModel:weakself.viewModel];
        }
        
        NSInteger row = indexPath.row;
        EaseConversationModel *model = [weakself.resultController.dataArray objectAtIndex:row];
        cell.model = model;
        return cell;
    }];
    [self.resultController setCanEditRowAtIndexPath:^BOOL(UITableView *tableView, NSIndexPath *indexPath) {
        return YES;
    }];
    [self.resultController setTrailingSwipeActionsConfigurationForRowAtIndexPath:^UISwipeActionsConfiguration *(UITableView *tableView, NSIndexPath *indexPath) {
        EaseConversationModel *model = [weakself.resultController.dataArray objectAtIndex:indexPath.row];
        UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive
                                                                                   title:@"删除会话"
                                                                                 handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL))
        {
            [weakself.resultController.tableView setEditing:NO];
            int unreadCount = [[EMClient sharedClient].chatManager getConversationWithConvId:model.easeId].unreadMessagesCount;
            [[EMClient sharedClient].chatManager deleteConversation:model.easeId isDeleteMessages:YES completion:^(NSString *aConversationId, EMError *aError) {
                if (!aError) {
                    [weakself.resultController.dataArray removeObjectAtIndex:indexPath.row];
                    [weakself.resultController.tableView reloadData];
                    if (unreadCount > 0 && weakself.deleteConversationCompletion) {
                        weakself.deleteConversationCompletion(YES);
                    }
                }
            }];
        }];
        UIContextualAction *topAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
                                                                                title:!model.isTop ? @"置顶" : @"取消置顶"
                                                                              handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL))
        {
            [weakself.resultController.tableView setEditing:NO];
            [model setIsTop:!model.isTop];
            [weakself.easeConvsVC refreshTable];
        }];
        UISwipeActionsConfiguration *actions = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction,topAction]];
        actions.performsFirstActionWithFullSwipe = NO;
        return actions;
    }];
    [self.resultController setDidSelectRowAtIndexPathCompletion:^(UITableView *tableView, NSIndexPath *indexPath) {
        NSInteger row = indexPath.row;
        EaseConversationModel *model = [weakself.resultController.dataArray objectAtIndex:row];
        weakself.resultController.searchBar.text = @"";
        [weakself.resultController.searchBar resignFirstResponder];
        weakself.resultController.searchBar.showsCancelButton = NO;
        [weakself searchBarCancelButtonAction:nil];
        [weakself.resultNavigationController dismissViewControllerAnimated:YES completion:nil];
        //系统通知
        if ([model.easeId isEqualToString:EMSYSTEMNOTIFICATIONID]) {
            NotificationViewController *controller = [[NotificationViewController alloc] initWithStyle:UITableViewStylePlain];
            [weakself.navigationController pushViewController:controller animated:YES];
            return;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:CHAT_PUSHVIEWCONTROLLER object:model.easeId];
    }];
}

- (void)refreshTableView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.view.window)
            [self.easeConvsVC refreshTable];
    });
}

- (void)refreshTableViewWithData
{
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].chatManager getConversationsFromServer:^(NSArray *aCoversations, EMError *aError) {
        if (!aError && [aCoversations count] > 0) {
            [weakself.easeConvsVC.dataAry removeAllObjects];
            [weakself.easeConvsVC.dataAry addObjectsFromArray:aCoversations];
            [weakself.easeConvsVC refreshTable];
        }
    }];
}

#pragma mark - searchButtonAction

- (void)searchButtonAction
{
    if (self.resultNavigationController == nil) {
        self.resultController = [[EMSearchResultController alloc] init];
        self.resultController.delegate = self;
        self.resultNavigationController = [[UINavigationController alloc] initWithRootViewController:self.resultController];
        [self.resultNavigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"navBarBg"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forBarMetrics:UIBarMetricsDefault];
        [self _setupSearchResultController];
    }
    [self.resultController.searchBar becomeFirstResponder];
    self.resultController.searchBar.showsCancelButton = YES;
    self.resultNavigationController.modalPresentationStyle = 0;
    [self presentViewController:self.resultNavigationController animated:YES completion:nil];
}

#pragma mark - moreAction

- (void)moreAction
{
    [PellTableViewSelect addPellTableViewSelectWithWindowFrame:CGRectMake(self.view.bounds.size.width-160, self.addImageBtn.frame.origin.y, 145, 104) selectData:@[@"创建群组",@"添加好友"] images:@[@"icon-创建群组",@"icon-添加好友"] locationY:30 - (22 - EMVIEWTOPMARGIN) action:^(NSInteger index){
        if(index == 0) {
            [self createGroup];
        } else if (index == 1) {
            [self addFriend];
        }
    } animated:YES];
}

//创建群组
- (void)createGroup
{
    self.inviteController = nil;
    self.inviteController = [[InviteGroupMemberViewController alloc] init];
    __weak typeof(self) weakself = self;
    [self.inviteController setDoneCompletion:^(NSArray * _Nonnull aSelectedArray) {
        CreateGroupViewController *createController = [[CreateGroupViewController alloc] initWithSelectedMembers:aSelectedArray];
        createController.inviteController = weakself.inviteController;
        [createController setSuccessCompletion:^(EMGroup * _Nonnull aGroup) {
            [[NSNotificationCenter defaultCenter] postNotificationName:CHAT_PUSHVIEWCONTROLLER object:aGroup];
        }];
        [weakself.navigationController pushViewController:createController animated:YES];
    }];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.inviteController];
    navController.modalPresentationStyle = 0;
    [self presentViewController:navController animated:YES completion:nil];
}

//添加好友
- (void)addFriend
{
    InviteFriendViewController *controller = [[InviteFriendViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - EMSearchControllerDelegate

- (void)searchBarWillBeginEditing:(UISearchBar *)searchBar
{
    self.resultController.searchKeyword = nil;
}

- (void)searchBarCancelButtonAction:(UISearchBar *)searchBar
{
    [[RealtimeSearch shared] realtimeSearchStop];
    
    if ([self.resultController.dataArray count] > 0) {
        [self.resultController.dataArray removeAllObjects];
    }
    [self.resultController.tableView reloadData];
    [self.easeConvsVC refreshTabView];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.view endEditing:YES];
}

- (void)searchTextDidChangeWithString:(NSString *)aString
{
    self.resultController.searchKeyword = aString;
    
    __weak typeof(self) weakself = self;
    [[RealtimeSearch shared] realtimeSearchWithSource:self.easeConvsVC.dataAry searchText:aString collationStringSelector:@selector(showName) resultBlock:^(NSArray *results) {
         dispatch_async(dispatch_get_main_queue(), ^{
             if ([weakself.resultController.dataArray count] > 0) {
                 [weakself.resultController.dataArray removeAllObjects];
             }
            [weakself.resultController.dataArray addObjectsFromArray:results];
            [weakself.resultController.tableView reloadData];
        });
    }];
}
   
#pragma mark - EaseConversationsViewControllerDelegate

- (id<EaseUserDelegate>)easeUserDelegateAtConversationId:(NSString *)conversationId conversationType:(EMConversationType)type
{
    ConversationUserDataModel *userData = [[ConversationUserDataModel alloc]initWithEaseId:conversationId conversationType:type];
    if(type == EMConversationTypeChat) {
        if (![conversationId isEqualToString:EMSYSTEMNOTIFICATIONID]) {
            EMUserInfo* userInfo = [[UserInfoStore sharedInstance] getUserInfoById:conversationId];
            if(userInfo) {
                if([userInfo.nickName length] > 0) {
                    userData.showName = userInfo.nickName;
                }
                if([userInfo.avatarUrl length] > 0) {
                    userData.avatarURL = userInfo.avatarUrl;
                }
            }else{
                [[UserInfoStore sharedInstance] fetchUserInfosFromServer:@[conversationId]];
            }
        }
    }
    return userData;
}

- (NSArray<UIContextualAction *> *)easeTableView:(UITableView *)tableView trailingSwipeActionsForRowAtIndexPath:(NSIndexPath *)indexPath actions:(NSArray<UIContextualAction *> *)actions
{
    NSMutableArray<UIContextualAction *> *array = [[NSMutableArray<UIContextualAction *> alloc]init];
    __weak typeof(self) weakself = self;
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
                                                                               title:@"删除"
                                                                             handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL))
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"确认删除？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *clearAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [tableView setEditing:NO];
            [self _deleteConversation:indexPath];
        }];
        [clearAction setValue:[UIColor colorWithRed:245/255.0 green:52/255.0 blue:41/255.0 alpha:1.0] forKey:@"_titleTextColor"];
        [alertController addAction:clearAction];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [tableView setEditing:NO];
        }];
        [cancelAction  setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
        [alertController addAction:cancelAction];
        alertController.modalPresentationStyle = 0;
        [weakself presentViewController:alertController animated:YES completion:nil];
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    [array addObject:deleteAction];
    [array addObject:actions[1]];
    return [array copy];
}

- (void)easeTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EaseConversationCell *cell = (EaseConversationCell*)[tableView cellForRowAtIndexPath:indexPath];
    //系统通知  
    if ([cell.model.easeId isEqualToString:EMSYSTEMNOTIFICATIONID]) {
        NotificationViewController *controller = [[NotificationViewController alloc] initWithStyle:UITableViewStylePlain];
        [self.navigationController pushViewController:controller animated:YES];
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:CHAT_PUSHVIEWCONTROLLER object:cell.model];
}


#pragma mark - Action

//删除会话
- (void)_deleteConversation:(NSIndexPath *)indexPath
{
    __weak typeof(self) weakSelf = self;
    NSInteger row = indexPath.row;
    EaseConversationModel *model = [self.easeConvsVC.dataAry objectAtIndex:row];
    int unreadCount = [[EMClient sharedClient].chatManager getConversationWithConvId:model.easeId].unreadMessagesCount;
    [[EMClient sharedClient].chatManager deleteConversation:model.easeId
                                           isDeleteMessages:YES
                                                 completion:^(NSString *aConversationId, EMError *aError) {
        if (!aError) {
            [weakSelf.easeConvsVC.dataAry removeObjectAtIndex:row];
            [weakSelf.easeConvsVC refreshTabView];
            if (unreadCount > 0 && weakSelf.deleteConversationCompletion) {
                weakSelf.deleteConversationCompletion(YES);
            }
        }
    }];
}

@end
