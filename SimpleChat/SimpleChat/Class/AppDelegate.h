//
//  AppDelegate.h
//  SimpleChat
//
//  Created by stugeek on 2021/12/1.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, EMChatManagerDelegate>
{
    EMConnectionState _connectionState;
}

@property (strong, nonatomic) UIWindow *window;

@end
