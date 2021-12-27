//
//  EMRightViewTool.m
//  SimpleChat
//
//  Created by stugeek on 2021/12/3.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import "RightViewToolView.h"

#define RightViewRange 24.0

@interface RightViewToolView()

@end

@implementation RightViewToolView

- (instancetype)initRightViewWithViewType:(EMRightViewType)rightViewType
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, 46, RightViewRange);
        self.rightViewBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, RightViewRange, RightViewRange)];
        if (rightViewType == EMPswdRightView) {
            //密码
            [self.rightViewBtn setImage:[UIImage imageNamed:@"hiddenPwd"] forState:UIControlStateNormal];
            [self.rightViewBtn setImage:[UIImage imageNamed:@"showPwd"] forState:UIControlStateSelected];
        }
        if (rightViewType == EMUsernameRightView)
            //清除用户名
            [self.rightViewBtn setImage:[UIImage imageNamed:@"clearContent"] forState:UIControlStateNormal];
        [self addSubview:self.rightViewBtn];
    }
    return self;
}

@end
