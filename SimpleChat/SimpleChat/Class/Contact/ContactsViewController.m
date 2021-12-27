//
//  ContactsViewController.m
//  SimpleChat
//
//  Created by stugeek on 2021/12/2.
//  Copyright © 2021 stugeek. All rights reserved.
//

#define NEWFRIEND @"newFriend"
#define GROUPLIST @"groupList"

#import "ContactsViewController.h"
#import "RealtimeSearch.h"
#import "EMAvatarNameCell.h"
#import "InviteFriendViewController.h"
#import "PellTableViewSelect.h"
#import "JoinGroupViewController.h"
#import "ContactModel.h"
#import "PersonalDataViewController.h"
#import "EMSearchResultController.h"
#import "UserInfoStore.h"

@interface ContactsViewController ()<EMContactManagerDelegate, EMSearchControllerDelegate, EaseContactsViewControllerDelegate>
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *searchLabel;
@property (nonatomic, strong) EaseContactsViewController *contactsVC;
@property (nonatomic, strong) UIButton *addImageBtn;
@property (nonatomic, strong) NSMutableArray<NSString*> *contancts;
@property (nonatomic, strong) UINavigationController *resultNavigationController;
@property (nonatomic, strong) EMSearchResultController *resultController;
@end

@implementation ContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [[EMClient sharedClient].contactManager addDelegate:self delegateQueue:nil];
    [self initView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView) name:CONTACT_BLACKLIST_UPDATE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView) name:USERINFO_UPDATE object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
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
    [[EMClient sharedClient].contactManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) showUsers:(NSArray*)aUserIds
{
    self->_contancts = [aUserIds mutableCopy];
    NSMutableArray<EaseUserDelegate> *contacts = [NSMutableArray<EaseUserDelegate> array];
    for (NSString *username in aUserIds) {
        ContactModel *model = [[ContactModel alloc] init];
        EMUserInfo* userInfo = [[UserInfoStore sharedInstance] getUserInfoById:username];
        model.easeId = username;
        if(userInfo) {
            if([userInfo.avatarUrl length] > 0) {
                model.avatarURL = userInfo.avatarUrl;
            }
            if(userInfo.nickName.length > 0) {
                model.showName = userInfo.nickName;
            }
        }else{
            [[UserInfoStore sharedInstance] fetchUserInfosFromServer:@[username]];
        }
            
        [contacts addObject:model];
    }
    
    [self->_contactsVC setContacts:contacts];
    [self->_contactsVC endRefresh];
}

#pragma mark - EaseContactsViewControllerDelegate

- (void)willBeginRefresh {
    [EMClient.sharedClient.contactManager getContactsFromServerWithCompletion:^(NSArray *aList, EMError *aError) {
        if (!aError) {
            [self showUsers:aList];
        }
    }];
}

- (void)easeTableView:(UITableView *)tableView didSelectRowAtContactModel:(EaseContactModel *)contact {
    if ([contact.easeId isEqualToString:NEWFRIEND]) {
        InviteFriendViewController *controller = [[InviteFriendViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
        return;
    }
    if ([contact.easeId isEqualToString:GROUPLIST]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_LIST_PUSHVIEWCONTROLLER object:@{NOTIF_NAVICONTROLLER:self.navigationController}];
        return;
    }
    [self personData:contact.easeId];
    //[[NSNotificationCenter defaultCenter] postNotificationName:CHAT_PUSHVIEWCONTROLLER object:contact.easeId];
}

- (NSArray<UIContextualAction *> *)easeTableView:(UITableView *)tableView trailingSwipeActionsForRowAtContactModel:(EaseContactModel *)contact actions:(NSArray<UIContextualAction *> *)actions
{
    //通讯录头部非联系人列表禁止侧滑
    if ([contact.easeId isEqualToString:NEWFRIEND] || [contact.easeId isEqualToString:GROUPLIST]) {
        return nil;
    }
    __weak typeof(self) weakself = self;
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive
                                                                               title:@"删除"
                                                                             handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL))
    {
        [weakself showHudInView:weakself.view hint:@"删除好友..."];
        [weakself _deleteContact:contact.easeId completion:^(EMError *aError) {
            [weakself.resultController hideHud];
        }];
    }];
    return @[deleteAction];
}

- (void)updateContactViewTableHeader {
    _contactsVC.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    UIColor* LightSkyBlue=[UIColor colorWithRed:185.0f/255.0f green:236.0f/255.0f blue:250.0f/255.0f alpha:0.5];
    _contactsVC.tableView.tableHeaderView.backgroundColor = LightSkyBlue;
    UIControl *control = [[UIControl alloc] initWithFrame:CGRectZero];
    control.clipsToBounds = YES;
    control.layer.cornerRadius = 18;
    control.backgroundColor = UIColor.whiteColor;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchButtonAction)];
    [control addGestureRecognizer:tap];
    
    [_contactsVC.tableView.tableHeaderView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_contactsVC.tableView);
        make.width.equalTo(_contactsVC.tableView);
        make.top.equalTo(_contactsVC.tableView);
        make.height.mas_equalTo(52);
    }];
    
    [_contactsVC.tableView.tableHeaderView addSubview:control];
    [control mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_offset(36);
        make.top.equalTo(_contactsVC.tableView.tableHeaderView).offset(8);
        make.bottom.equalTo(_contactsVC.tableView.tableHeaderView).offset(-8);
        make.left.equalTo(_contactsVC.tableView.tableHeaderView.mas_left).offset(17);
        make.right.equalTo(_contactsVC.tableView.tableHeaderView).offset(-16);
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

#pragma mark - Subviews

- (void)initView
{
    UIColor* lightBlue=[UIColor colorWithRed:220.0f/255.0f green:236.0f/255.0f blue:250.0f/255.0f alpha:0.5];
    self.view.backgroundColor = lightBlue;
    
    if (self.titleLabel == nil) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.text = @"通讯录";
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
    [self.addImageBtn addTarget:self action:@selector(addAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addImageBtn];
    [self.addImageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@35);
        make.centerY.equalTo(self.titleLabel);
        make.right.equalTo(self.view).offset(-16);
    }];
    EaseContactsViewModel *model = [[EaseContactsViewModel alloc] init];
    model.defaultAvatarImage = [UIImage imageNamed:@"defaultAvatar"];
    model.avatarType = Rectangular;
    model.sectionTitleEdgeInsets= UIEdgeInsetsMake(5, 15, 5, 5);
    _contactsVC = [[EaseContactsViewController alloc] initWithModel:model];
    _contactsVC.customHeaderItems = [self items];
    _contactsVC.delegate = self;
    [self addChildViewController:_contactsVC];
    [self.view addSubview:_contactsVC.view];
    [_contactsVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(15);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    [self updateContactViewTableHeader];

    [self fetchAllContactsUserInfo];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)fetchAllContactsUserInfo
{
    NSArray* aList = [[[EMClient sharedClient] contactManager] getContacts];
    NSMutableArray * array = [NSMutableArray array];
    for (NSString* userId in aList) {
        if(![[UserInfoStore sharedInstance] getUserInfoById:userId])
            [array addObject:userId];
    }
    NSInteger count = array.count;
    int index = 0;
    while (count > 0) {
        NSRange range;
        range.location = 100*index;
        if(count > 100) {
            range.length = 100;
        }else
            range.length = count;
        NSArray* arr = [array subarrayWithRange:range];
        [[[EMClient sharedClient] userInfoManager] fetchUserInfoById:arr completion:^(NSDictionary *aUserDatas, EMError *aError) {
            if(!aError) {
                NSMutableArray* arrayUserInfo = [NSMutableArray array];
                for (NSString* uid in aUserDatas) {
                    EMUserInfo* userInfo = [aUserDatas objectForKey:uid];
                    if(uid.length > 0 && userInfo)
                    {
                        [arrayUserInfo addObject:userInfo];
                    }
                }
                [[UserInfoStore sharedInstance] addUserInfos:arrayUserInfo];
            }
        }];
        count -= 100;
    }
}

- (NSArray<EaseUserDelegate> *)items {
    ContactModel *newFriends = [[ContactModel alloc] init];
    newFriends.easeId = NEWFRIEND;
    newFriends.showName = @"新的好友";
    newFriends.defaultAvatar = [UIImage imageNamed:@"newFriend"];
    ContactModel *groups = [[ContactModel alloc] init];
    groups.easeId = GROUPLIST;
    groups.showName = @"群聊";
    groups.defaultAvatar = [UIImage imageNamed:@"groupchat"];
    
    return (NSArray<EaseUserDelegate> *)@[newFriends, groups];
}

- (void)_setupSearchResultController
{
    __weak typeof(self) weakself = self;
    self.resultController.tableView.rowHeight = 60;
    self.resultController.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.resultController setCellForRowAtIndexPathCompletion:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
        NSString *CellIdentifier = @"EMAvatarNameCell";
        EMAvatarNameCell *cell = (EMAvatarNameCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[EMAvatarNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        NSInteger row = indexPath.row;
        NSString *contact = weakself.resultController.dataArray[row];
        cell.avatarView.image = [UIImage imageNamed:@"defaultAvatar"];
        cell.nameLabel.text = contact;
        return cell;
    }];
    [self.resultController setCanEditRowAtIndexPath:^BOOL(UITableView *tableView, NSIndexPath *indexPath) {
        return YES;
    }];
    [self.resultController setTrailingSwipeActionsConfigurationForRowAtIndexPath:^UISwipeActionsConfiguration *(UITableView *tableView, NSIndexPath *indexPath) {
        UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive
                                                                                   title:@"删除"
                                                                                 handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL))
        {
            NSInteger row = indexPath.row;
            NSString *contact = weakself.contancts[row];
            [weakself.resultController showHudInView:weakself.resultController.view hint:@"删除好友..."];
            [weakself _deleteContact:contact completion:^(EMError *aError) {
                [weakself.resultController hideHud];
            }];
        }];
        UISwipeActionsConfiguration *actions = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
        actions.performsFirstActionWithFullSwipe = NO;
        return actions;
    }];
    [self.resultController setDidSelectRowAtIndexPathCompletion:^(UITableView *tableView, NSIndexPath *indexPath) {
        NSInteger row = indexPath.row;
        NSString *contact = weakself.resultController.dataArray[row];
        
        weakself.resultController.searchBar.text = @"";
        [weakself.resultController.searchBar resignFirstResponder];
        weakself.resultController.searchBar.showsCancelButton = NO;
        [weakself searchBarCancelButtonAction:nil];
        [weakself.resultNavigationController dismissViewControllerAnimated:YES completion:nil];
        
        [weakself personData:contact];
    }];
}

- (void)refreshTableView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray* userIds = [[[EMClient sharedClient] contactManager] getContacts];
        [self showUsers:userIds];
    });
}

#pragma mark - EMContactManagerDelegate

- (void)friendshipDidAddByUser:(NSString *)aUsername
{
    [[[EMClient sharedClient] userInfoManager] fetchUserInfoById:@[aUsername] completion:^(NSDictionary *aUserDatas, EMError *aError) {
        if(!aError) {
            
        }
    }];
    [self.contactsVC refreshTable];
    [self.contancts addObject:aUsername];
}

- (void)friendshipDidRemoveByUser:(NSString *)aUsername
{
    [self.contactsVC refreshTable];
    [self.contancts removeObject:aUsername];
}

#pragma mark - EMSearchControllerDelegate

- (void)searchBarWillBeginEditing:(UISearchBar *)searchBar
{
    self.resultController.searchKeyword = nil;
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonAction:(UISearchBar *)searchBar
{
    [[RealtimeSearch shared] realtimeSearchStop];
    
    [self.resultController.dataArray removeAllObjects];
    [self.resultController.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.view endEditing:YES];
}

- (void)searchTextDidChangeWithString:(NSString *)aString
{
    self.resultController.searchKeyword = aString;
    
    __weak typeof(self) weakself = self;
    [[RealtimeSearch shared] realtimeSearchWithSource:self.contancts searchText:aString collationStringSelector:nil resultBlock:^(NSArray *results) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakself.resultController.dataArray count] > 0)
                [weakself.resultController.dataArray removeAllObjects];
            [weakself.resultController.dataArray addObjectsFromArray:results];
            [weakself.resultController.tableView reloadData];
        });
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

#pragma mark - personDataAction
- (void)personData:(NSString*)contanct
{
    PersonalDataViewController *controller = [[PersonalDataViewController alloc]initWithNickName:contanct];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - deleteAction
- (void)_deleteContact:(NSString *)aContact
            completion:(void (^)(EMError *aError))aCompletion
{
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].contactManager deleteContact:aContact
                                     isDeleteConversation:YES
                                               completion:^(NSString *aUsername, EMError *aError) {
        [weakself hideHud];
        if (aError) {
            [EMAlertController showErrorAlert:@"删除好友失败"];
        } else {
            [EMAlertController showSuccessAlert:[NSString stringWithFormat:@"您已删除好友%@", aContact]];
        }
        if (aCompletion) {
            aCompletion(aError);
        }
    }];
}

#pragma mark - moreAction
- (void)addAction
{
    [PellTableViewSelect addPellTableViewSelectWithWindowFrame:CGRectMake(self.view.bounds.size.width-100, self.addImageBtn.frame.origin.y, 110, 104) selectData:@[@"找人",@"找群"] images:@[@"icon-添加好友",@"icon-加群"] locationY:30 - (22 - EMVIEWTOPMARGIN) action:^(NSInteger index) {
        if(index == 0) {
            [self lookForSomeOne];
        } else if (index == 1) {
            [self findGroup];
        }
    } animated:YES];
}

//找人
- (void)lookForSomeOne
{
    InviteFriendViewController *controller = [[InviteFriendViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

//找群
- (void)findGroup
{
    JoinGroupViewController *controller = [[JoinGroupViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
