//
//  ForwardMessage.h
//  SimpleChat
//
//  Created by stugeek on 2021/12/2.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import "ChatViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatViewController (EMForwardMessage)

- (void)forwardMenuItemAction:(EMMessage*)message;

@end

NS_ASSUME_NONNULL_END
