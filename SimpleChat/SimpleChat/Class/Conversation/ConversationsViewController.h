//
//  ConversationsViewController.h
//  SimpleChat
//
//  Created by stugeek on 2021/12/2.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import "EMRefreshViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface ConversationsViewController : EMRefreshViewController

@property (nonatomic, copy) void (^deleteConversationCompletion)(BOOL isDelete);

@end

NS_ASSUME_NONNULL_END
