//
//  SecurityViewController.m
//  SimpleChat
//
//  Created by stugeek on 2021/12/3.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import "SecurityViewController.h"
#import "Options.h"
#import "UserInfoStore.h"
#import "SelectAvatarViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SecurityViewController ()

@property (nonatomic, strong) UIImageView *headerView;
@property (nonatomic) EMUserInfo* userInfo;

@end

@implementation SecurityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    [self initView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoUpdated) name:USERINFO_UPDATE object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Subviews

- (void)initView
{
    [self addPopBackLeftItem];
    self.title = @"账号与安全";

    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = kColor_LightGray;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
    self.headerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"defaultAvatar"]];
    self.headerView.frame = CGRectMake(0, 0, 36, 36);
    self.headerView.userInteractionEnabled = YES;
    [self userInfoUpdated];
    if([EMClient sharedClient].currentUsername.length > 0)
        [[UserInfoStore sharedInstance] fetchUserInfosFromServer:@[[EMClient sharedClient].currentUsername]];
}

-(void)userInfoUpdated
{
    dispatch_async(dispatch_get_main_queue(), ^{
        {
            self.userInfo = [[UserInfoStore sharedInstance] getUserInfoById:[EMClient sharedClient].currentUsername];
            if(!self.userInfo) {
                [[[EMClient sharedClient] userInfoManager] fetchUserInfoById:@[[EMClient sharedClient].currentUsername] completion:^(NSDictionary *aUserDatas, EMError *aError) {
                    if(!aError) {
                        self.userInfo = [aUserDatas objectForKey:[EMClient sharedClient].currentUsername];
                        if(self.userInfo) {
                            if(self.userInfo.avatarUrl) {
                                NSURL* url = [NSURL URLWithString:self.userInfo.avatarUrl];
                                [self.headerView sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                        
                                }];
                            }
                        }
                    }
                    
                }];
            }else{
                if(self.userInfo.avatarUrl.length > 0) {
                    NSURL* url = [NSURL URLWithString:self.userInfo.avatarUrl];
                    if(url) {
                        [self.headerView sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                
                        }];
                    }
                }
                
            }
        }
        if(self.view.window)
            [self.tableView reloadData];
    });
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UITableViewCell"];
        cell.detailTextLabel.textColor = [UIColor grayColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSInteger row = indexPath.row;
    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.text = @"";
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (row == 0) {
        cell.textLabel.text = @"昵称";
        if(self.userInfo)
            cell.detailTextLabel.text = self.userInfo.nickName;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (row == 1) {
        cell.textLabel.text = @"邮箱";
        if(self.userInfo)
            cell.detailTextLabel.text = self.userInfo.mail;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (row == 2) {
        cell.textLabel.text = @"联系方式";
        if(self.userInfo)
            cell.detailTextLabel.text = self.userInfo.phone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (row == 3) {
        cell.textLabel.text = @"生日";
        if(self.userInfo)
            cell.detailTextLabel.text = self.userInfo.birth;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if (row == 0) {
        [self changeNikeNameAction];
    } else if (row == 1) {
        [self changeMailAction];
    } else if (row == 2) {
        [self changePhoneAction];
    } else {
        [self changeBirthAction];
    }
    
}

#pragma mark - Action

- (void)_updateNikeName:(NSString *)aName
{
    //设置推送设置
    [self showHint:@"修改昵称..."];
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].pushManager updatePushDisplayName:aName completion:^(NSString * _Nonnull aDisplayName, EMError * _Nonnull aError) {
        if (!aError) {
            if (weakself.updateAPNSNicknameCompletion) {
                weakself.updateAPNSNicknameCompletion();
            }
            [weakself.tableView reloadData];
            [weakself hideHud];
        } else {
            [EMAlertController showErrorAlert:aError.errorDescription];
        }
    }];
    [[[EMClient sharedClient] userInfoManager] updateOwnUserInfo:aName withType:EMUserInfoTypeNickName completion:^(EMUserInfo* aUserInfo,EMError *aError) {
            if(!aError) {
                [[UserInfoStore sharedInstance] setUserInfo:aUserInfo forId:[EMClient sharedClient].currentUsername];
                [[NSNotificationCenter defaultCenter] postNotificationName:USERINFO_UPDATE  object:nil];
            }else{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [weakself showHint:[NSString stringWithFormat:@"修改昵称失败：%@",aError.errorDescription]];
                });
            }
            }];
}

- (void)_updateMail:(NSString *)aMail
{
    //设置推送设置
    [self showHint:@"修改邮箱..."];
    __weak typeof(self) weakself = self;
    [[[EMClient sharedClient] userInfoManager] updateOwnUserInfo:aMail withType:EMUserInfoTypeMail completion:^(EMUserInfo* aUserInfo,EMError *aError) {
            if(!aError) {
                [[UserInfoStore sharedInstance] setUserInfo:aUserInfo forId:[EMClient sharedClient].currentUsername];
                [[NSNotificationCenter defaultCenter] postNotificationName:USERINFO_UPDATE  object:nil];
            }else{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [weakself showHint:[NSString stringWithFormat:@"修改邮箱失败：%@",aError.errorDescription]];
                });
            }
            }];
}

- (void)_updatePhone:(NSString *)aPhone
{
    //设置推送设置
    [self showHint:@"修改联系方式..."];
    __weak typeof(self) weakself = self;
    [[[EMClient sharedClient] userInfoManager] updateOwnUserInfo:aPhone withType:EMUserInfoTypePhone completion:^(EMUserInfo* aUserInfo,EMError *aError) {
            if(!aError) {
                [[UserInfoStore sharedInstance] setUserInfo:aUserInfo forId:[EMClient sharedClient].currentUsername];
                [[NSNotificationCenter defaultCenter] postNotificationName:USERINFO_UPDATE  object:nil];
            }else{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [weakself showHint:[NSString stringWithFormat:@"修改联系方式失败：%@",aError.errorDescription]];
                });
            }
            }];
}

- (void)_updateBirth:(NSString *)aBirth
{
    //设置推送设置
    [self showHint:@"修改生日..."];
    __weak typeof(self) weakself = self;
    [[[EMClient sharedClient] userInfoManager] updateOwnUserInfo:aBirth withType:EMUserInfoTypeBirth completion:^(EMUserInfo* aUserInfo,EMError *aError) {
            if(!aError) {
                [[UserInfoStore sharedInstance] setUserInfo:aUserInfo forId:[EMClient sharedClient].currentUsername];
                [[NSNotificationCenter defaultCenter] postNotificationName:USERINFO_UPDATE  object:nil];
            }else{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [weakself showHint:[NSString stringWithFormat:@"修改生日失败：%@",aError.errorDescription]];
                });
            }
            }];
}

- (void)changeNikeNameAction
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"更改昵称" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"请输入昵称";
        if(self.userInfo)
            textField.text = self.userInfo.nickName;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:cancelAction];
    
    __weak typeof(self) weakself = self;
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = alertController.textFields.firstObject;
        [weakself _updateNikeName:textField.text];
    }];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)changeMailAction
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"更改邮箱" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"请输入邮箱";
        if(self.userInfo)
            textField.text = self.userInfo.mail;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:cancelAction];
    
    __weak typeof(self) weakself = self;
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = alertController.textFields.firstObject;
        [weakself _updateMail:textField.text];
    }];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)changePhoneAction
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"更改联系方式" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"请输入联系方式";
        if(self.userInfo)
            textField.text = self.userInfo.phone;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:cancelAction];
    
    __weak typeof(self) weakself = self;
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = alertController.textFields.firstObject;
        [weakself _updatePhone:textField.text];
    }];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)changeBirthAction
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"更改生日" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"请输入生日";
        if(self.userInfo)
            textField.text = self.userInfo.phone;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:cancelAction];
    
    __weak typeof(self) weakself = self;
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = alertController.textFields.firstObject;
        [weakself _updateBirth:textField.text];
    }];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end

