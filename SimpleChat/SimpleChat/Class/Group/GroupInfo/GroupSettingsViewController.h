//
//  GroupSettingsViewController.h
//  SimpleChat
//
//  Created by stugeek on 2021/12/3.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import "EMRefreshTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface GroupSettingsViewController : EMRefreshTableViewController

- (instancetype)initWithGroup:(EMGroup *)aGroup;

@end

NS_ASSUME_NONNULL_END
