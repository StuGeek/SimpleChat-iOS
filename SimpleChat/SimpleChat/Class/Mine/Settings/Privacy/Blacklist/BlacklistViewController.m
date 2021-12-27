//
//  BlacklistViewController.m
//  SimpleChat
//
//  Created by stugeek on 2021/12/3.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import "BlacklistViewController.h"

#import "RealtimeSearch.h"

#import "EMAvatarNameCell+UserInfo.h"
#import "AddBlacklistViewController.h"
#import "UserInfoStore.h"

@interface BlacklistViewController ()<EMAvatarNameCellDelegate>

@property (nonatomic, strong) NSArray *blacklist;

@end

@implementation BlacklistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView) name:USERINFO_UPDATE object:nil];
    
    [self initView];
    [self tableViewDidTriggerHeaderRefresh];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReloadBlacklist:) name:CONTACT_BLACKLIST_RELOAD object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Subviews

- (void)initView
{
    [self addPopBackLeftItem];
    self.title = @"黑名单";
    Options *options = [Options sharedOptions];
    if (!options.isEnlargerFontMode) {
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: UIColor.blackColor, NSFontAttributeName : [UIFont systemFontOfSize:18]};
    }
    else {
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: UIColor.blackColor, NSFontAttributeName : [UIFont systemFontOfSize:28]};
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.showRefreshHeader = YES;
    self.tableView.rowHeight = 66;
    self.tableView.tableFooterView = [[UIView alloc] init];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView)
        return [(NSArray *)self.dataArray count];
    
    return [self.searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EMAvatarNameCell *cell = (EMAvatarNameCell *)[tableView dequeueReusableCellWithIdentifier:@"EMAvatarNameCell"];
    // Configure the cell...
    if (cell == nil) {
        cell = [[EMAvatarNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EMAvatarNameCell"];
    }

    cell.indexPath = indexPath;
    if (tableView == self.tableView) {
        cell.avatarView.image = [UIImage imageNamed:@"defaultAvatar"];
        cell.nameLabel.text = [self.dataArray objectAtIndex:indexPath.row];
        cell.nameLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
        cell.nameLabel.font = [UIFont systemFontOfSize:18.f];
        [cell refreshUserInfo:[self.dataArray objectAtIndex:indexPath.row]];
        return cell;
    }
    cell.avatarView.image = [UIImage imageNamed:@"defaultAvatar"];
    cell.nameLabel.text = [self.searchResults objectAtIndex:indexPath.row];
    [cell refreshUserInfo:[self.searchResults objectAtIndex:indexPath.row]];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //在iOS8.0上，必须加上这个方法才能出发左划操作
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *username = nil;
        NSInteger row = indexPath.row;
        if (tableView == self.tableView) {
            username = [self.dataArray objectAtIndex:row];
        } else {
            username = [self.searchResults objectAtIndex:row];
        }
        
        if ([username length] == 0) {
            return;
        }
        
        [self showHudInView:self.view hint:@"移除黑名单..."];
        __weak typeof(self) weakself = self;
        [[EMClient sharedClient].contactManager removeUserFromBlackList:username completion:^(NSString *aUsername, EMError *aError) {
            [weakself hideHud];
            if (aError) {
                [EMAlertController showErrorAlert:aError.errorDescription];
            } else {
                [EMAlertController showSuccessAlert:@"已将用户移出黑名单"];
                [[NSNotificationCenter defaultCenter] postNotificationName:CONTACT_BLACKLIST_UPDATE object:nil];
                if (tableView != weakself.tableView) {
                    [self.searchResults removeObject:username];
                    [tableView reloadData];
                }
                [weakself loadBlacklistFromDB];
            }
        }];
    }
}

- (void)refreshTableView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.view.window)
            [self.tableView reloadData];
    });
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

#pragma mark - EMSearchBarDelegate

- (void)searchTextDidChangeWithString:(NSString *)aString
{
    __weak typeof(self) weakself = self;
    [[RealtimeSearch shared] realtimeSearchWithSource:self.blacklist searchText:aString collationStringSelector:nil resultBlock:^(NSArray *results) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (results.count <= 0) {
                [weakself showHint:@"黑名单无该用户"];
                return;
            }
            [weakself.searchResults removeAllObjects];
            [weakself.searchResults addObjectsFromArray:results];
            [weakself.searchResultTableView reloadData];
        });
    }];
}

#pragma mark - NSNotification

- (void)handleReloadBlacklist:(NSNotification *)aNotif
{
    [[NSNotificationCenter defaultCenter] postNotificationName:CONTACT_BLACKLIST_UPDATE object:nil];
    [self loadBlacklistFromDB];
}

#pragma mark - Data
- (void)tableViewDidTriggerHeaderRefresh
{
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].contactManager getBlackListFromServerWithCompletion:^(NSArray *aList, EMError *aError) {
        if (!aError) {
            weakself.blacklist = aList;
            [weakself.dataArray removeAllObjects];
            if ([aList count] > 0) {
                [weakself.dataArray addObjectsFromArray:aList];
            }
            [weakself.tableView reloadData];
        }
        
        [weakself tableViewDidFinishTriggerHeader:YES reload:NO];
    }];
}

- (void)loadBlacklistFromDB
{
    self.blacklist = [[EMClient sharedClient].contactManager getBlackList];
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:self.blacklist];
    [self.tableView reloadData];
}

@end
