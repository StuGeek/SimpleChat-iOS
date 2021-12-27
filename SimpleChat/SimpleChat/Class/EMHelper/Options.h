//
//  Options.h
//  SimpleChat
//
//  Created by qtdmz on 2018/12/17.
//  Copyright © 2018 qtdmz. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * _Nullable Options_Appkey = @"Appkey";
static NSString * _Nullable Options_ApnsCertname = @"ApnsCertname";
static NSString * _Nullable Options_HttpsOnly = @"HttpsOnly";

static NSString * _Nullable Options_SpecifyServer = @"SpecifyServer";
static NSString * _Nullable Options_IMPort = @"IMPort";
static NSString * _Nullable Options_IMServer = @"IMServer";
static NSString * _Nullable Options_RestServer = @"RestServer";

static NSString * _Nullable Options_AutoAcceptGroupInvitation = @"AutoAcceptGroupInvitation";
static NSString * _Nullable Options_AutoTransMsgFile = @"AutoTransferMessageAttachments";
static NSString * _Nullable Options_AutoDownloadThumb = @"AutoDownloadThumbnail";
static NSString * _Nullable Options_DeleteChatExitGroup = @"DeleteChatExitGroup";
static NSString * _Nullable Options_SortMessageByServerTime = @"SortMessageByServerTime";
static NSString * _Nullable Options_PriorityGetMsgFromServer = @"PriorityGetMsgFromServer";

static NSString * _Nullable Options_AutoLogin = @"AutoLogin";
static NSString * _Nullable Options_LoggedinUsername = @"LoggedinUsername";
static NSString * _Nullable Options_LoggedinPassword = @"LoggedinPassword";

static NSString * _Nullable Options_ChatTyping = @"ChatTyping";
static NSString * _Nullable Options_AutoDeliveryAck = @"AutoDeliveryAck";

static NSString * _Nullable Options_OfflineHangup = @"OfflineHangup";

static NSString * _Nullable Options_ShowCallInfo = @"ShowCallInfo";
static NSString * _Nullable Options_UseBackCamera = @"UseBackCamera";

static NSString * _Nullable Options_IsReceiveNewMsgNotice = @"IsReceiveNewMsgNotice";
static NSString * _Nullable Options_WillRecord = @"WillRecord";
static NSString * _Nullable Options_WillMergeStrem = @"WillMergeStrem";
static NSString * _Nullable Options_EnableConsoleLog = @"enableConsoleLog";

static NSString * _Nullable Options_LocationAppkeyArray = @"LocationAppkeyArray";

static NSString * _Nullable Options_IsSupportWechatMiniProgram = @"IsSupportMiniProgram";
static NSString * _Nullable Options_EnableCustomAudioData = @"EnableCustomAudioData";
static NSString * _Nullable Options_CustomAudioDataSamples = @"CustomAudioDataSamples";
static NSString * _Nullable Options_IsCustomServer = @"IsCustomServer";
static NSString * _Nullable Options_IsFirstLaunch = @"IsFirstLaunch";
static NSString * _Nullable Options_IsEnlargerFontMode = @"IsEnlargerFontMode";
static NSString * _Nullable Options_IsHasReadMode = @"IsHasReadMode";

NS_ASSUME_NONNULL_BEGIN

@class EMOptions;
@interface Options : NSObject <NSCoding, NSCopying>

@property (nonatomic, copy) NSString *appkey;
@property (nonatomic, copy) NSString *apnsCertName;
@property (nonatomic, assign) BOOL usingHttpsOnly;
@property (nonatomic) BOOL specifyServer;
@property (nonatomic, assign) int chatPort;
@property (nonatomic, copy) NSString *chatServer;
@property (nonatomic, copy) NSString *restServer;
@property (nonatomic) BOOL isAutoAcceptGroupInvitation;
@property (nonatomic) BOOL isAutoTransferMessageAttachments;
@property (nonatomic) BOOL isAutoDownloadThumbnail;
@property (nonatomic) BOOL isSortMessageByServerTime;
@property (nonatomic) BOOL isPriorityGetMsgFromServer;
@property (nonatomic) BOOL isAutoLogin;
@property (nonatomic, strong) NSString *loggedInUsername;
@property (nonatomic, strong) NSString *loggedInPassword;
@property (nonatomic) BOOL isChatTyping;
@property (nonatomic) BOOL isAutoDeliveryAck;
@property (nonatomic) BOOL isOfflineHangup;
@property (nonatomic) BOOL isShowCallInfo;
@property (nonatomic) BOOL isUseBackCamera;
@property (nonatomic) BOOL isReceiveNewMsgNotice;
@property (nonatomic) BOOL willRecord;
@property (nonatomic) BOOL willMergeStrem;
@property (nonatomic) BOOL enableConsoleLog;
@property (nonatomic) BOOL enableCustomAudioData;
@property (nonatomic) int  customAudioDataSamples;
@property (nonatomic) BOOL isSupportWechatMiniProgram;
@property (nonatomic) BOOL isCustomServer;
@property (nonatomic) BOOL isFirstLaunch;
@property (nonatomic, strong) NSMutableArray *locationAppkeyArray;
@property (nonatomic) BOOL isEnlargerFontMode;
@property (nonatomic) BOOL isHasReadMode;

+ (instancetype)sharedOptions;

+ (void)reInitAndSaveServerOptions;

+ (void)updateAndSaveServerOptions:(NSDictionary *)aDic;

- (void)archive;

- (EMOptions *)toOptions;

@end

NS_ASSUME_NONNULL_END
