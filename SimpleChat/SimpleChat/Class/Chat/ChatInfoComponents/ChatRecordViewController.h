//
//  ChatRecordViewController.h
//  SimpleChat
//
//  Created by stugeek on 2021/12/2.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMSearchViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatRecordViewController : EMSearchViewController

- (instancetype)initWithCoversationModel:(EMConversation *)conversation;

@end

NS_ASSUME_NONNULL_END
