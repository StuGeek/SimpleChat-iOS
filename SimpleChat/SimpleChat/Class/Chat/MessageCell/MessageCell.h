//
//  MessageCell.h
//  SimpleChat
//
//  Created by stugeek on 2021/12/2.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MsgBubbleView.h"

#define avatarLonger 40
#define componentSpacing 10

NS_ASSUME_NONNULL_BEGIN

@protocol MessageCellDelegate;
@interface MessageCell : UITableViewCell

@property (nonatomic, weak) id<MessageCellDelegate> delegate;
@property (nonatomic, strong) MsgBubbleView *msgView;
@property (nonatomic) EMMessageDirection direction;
@property (nonatomic, strong) EaseMessageModel *model;

- (instancetype)initWithDirection:(EMMessageDirection)aDirection
                             type:(EMMessageType)aType
                          msgView:(MsgBubbleView*)aMsgView;

@end


@protocol MessageCellDelegate <NSObject>

@optional
- (void)messageCellDidSelected:(MessageCell *)aCell;
- (void)messageAvatarDidSelected:(EaseMessageModel *)model;

@end

NS_ASSUME_NONNULL_END
