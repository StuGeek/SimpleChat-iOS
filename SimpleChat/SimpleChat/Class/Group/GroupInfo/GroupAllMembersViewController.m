//
//  GroupAllMembersViewController.m
//  SimpleChat
//
//  Created by stugeek on 2021/12/3.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import "GroupAllMembersViewController.h"
#import "GroupMembersViewController.h"
#import "GroupAdminsViewController.h"

@interface GroupAllMembersViewController ()

@property (nonatomic, strong) EMGroup *group;

@end

@implementation GroupAllMembersViewController

- (instancetype)initWithGroup:(EMGroup *)aGroup
{
    self = [super init];
    if (self) {
        _group = aGroup;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    self.showRefreshHeader = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGroupMembersUpdated:) name:GROUP_INFO_UPDATED object:nil];
    // Do any additional setup after loading the view.
}

- (void)initView
{
    [self addPopBackLeftItem];
    self.title = @"群成员";
    self.view.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0];

    self.tableView.scrollEnabled = NO;
    self.tableView.rowHeight = 60;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@130);
    }];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSString *cellIdentifier = @"UITableViewCellValue1";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (section == 0) {
        if (row == 0) {
            cell.textLabel.text = @"群管理员";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"共%lu人",(unsigned long)self.group.adminList.count + 1];
        } else if (row == 1) {
            cell.textLabel.text = @"群成员";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"共%lu人",(self.group.occupantsCount - self.group.adminList.count - 1)];
        }
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0];
    cell.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.001;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        if (row == 0) {
            GroupAdminsViewController *controller = [[GroupAdminsViewController alloc]initWithGroup:self.group];
            [self.navigationController pushViewController:controller animated:YES];
        } else if (row == 1) {
            GroupMembersViewController *controller = [[GroupMembersViewController alloc]initWithGroup:self.group];
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

#pragma mark - MemebersUpdateNoti

- (void)handleGroupMembersUpdated:(NSNotification *)aNotif
{
    EMGroup *group = aNotif.object;
    self.group = group;
    [self.tableView reloadData];
}

@end
