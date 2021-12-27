//
//  UIViewController+Util.h
//  SimpleChat
//
//  Created by qtdmz on 25/08/2017.
//  Copyright © 2017 qtdmz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Util)

- (void)addPopBackLeftItem;

- (void)addPopBackLeftItemWithTarget:(id _Nullable )aTarget
                              action:(SEL _Nullable )aAction;

- (void)addKeyboardNotificationsWithShowSelector:(SEL _Nullable )aShowSelector
                                    hideSelector:(SEL _Nullable )aHideSelector;

- (void)removeKeyboardNotifications;

//+ (BOOL)isUseChinese;

- (void)showAlertControllerWithMessage:(NSString *)aMsg;

@end
