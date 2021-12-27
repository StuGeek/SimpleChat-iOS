//
//  NSObject+Alert.h
//  SimpleChat
//
//  Created by qtdmz on 2019/2/22.
//  Copyright © 2019 qtdmz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Alert)

- (void)showAlertWithMessage:(NSString *)aMsg;

- (void)showAlertWithTitle:(NSString *)aTitle
                   message:(NSString *)aMsg;

@end

NS_ASSUME_NONNULL_END
