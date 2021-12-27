//
//  AccountViewController.h
//  SimpleChat
//
//  Created by stugeek on 2021/12/3.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AccountViewController : UITableViewController

@property (nonatomic, copy) void (^updateAPNSNicknameCompletion)(void);

@end

NS_ASSUME_NONNULL_END
