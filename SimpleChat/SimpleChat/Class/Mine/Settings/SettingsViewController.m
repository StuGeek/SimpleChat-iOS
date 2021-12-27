//
//  SettingsViewController.m
//  SimpleChat
//
//  Created by stugeek on 2021/12/3.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import "SettingsViewController.h"
#import "SecurityViewController.h"
#import "GeneralViewController.h"
#import "MsgRemindViewController.h"
#import "PrivacyViewController.h"

@interface SettingsViewController ()
@property(nonatomic, strong) UIAlertController *alertController;
@property(nonatomic, strong) UILabel *logoutLabel;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    self.showRefreshHeader = NO;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initView];
    self.showRefreshHeader = NO;
    [self.tableView reloadData];
}

#pragma mark - Subviews

- (void)initView
{
    [self addPopBackLeftItem];
    self.title = @"设置";
    
    Options *options = [Options sharedOptions];
    if (!options.isEnlargerFontMode) {
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: UIColor.blackColor, NSFontAttributeName : [UIFont systemFontOfSize:18]};
    }
    else {
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: UIColor.blackColor, NSFontAttributeName : [UIFont systemFontOfSize:28]};
    }
    
    self.view.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0];
    
    self.tableView.rowHeight = 66;
    self.tableView.backgroundColor = kColor_LightGray;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    self.tableView.scrollEnabled = NO;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 2) {
        return 1;
    }
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellStyleValue1"];
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UITableViewCellStyleValue1"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [cell setSeparatorInset:UIEdgeInsetsMake(0, 16, 0, 16)];
    cell.textLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];

    if (section == 0) {
        if (row == 0) {
            cell.textLabel.text = @"账号与安全";
        } else if (row == 1) {
            cell.textLabel.text = @"新消息提醒";
        }
    } else if (section == 1) {
        if (row == 0) {
            cell.textLabel.text = @"通用";
        } else if (row == 1) {
            cell.textLabel.text = @"隐私";
        }
    } else if (section == 2) {
        if (self.logoutLabel == nil) {
            self.logoutLabel = [[UILabel alloc]init];
            self.logoutLabel.text = @"退出";
            self.logoutLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
            [cell.contentView addSubview:self.logoutLabel];
            [self.logoutLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(cell.contentView);
            }];
            cell.accessoryType = UITableViewCellSelectionStyleNone;
        }
    }
    Options *options = [Options sharedOptions];
    if (!options.isEnlargerFontMode) {
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        self.logoutLabel.font = [UIFont systemFontOfSize:16];
    }
    else {
        cell.textLabel.font = [UIFont systemFontOfSize:26];
        self.logoutLabel.font = [UIFont systemFontOfSize:26];
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        if (row == 0) {
            SecurityViewController *securityController = [[SecurityViewController alloc]init];
            [self.navigationController pushViewController:securityController animated:YES];
        } else if (row == 1) {
            MsgRemindViewController *msgRemindController = [[MsgRemindViewController alloc]init];
            [self.navigationController pushViewController:msgRemindController animated:YES];
        }
    } else if (section == 1) {
        if (row == 0) {
            GeneralViewController *generalController = [[GeneralViewController alloc]init];
            [self.navigationController pushViewController:generalController animated:YES];
        } else if (row == 1) {
            PrivacyViewController *securityPrivacyController = [[PrivacyViewController alloc]init];
            [self.navigationController pushViewController:securityPrivacyController animated:YES];
        }
    } else {
        [self logoutAction];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.001;
    }
    return 16;
}

#pragma mark - Action

 - (void)logoutAction
 {
     __weak typeof(self) weakself = self;
     [self showHudInView:self.view hint:@"退出..."];
     [[EMClient sharedClient] logout:YES completion:^(EMError *aError) {
         [weakself hideHud];
         if (aError) {
             [EMAlertController showErrorAlert:aError.errorDescription];
         } else {
             Options *options = [Options sharedOptions];
             options.isAutoLogin = NO;
             options.loggedInUsername = @"";
             [options archive];
             [[NSNotificationCenter defaultCenter] postNotificationName:ACCOUNT_LOGIN_CHANGED object:@NO];
         }
     }];
 }

@end
