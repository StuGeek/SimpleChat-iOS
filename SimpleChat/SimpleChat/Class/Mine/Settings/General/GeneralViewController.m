//
//  GeneralViewController.m
//  SimpleChat
//
//  Created by stugeek on 2021/12/3.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import "GeneralViewController.h"

#import "Options.h"

@interface GeneralViewController ()

@property (nonatomic, strong) NSString *logPath;

@property (nonatomic, strong) UISwitch *disturbSwitch;

@end

@implementation GeneralViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showRefreshHeader = NO;
    // Uncomment the following line to preserve selection between presentations.
    [self initView];
}

#pragma mark - Subviews

- (void)initView
{
    [self addPopBackLeftItem];
    self.title = @"通用";
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
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
        case 1:
            return 1;
        case 2:
            return 2;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSString *cellIdentifier = @"UITableViewCellSwitch";
    
    UISwitch *switchControl = nil;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 65, 20, 50, 40)];
        switchControl.tag = [self _tagWithIndexPath:indexPath];
        [switchControl addTarget:self action:@selector(cellSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:switchControl];
    }
    
    Options *options = [Options sharedOptions];
    
    cell.detailTextLabel.text = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;

    if (section == 0) {
        cell.textLabel.text = @"放大字体（关怀模式）";
        [switchControl setOn:options.isEnlargerFontMode animated:YES];
    } else if (section == 1) {
        cell.textLabel.text = @"显示输入状态";
        [switchControl setOn:options.isChatTyping animated:YES];
    } else if (section == 2) {
        if (row == 0) {
            cell.textLabel.text = @"自动接受群组邀请";
            [switchControl setOn:options.isAutoAcceptGroupInvitation animated:YES];
        } else if (row == 1) {
            cell.textLabel.text = @"退出群组时删除会话";
            [switchControl setOn:[EMClient sharedClient].options.isDeleteMessagesWhenExitGroup animated:YES];
        }
    }
    cell.textLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    
    Options *option = [Options sharedOptions];
    if (!option.isEnlargerFontMode) {
        cell.textLabel.font = [UIFont systemFontOfSize:14];
    }
    else {
        cell.textLabel.font = [UIFont systemFontOfSize:22];
    }
    cell.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.001;
    }
    if (section == 2) {
        return 46;
    }
    return 16;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 2) {
        UILabel *label = [[UILabel alloc] init];
        Options *option = [Options sharedOptions];
        if (!option.isEnlargerFontMode) {
            label.font = [UIFont systemFontOfSize:14];
        }
        else {
            label.font = [UIFont systemFontOfSize:24];
        }
        label.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        label.text = @"     群组设置";
        label.textAlignment = NSTextAlignmentLeft;
        return label;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
}

#pragma mark - Private

- (NSInteger)_tagWithIndexPath:(NSIndexPath *)aIndexPath
{
    NSInteger tag = aIndexPath.section * 10 + aIndexPath.row;
    return tag;
}

- (NSIndexPath *)_indexPathWithTag:(NSInteger)aTag
{
    NSInteger section = aTag / 10;
    NSInteger row = aTag % 10;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    return indexPath;
}

#pragma mark - Action

- (void)cellSwitchValueChanged:(UISwitch *)aSwitch
{
    Options *options = [Options sharedOptions];
    NSIndexPath *indexPath = [self _indexPathWithTag:aSwitch.tag];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        options.isEnlargerFontMode = aSwitch.isOn;
        [[Options sharedOptions] archive];
        if (aSwitch.isOn) {
            self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: UIColor.blackColor, NSFontAttributeName : [UIFont systemFontOfSize:28]};
        }
        else {
            self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: UIColor.blackColor, NSFontAttributeName : [UIFont systemFontOfSize:18]};
        }
        [self.tableView reloadData];
    } else if (section == 1) {
        options.isChatTyping = aSwitch.isOn;
        [[Options sharedOptions] archive];
    } else if (section == 2) {
        if (row == 0) {
            [EMClient sharedClient].options.isAutoAcceptGroupInvitation = aSwitch.isOn;
            options.isAutoAcceptGroupInvitation = aSwitch.isOn;
            [options archive];
        } else if (row == 1) {
            [[EMClient sharedClient].options setIsDeleteMessagesWhenExitGroup:aSwitch.isOn];
        }
    }
}

@end
