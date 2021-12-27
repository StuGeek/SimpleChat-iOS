//
//  ChatInfoViewController.h
//  SimpleChat
//
//  Created by stugeek on 2021/12/2.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMRefreshViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatInfoViewController : EMRefreshViewController

- (instancetype)initWithCoversation:(EMConversation *)aConversation;

@property (nonatomic, copy) void (^clearRecordCompletion)(BOOL isClearRecord);

@end

NS_ASSUME_NONNULL_END
