//
//  MessageStatusView.h
//  SimpleChat
//
//  Created by stugeek on 2021/12/2.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageStatusView : UIView

@property (nonatomic, copy) void (^resendCompletion)(void);

- (void)setSenderStatus:(EMMessageStatus)aStatus
            isReadAcked:(BOOL)aIsReadAcked;

@end
