//
//  MsgTranspondViewController.h
//  SimpleChat
//
//  Created by stugeek on 2021/12/2.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import "EMRefreshTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MsgTranspondViewController : EMRefreshTableViewController

@property (nonatomic, copy) void (^doneCompletion)(NSString *aUsername);

@end

NS_ASSUME_NONNULL_END
