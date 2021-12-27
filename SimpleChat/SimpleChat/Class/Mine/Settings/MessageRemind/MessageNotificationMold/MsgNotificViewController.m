//
//  MsgNotificViewController.m
//  SimpleChat
//
//  Created by stugeek on 2021/12/3.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import "MsgNotificViewController.h"

@interface MsgNotificViewController ()
@property (nonatomic, strong) UISwitch *msgRemindSwitch;
@property (nonatomic, strong) UISwitch *msgShowSwitch;
@end

@implementation MsgNotificViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showRefreshHeader = NO;
    // Uncomment the following line to preserve selection between presentations.
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

#pragma mark - Subviews

- (void)initView
{
    [self addPopBackLeftItem];
    self.title = @"显示消息设置";
    self.view.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0];
    
    self.tableView.scrollEnabled = NO;
    self.tableView.rowHeight = 66;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = kColor_LightGray;
    self.tableView.scrollEnabled = NO;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    self.msgRemindSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 65, 20, 50, 40)];
    [self.msgRemindSwitch addTarget:self action:@selector(showSimpleBanner) forControlEvents:UIControlEventValueChanged];
    
    self.msgShowSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 65, 50, 50, 40)];
    [self.msgShowSwitch addTarget:self action:@selector(showMessageSummary) forControlEvents:UIControlEventValueChanged];
    
    [self.msgRemindSwitch setOn:[EMClient sharedClient].pushManager.pushOptions.displayStyle == EMPushDisplayStyleSimpleBanner animated:YES];
    [self.msgShowSwitch setOn:[EMClient sharedClient].pushManager.pushOptions.displayStyle == EMPushDisplayStyleMessageSummary animated:YES];
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
    NSString *cellIdentifier = @"UITableViewCellSwitch";
    if (section == 0 && row == 1) {
        cellIdentifier = @"UITableViewCellValue1";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.detailTextLabel.text = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;

    if (section == 0) {
        if (row == 0) {
            cell.textLabel.text = @"仅未读提示";
            cell.accessoryView = self.msgRemindSwitch;
        } else if (row == 1) {
            cell.textLabel.text = @"详细信息";
            cell.accessoryView = self.msgShowSwitch;
        }
    }
    cell.textLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    Options *options = [Options sharedOptions];
    if (!options.isEnlargerFontMode) {
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    }
    else {
        cell.textLabel.font = [UIFont systemFontOfSize:24];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:24];
    }
    cell.detailTextLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    cell.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 46;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        UILabel *label = [[UILabel alloc] init];
        Options *options = [Options sharedOptions];
        if (!options.isEnlargerFontMode) {
            label.font = [UIFont systemFontOfSize:14];
        }
        else {
            label.font = [UIFont systemFontOfSize:24];
        }
        label.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        label.text = @"     显示消息设置";
        label.textAlignment = NSTextAlignmentLeft;
        return label;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if (row == 1) {
        MsgNotificViewController *controller = [[MsgNotificViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
}

- (void)msgRemindValueChanged
{
    [self _updatePushStyle:EMPushDisplayStyleSimpleBanner];
    [self.tableView reloadData];
}

- (void)showSimpleBanner
{
    [self _updatePushStyle:EMPushDisplayStyleSimpleBanner];
    [self.msgRemindSwitch setOn:true animated:YES];
    [self.msgShowSwitch setOn:false animated:YES];
    [self.tableView reloadData];
}

- (void)showMessageSummary
{
    [self _updatePushStyle:EMPushDisplayStyleMessageSummary];
    [self.msgRemindSwitch setOn:false animated:YES];
    [self.msgShowSwitch setOn:true animated:YES];
    [self.tableView reloadData];
}

- (void)_updatePushStyle:(EMPushDisplayStyle)aStyle
{
    void (^block)(EMError *aError) = ^(EMError *aError) {
    };
    [[EMClient sharedClient].pushManager updatePushDisplayStyle:aStyle completion:block];
}

@end

