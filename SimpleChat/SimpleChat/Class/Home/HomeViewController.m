//
//  HomeViewController.m
//  SimpleChat
//
//  Created by stugeek on 2021/12/3.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import "HomeViewController.h"
#import "ConversationsViewController.h"
#import "ContactsViewController.h"
#import "ShareViewController.h"
#import "MineViewController.h"
#import "RemindManager.h"

#define kTabbarItemTag_Conversation 0
#define kTabbarItemTag_Contact 1
#define kTabbarItemTag_Settings 2
#define kTabbarItemTag_Sharing 3

@interface HomeViewController ()<UITabBarDelegate, EMChatManagerDelegate, EaseIMKitManagerDelegate>

@property (nonatomic) BOOL isViewAppear;

@property (nonatomic, strong) UITabBar *tabBar;
@property (strong, nonatomic) NSArray *viewControllers;

@property (nonatomic, strong) ConversationsViewController *conversationsController;
@property (nonatomic, strong) ContactsViewController *contactsController;
@property (nonatomic, strong) MineViewController *mineController;
@property (nonatomic, strong) ShareViewController *shareController;
@property (nonatomic, strong) UIView *addView;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
    
    //监听消息接收，主要更新会话tabbaritem的badge
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    [EaseIMKitManager.shared addDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    self.isViewAppear = YES;
    [self _loadConversationTabBarItemBadge];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.isViewAppear = NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)dealloc
{
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [EaseIMKitManager.shared removeDelegate:self];
}

#pragma mark - Subviews

- (void)initView
{
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        [self setEdgesForExtendedLayout: UIRectEdgeNone];
    }
    UIColor* lightBlue=[UIColor colorWithRed:220.0f/255.0f green:236.0f/255.0f blue:250.0f/255.0f alpha:0.5];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tabBar = [[UITabBar alloc] init];
    self.tabBar.delegate = self;
    self.tabBar.translucent = NO;
    [self.tabBar setBackgroundColor:lightBlue];
    //self.tabBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tabBar];
    [self.tabBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-EMVIEWBOTTOMMARGIN);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.height.mas_equalTo(50);
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    [self.tabBar addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tabBar.mas_top);
        make.left.equalTo(self.tabBar.mas_left);
        make.right.equalTo(self.tabBar.mas_right);
        make.height.equalTo(@1);
    }];
    
    [self _setupChildController];
}

- (UITabBarItem *)_setupTabBarItemWithTitle:(NSString *)aTitle
                                    imgName:(NSString *)aImgName
                            selectedImgName:(NSString *)aSelectedImgName
                                        tag:(NSInteger)aTag
{
    UITabBarItem *retItem = [[UITabBarItem alloc] initWithTitle:aTitle image:[UIImage imageNamed:aImgName] selectedImage:[UIImage imageNamed:aSelectedImgName]];
    retItem.tag = aTag;
    [retItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIFont systemFontOfSize:14], NSFontAttributeName, [UIColor lightGrayColor],NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [retItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:13], NSFontAttributeName, kColor_Blue, NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    return retItem;
}

- (void)_setupChildController
{
    __weak typeof(self) weakself = self;
    self.conversationsController = [[ConversationsViewController alloc]init];
    [self.conversationsController setDeleteConversationCompletion:^(BOOL isDelete) {
        if (isDelete) {
            [weakself _loadConversationTabBarItemBadge];
        }
    }];
    UITabBarItem *consItem = [self _setupTabBarItemWithTitle:@"会话" imgName:@"icon_dialog_unselected" selectedImgName:@"icon_dialog" tag:kTabbarItemTag_Conversation];
    self.conversationsController.tabBarItem = consItem;
    [self addChildViewController:self.conversationsController];
    
    self.contactsController = [[ContactsViewController alloc]init];
    UITabBarItem *contItem = [self _setupTabBarItemWithTitle:@"通讯录" imgName:@"icon_address_book_unselected" selectedImgName:@"icon_address_book" tag:kTabbarItemTag_Contact];
    self.contactsController.tabBarItem = contItem;
    [self addChildViewController:self.contactsController];
    
    //UITabBarItem *shareItem = [self _setupTabBarItemWithTitle:@"分享" imgName:@"icon_share_unselected" selectedImgName:@"icon_share" tag:kTabbarItemTag_Settings];
    self.shareController = [[ShareViewController alloc]init];
    UITabBarItem *shareItem = [self _setupTabBarItemWithTitle:@"分享生活" imgName:@"icon_share_unselected" selectedImgName:@"icon_share" tag:kTabbarItemTag_Sharing];
    self.shareController.tabBarItem = shareItem;
    [self addChildViewController:self.shareController];
    
    self.mineController = [[MineViewController alloc] init];
    UITabBarItem *mineItem = [self _setupTabBarItemWithTitle:@"我" imgName:@"icon_me_unselected" selectedImgName:@"icon_me" tag:kTabbarItemTag_Settings];
    self.mineController.tabBarItem = mineItem;
    [self addChildViewController:self.mineController];
    
    self.viewControllers = @[self.conversationsController, self.contactsController, self.mineController];
    
    [self.tabBar setItems:@[consItem, contItem, shareItem, mineItem]];
    
    self.tabBar.selectedItem = consItem;
    [self tabBar:self.tabBar didSelectItem:consItem];
}

#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    NSInteger tag = item.tag;
    UIView *tmpView = nil;
    if (tag == kTabbarItemTag_Conversation)
        tmpView = self.conversationsController.view;
    if (tag == kTabbarItemTag_Contact)
        tmpView = self.contactsController.view;
    if (tag == kTabbarItemTag_Settings)
        tmpView = self.mineController.view;
    if (tag == kTabbarItemTag_Sharing)
        tmpView = self.shareController.view;
    
    if (self.addView == tmpView) {
        return;
    } else {
        [self.addView removeFromSuperview];
        self.addView = nil;
    }
    
    self.addView = tmpView;
    if (self.addView) {
        [self.view addSubview:self.addView];
        [self.addView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.bottom.equalTo(self.tabBar.mas_top);
        }];
    }
}

#pragma mark - EMChatManagerDelegate

- (void)messagesDidReceive:(NSArray *)aMessages
{
    for (EMMessage *msg in aMessages) {
        if (msg.body.type == EMMessageBodyTypeText && [((EMTextMessageBody *)msg.body).text isEqualToString:EMCOMMUNICATE_CALLINVITE]) {
            //通话邀请
            EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:msg.conversationId type:EMConversationTypeGroupChat createIfNotExist:YES];
            if ([((EMTextMessageBody *)msg.body).text isEqualToString:EMCOMMUNICATE_CALLINVITE]) {
                [conversation deleteMessageWithId:msg.messageId error:nil];
                continue;
            }
        }
    }
    if (self.isViewAppear) {
        [self _loadConversationTabBarItemBadge];
    }
}

//　收到已读回执
- (void)messagesDidRead:(NSArray *)aMessages
{
    [self _loadConversationTabBarItemBadge];
}

- (void)conversationListDidUpdate:(NSArray *)aConversationList
{
    [self _loadConversationTabBarItemBadge];
}

- (void)onConversationRead:(NSString *)from to:(NSString *)to
{
    [self _loadConversationTabBarItemBadge];
}

#pragma mark - EaseIMKitManagerDelegate

- (void)conversationsUnreadCountUpdate:(NSInteger)unreadCount
{
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakself.conversationsController.tabBarItem.badgeValue = unreadCount > 0 ? @(unreadCount).stringValue : nil;
    });
    [RemindManager updateApplicationIconBadgeNumber:unreadCount];
}

#pragma mark - Private

- (void)_loadConversationTabBarItemBadge
{
    NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
    NSInteger unreadCount = 0;
    for (EMConversation *conversation in conversations) {
        unreadCount += conversation.unreadMessagesCount;
    }
    self.conversationsController.tabBarItem.badgeValue = unreadCount > 0 ? @(unreadCount).stringValue : nil;
    [RemindManager updateApplicationIconBadgeNumber:unreadCount];
}

@end
