//
//  GroupInfoViewController.h
//  SimpleChat
//
//  Created by stugeek on 2021/12/3.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import "EMRefreshTableViewController.h"
#import "EMRefreshViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface GroupInfoViewController : EMRefreshViewController

@property (nonatomic, copy) void (^leaveOrDestroyCompletion)(void);

- (instancetype)initWithConversation:(EMConversation *)aConversation;

@property (nonatomic, copy) void (^clearRecordCompletion)(BOOL isClearRecord);

@end

NS_ASSUME_NONNULL_END
