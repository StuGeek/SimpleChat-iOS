//
//  MineViewController.m
//  SimpleChat
//
//  Created by stugeek on 2021/12/3.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import "MineViewController.h"

#import "EMAvatarNameCell+UserInfo.h"

#import "AccountViewController.h"
#import "SecurityViewController.h"
#import "SettingsViewController.h"
#import "AboutViewController.h"
#import "UserInfoStore.h"

@interface MineViewController ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) EMAvatarNameCell *userCell;
@property (nonatomic, strong) UIButton *suspendCardBtn;
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UILabel *funLabel;

@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoUpdated) name:USERINFO_UPDATE object:nil];
    self.showRefreshHeader = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initView];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.window = nil;
    self.backView = nil;
    self.navigationController.navigationBarHidden = NO;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Subviews

- (void)initView
{
    UIColor* lightBlue=[UIColor colorWithRed:220.0f/255.0f green:236.0f/255.0f blue:250.0f/255.0f alpha:0.5];
    self.view.backgroundColor = lightBlue;
    
    if (self.titleLabel == nil) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.text = @"我";
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.font = [UIFont systemFontOfSize:18];
        [self.view addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(self.view).offset(EMVIEWTOPMARGIN + 35);
            make.height.equalTo(@25);
        }];
    }
    
    self.userCell = [[EMAvatarNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EMAvatarNameCell"];
    self.userCell.selectionStyle = UITableViewCellSelectionStyleNone;
    self.userCell.accessoryType = UITableViewCellAccessoryNone;
    self.userCell.nameLabel.font = [UIFont systemFontOfSize:18];
    self.userCell.detailLabel.font = [UIFont systemFontOfSize:15];
    self.userCell.detailLabel.textColor = [UIColor grayColor];
    self.userCell.avatarView.image = [UIImage imageNamed:@"defaultAvatar"];
    self.userCell.nameLabel.text = [EMClient sharedClient].currentUsername;
    //self.userCell.detailLabel.text = [EMClient sharedClient].pushManager.pushOptions.displayName;
    [self userInfoUpdated];
    [self.userCell.avatarView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.userCell.contentView.mas_left).offset(28);
        make.centerY.equalTo(self.userCell.contentView);
        make.width.height.equalTo(@50);
    }];
    
    self.tableView.backgroundColor = lightBlue;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.scrollEnabled = NO;
    self.tableView.tableFooterView = [[UIView alloc] init];

    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(15);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    EMUserInfo* userInfo = [[UserInfoStore sharedInstance] getUserInfoById:[EMClient sharedClient].currentUsername];
    if(!userInfo && [EMClient sharedClient].currentUsername.length > 0) {
        [[UserInfoStore sharedInstance] fetchUserInfosFromServer:@[[EMClient sharedClient].currentUsername]];
    }else{
        [self userInfoUpdated];
    }
}

-(void)userInfoUpdated
{
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        {
            if(weakself.view.window) {
                [weakself.userCell refreshUserInfo:[EMClient sharedClient].currentUsername];
                [weakself.tableView reloadData];
            }
        }
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    switch (section) {
        case 0:
            count = 1;
            break;
        case 1:
            count = 2;
            break;
        default:
            break;
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    UIImageView *imgView = [[UIImageView alloc]init];
    [cell.contentView addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(cell.contentView);
        make.left.equalTo(cell.contentView).offset(20);
        make.width.height.equalTo(@30);
    }];
    self.funLabel = [[UILabel alloc]init];
    self.funLabel.userInteractionEnabled = NO;
    [cell.contentView addSubview:self.funLabel];
    [self.funLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imgView.mas_right).offset(18);
        make.centerY.equalTo(cell.contentView);
    }];
    
    if (section == 0) {
        if (row == 0) {
            return self.userCell;
        }
    }
    if (section == 1) {
        if (row == 0) {
            imgView.image = [UIImage imageNamed:@"settings"];
            self.funLabel.text = @"设置";
        } else if (row == 1) {
            imgView.image = [UIImage imageNamed:@"aboutSimpleChat"];
            self.funLabel.text = @"关于SimpleChat";
        }
    }
    self.funLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    self.funLabel.textAlignment = NSTextAlignmentLeft;
    Options *options = [Options sharedOptions];
    if (!options.isEnlargerFontMode) {
        self.titleLabel.font = [UIFont systemFontOfSize:18];
        self.funLabel.font = [UIFont systemFontOfSize:14.0];
    }
    else {
        self.titleLabel.font = [UIFont systemFontOfSize:28];
        self.funLabel.font = [UIFont systemFontOfSize:24.0];
    }
    cell.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) return 70;
    return 66;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) return 0;
    return 16;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    __weak typeof(self) weakself = self;
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        if (row == 0) {
            AccountViewController *controller = [[AccountViewController alloc] initWithStyle:UITableViewStyleGrouped];
            [controller setUpdateAPNSNicknameCompletion:^{
                weakself.userCell.detailLabel.text = [EMClient sharedClient].pushManager.pushOptions.displayName;
                [weakself.tableView reloadData];
            }];
            [self.navigationController pushViewController:controller animated:YES];
        }
    } else if (section == 1) {
        if (row == 0) {
            SettingsViewController *settingsController = [[SettingsViewController alloc]init];
            [self.navigationController pushViewController:settingsController animated:YES];
        } else if (row == 1) {
            AboutViewController *aboutHuanXin = [[AboutViewController alloc]init];
            [self.navigationController pushViewController:aboutHuanXin animated:YES];
        }
    }
}

#pragma mark - scrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        CGRect rectInTableView = [self.tableView rectForRowAtIndexPath:indexPath];
        CGRect rectInSuperview = [self.tableView convertRect:rectInTableView toView:[self.tableView superview]];
        if (rectInSuperview.origin.y < 70) {
            self.backView.alpha = 0.7;
        } else {
            self.backView.alpha = 1.0;
        }
    }
}

@end
