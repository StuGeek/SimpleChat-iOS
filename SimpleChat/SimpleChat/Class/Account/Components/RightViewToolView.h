//
//  EMRightViewTool.h
//  SimpleChat
//
//  Created by stugeek on 2021/12/3.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, EMRightViewType) {
    EMPswdRightView = 0,
    EMUsernameRightView,
};


/**
 登录注册输入框textfiled的rightView组件
*/
@interface RightViewToolView : UIView

@property (nonatomic, strong) UIButton *rightViewBtn;

- (instancetype)initRightViewWithViewType:(EMRightViewType)rightViewType;

@end

NS_ASSUME_NONNULL_END
