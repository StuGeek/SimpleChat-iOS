//
//  NotificationCell.h
//  SimpleChat
//
//  Created by stugeek on 2021/12/2.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NotificationCellDelegate;

@class EMNotificationModel;
@interface NotificationCell : UITableViewCell

@property (nonatomic, weak) id<NotificationCellDelegate> delegate;

@property (nonatomic, strong) EMNotificationModel *model;

@end


@protocol NotificationCellDelegate <NSObject>

@optional

- (void)agreeNotification:(EMNotificationModel *)aModel;

- (void)declineNotification:(EMNotificationModel *)aModel;

@end

NS_ASSUME_NONNULL_END
