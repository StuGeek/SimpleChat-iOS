//
//  ConfirmUserCardView.h
//  SimpleChat
//
//  Created by stugeek on 2021/12/1.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ConfirmUserCardViewDelegate <NSObject>

- (void)clickOK:(NSString*)aUid nickName:(NSString*)aNickName avatarUrl:(NSString*)aUrl;
- (void)clickCancel;

@end

@interface ConfirmUserCardView : UIView
- (instancetype)initWithRemoteName:(NSString*)aRemoteName avatarUrl:(NSString*)aUrl showName:(NSString*)aShowName uid:(NSString*)aUid delegate:(id<ConfirmUserCardViewDelegate>)aDelegate;

@property (weak,nonatomic) id<ConfirmUserCardViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
