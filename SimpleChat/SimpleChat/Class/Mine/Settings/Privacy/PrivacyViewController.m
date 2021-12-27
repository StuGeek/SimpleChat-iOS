//
//  PrivacyViewController.m
//  SimpleChat
//
//  Created by stugeek on 2021/12/3.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import "PrivacyViewController.h"
#import "BlacklistViewController.h"

@interface PrivacyViewController ()

@end

@implementation PrivacyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    self.showRefreshHeader = NO;
    // Do any additional setup after loading the view.
}

- (void)initView
{
    [self addPopBackLeftItem];
    self.title = @"隐私";
    self.view.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0];

    self.tableView.scrollEnabled = NO;
    self.tableView.rowHeight = 66;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@70);
    }];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UITableViewCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (section == 0) {
        cell.textLabel.text = @"黑名单";
    }
    Options *options = [Options sharedOptions];
    if (!options.isEnlargerFontMode) {
        cell.textLabel.font = [UIFont systemFontOfSize:14];
    }
    else {
        cell.textLabel.font = [UIFont systemFontOfSize:24];
    }
    
    cell.textLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
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
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    if (section == 0) {
        BlacklistViewController *controller = [[BlacklistViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    }
}
@end
