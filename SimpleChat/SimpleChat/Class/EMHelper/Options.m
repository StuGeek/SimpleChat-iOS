//
//  Options.m
//  SimpleChat
//
//  Created by qtdmz on 2018/12/17.
//  Copyright © 2018 qtdmz. All rights reserved.
//

#import "Options.h"

#import <HyphenateChat/EMOptions+PrivateDeploy.h>

static Options *sharedOptions = nil;
@implementation Options

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _initServerOptions];
        
        self.isAutoAcceptGroupInvitation = NO;
        self.isAutoTransferMessageAttachments = YES;
        self.isAutoDownloadThumbnail = YES;
        self.isSortMessageByServerTime = YES;
        self.isPriorityGetMsgFromServer = NO;
        
        self.isAutoLogin = NO;
        self.loggedInUsername = @"";
        self.loggedInPassword = @"";
        
        self.isChatTyping = NO;
        self.isAutoDeliveryAck = NO;
        
        self.isOfflineHangup = NO;
        
        self.isShowCallInfo = YES;
        self.isUseBackCamera = NO;
        
        self.isReceiveNewMsgNotice = YES;
        self.willRecord = NO;
        self.willMergeStrem = NO;
        self.enableConsoleLog = YES;
        
        self.enableCustomAudioData = NO;
        self.customAudioDataSamples = 48000;
        self.isSupportWechatMiniProgram = NO;
        self.isCustomServer = NO;
        self.isFirstLaunch = NO;
        
        self.isEnlargerFontMode = NO;
        self.isHasReadMode = NO;
        self.locationAppkeyArray = [[NSMutableArray alloc]init];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        NSMutableArray *tempArray = [aDecoder decodeObjectForKey:Options_LocationAppkeyArray];
        if (tempArray == nil || [tempArray count] == 0) {
            self.locationAppkeyArray = [[NSMutableArray alloc]init];
            [self.locationAppkeyArray insertObject:DEF_APPKEY atIndex:0];
        } else {
            self.locationAppkeyArray = tempArray;
        }
        self.appkey = [aDecoder decodeObjectForKey:Options_Appkey];
        if ([self.appkey length] == 0) {
            self.appkey = [self.locationAppkeyArray objectAtIndex:0];
        }
        self.apnsCertName = [aDecoder decodeObjectForKey:Options_ApnsCertname];
        self.usingHttpsOnly = [aDecoder decodeBoolForKey:Options_HttpsOnly];
        
        self.specifyServer = [aDecoder decodeBoolForKey:Options_SpecifyServer];
        self.chatPort = [aDecoder decodeIntForKey:Options_IMPort];
        self.chatServer = [aDecoder decodeObjectForKey:Options_IMServer];
        self.restServer = [aDecoder decodeObjectForKey:Options_RestServer];

        self.isAutoAcceptGroupInvitation = [aDecoder decodeBoolForKey:Options_AutoAcceptGroupInvitation];
        self.isAutoTransferMessageAttachments = [aDecoder decodeBoolForKey:Options_AutoTransMsgFile];
        self.isAutoDownloadThumbnail = [aDecoder decodeBoolForKey:Options_AutoDownloadThumb];
        self.isSortMessageByServerTime = [aDecoder decodeBoolForKey:Options_SortMessageByServerTime];
        self.isPriorityGetMsgFromServer = [aDecoder decodeBoolForKey:Options_PriorityGetMsgFromServer];
        
        self.isAutoLogin = [aDecoder decodeBoolForKey:Options_AutoLogin];
        self.loggedInUsername = [aDecoder decodeObjectForKey:Options_LoggedinUsername];
        self.loggedInPassword = [aDecoder decodeObjectForKey:Options_LoggedinPassword];
        
        self.isChatTyping = [aDecoder decodeBoolForKey:Options_ChatTyping];
        self.isAutoDeliveryAck = [aDecoder decodeBoolForKey:Options_AutoDeliveryAck];
        
        self.isOfflineHangup = [aDecoder decodeBoolForKey:Options_OfflineHangup];
        
        self.isShowCallInfo = [aDecoder decodeBoolForKey:Options_ShowCallInfo];
        self.isUseBackCamera = [aDecoder decodeBoolForKey:Options_UseBackCamera];

        self.isReceiveNewMsgNotice = [aDecoder decodeBoolForKey:Options_IsReceiveNewMsgNotice];
        self.willRecord = [aDecoder decodeBoolForKey:Options_WillRecord];
        self.willMergeStrem = [aDecoder decodeBoolForKey:Options_WillMergeStrem];
        self.enableConsoleLog = [aDecoder decodeBoolForKey:Options_EnableConsoleLog];
        
        self.enableCustomAudioData = [aDecoder decodeBoolForKey:Options_EnableCustomAudioData];
        self.customAudioDataSamples = [aDecoder decodeIntForKey:Options_CustomAudioDataSamples];
        self.isSupportWechatMiniProgram = [aDecoder decodeBoolForKey:Options_IsSupportWechatMiniProgram];
        self.isCustomServer = [aDecoder decodeBoolForKey:Options_IsCustomServer];
        self.isFirstLaunch = [aDecoder decodeBoolForKey:Options_IsFirstLaunch];
        
        self.isEnlargerFontMode = [aDecoder decodeBoolForKey:Options_IsEnlargerFontMode];
        self.isHasReadMode = [aDecoder decodeBoolForKey:Options_IsHasReadMode];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.appkey forKey:Options_Appkey];
    [aCoder encodeObject:self.apnsCertName forKey:Options_ApnsCertname];
    [aCoder encodeBool:self.usingHttpsOnly forKey:Options_HttpsOnly];
    
    [aCoder encodeBool:self.specifyServer forKey:Options_SpecifyServer];
    [aCoder encodeInt:self.chatPort forKey:Options_IMPort];
    [aCoder encodeObject:self.chatServer forKey:Options_IMServer];
    [aCoder encodeObject:self.restServer forKey:Options_RestServer];

    [aCoder encodeBool:self.isAutoAcceptGroupInvitation forKey:Options_AutoAcceptGroupInvitation];
    [aCoder encodeBool:self.isAutoTransferMessageAttachments forKey:Options_AutoTransMsgFile];
    [aCoder encodeBool:self.isAutoDownloadThumbnail forKey:Options_AutoDownloadThumb];
    [aCoder encodeBool:self.isSortMessageByServerTime forKey:Options_SortMessageByServerTime];
    [aCoder encodeBool:self.isPriorityGetMsgFromServer forKey:Options_PriorityGetMsgFromServer];
    
    [aCoder encodeBool:self.isAutoLogin forKey:Options_AutoLogin];
    [aCoder encodeObject:self.loggedInUsername forKey:Options_LoggedinUsername];
    [aCoder encodeObject:self.loggedInPassword forKey:Options_LoggedinPassword];
    
    [aCoder encodeBool:self.isChatTyping forKey:Options_ChatTyping];
    [aCoder encodeBool:self.isAutoDeliveryAck forKey:Options_AutoDeliveryAck];
    
    [aCoder encodeBool:self.isOfflineHangup forKey:Options_OfflineHangup];
    
    [aCoder encodeBool:self.isShowCallInfo forKey:Options_ShowCallInfo];
    [aCoder encodeBool:self.isUseBackCamera forKey:Options_UseBackCamera];
    
    [aCoder encodeBool:self.isReceiveNewMsgNotice forKey:Options_IsReceiveNewMsgNotice];
    [aCoder encodeBool:self.willRecord forKey:Options_WillRecord];
    [aCoder encodeBool:self.willMergeStrem forKey:Options_WillMergeStrem];
    [aCoder encodeBool:self.enableConsoleLog forKey:Options_EnableConsoleLog];
    
    [aCoder encodeBool:self.enableCustomAudioData forKey:Options_EnableCustomAudioData];
    [aCoder encodeInt:self.customAudioDataSamples forKey:Options_CustomAudioDataSamples];
    
    [aCoder encodeBool:self.isSupportWechatMiniProgram forKey:Options_IsSupportWechatMiniProgram];
    
    [aCoder encodeObject:self.locationAppkeyArray forKey:Options_LocationAppkeyArray];
    [aCoder encodeBool:self.isCustomServer forKey:Options_IsCustomServer];
    [aCoder encodeBool:self.isFirstLaunch forKey:Options_IsFirstLaunch];
    
    [aCoder encodeBool:self.isEnlargerFontMode forKey:Options_IsEnlargerFontMode];
    [aCoder encodeBool:self.isHasReadMode forKey:Options_IsHasReadMode];
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    Options *retModel = [[[self class] alloc] init];
    retModel.appkey = self.appkey;
    retModel.apnsCertName = self.apnsCertName;
    retModel.usingHttpsOnly = self.usingHttpsOnly;
    retModel.specifyServer = self.specifyServer;
    retModel.chatPort = self.chatPort;
    retModel.chatServer = self.chatServer;
    retModel.restServer = self.restServer;
    retModel.isAutoAcceptGroupInvitation = self.isAutoAcceptGroupInvitation;
    retModel.isAutoTransferMessageAttachments = self.isAutoTransferMessageAttachments;
    retModel.isAutoDownloadThumbnail = self.isAutoDownloadThumbnail;
    retModel.isSortMessageByServerTime = self.isSortMessageByServerTime;
    retModel.isPriorityGetMsgFromServer = self.isPriorityGetMsgFromServer;
    retModel.isAutoLogin = self.isAutoLogin;
    retModel.loggedInUsername = self.loggedInUsername;
    retModel.loggedInPassword = self.loggedInPassword;
    retModel.isChatTyping = self.isChatTyping;
    retModel.isAutoDeliveryAck = self.isAutoDeliveryAck;
    retModel.isOfflineHangup = self.isOfflineHangup;
    retModel.isShowCallInfo = self.isShowCallInfo;
    retModel.isUseBackCamera = self.isUseBackCamera;
    retModel.isReceiveNewMsgNotice = self.isReceiveNewMsgNotice;
    retModel.willRecord = self.willRecord;
    retModel.willMergeStrem = self.willMergeStrem;
    retModel.enableConsoleLog = self.enableConsoleLog;
    retModel.enableCustomAudioData = self.enableCustomAudioData;
    retModel.customAudioDataSamples = self.customAudioDataSamples;
    retModel.isSupportWechatMiniProgram = self.isSupportWechatMiniProgram;
    retModel.isCustomServer = self.isCustomServer;
    retModel.locationAppkeyArray = self.locationAppkeyArray;
    retModel.isFirstLaunch = self.isFirstLaunch;
    
    retModel.isEnlargerFontMode = self.isEnlargerFontMode;
    retModel.isHasReadMode = self.isHasReadMode;
    return retModel;
}

- (void)setLoggedInUsername:(NSString *)loggedInUsername
{
    if (![_loggedInUsername isEqualToString:loggedInUsername]) {
        _loggedInUsername = loggedInUsername;
        _loggedInPassword = @"";
    }
}

#pragma mark - Private

- (void)_initServerOptions
{
    self.appkey = DEF_APPKEY;
#if DEBUG
    self.apnsCertName = @"EaseIM_APNS_Developer";
#else
    self.apnsCertName = @"EaseIM_APNS_Product";
#endif
    self.usingHttpsOnly = YES;
    self.specifyServer = NO;
    self.chatServer = @"106.75.100.247";
    self.chatPort = 6717;
    self.restServer = @"a1-hsb.easemob.com";
}

#pragma mark - Public

- (void)archive
{
    NSString *fileName = @"emdemo_options.data";
    NSString *file = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:fileName];
    [NSKeyedArchiver archiveRootObject:self toFile:file];
}

- (EMOptions *)toOptions
{
    EMOptions *retOpt = [EMOptions optionsWithAppkey:self.appkey];
    retOpt.apnsCertName = self.apnsCertName;
    retOpt.usingHttpsOnly = self.usingHttpsOnly;

    //self.specifyServer = YES;
    if (self.specifyServer) {
        retOpt.enableDnsConfig = NO;
        retOpt.chatPort = self.chatPort;
        retOpt.chatServer = self.chatServer;
        retOpt.restServer = self.restServer;
    }
    
    retOpt.isAutoLogin = self.isAutoLogin;
    
    retOpt.isAutoAcceptGroupInvitation = self.isAutoAcceptGroupInvitation;
    retOpt.isAutoTransferMessageAttachments = self.isAutoTransferMessageAttachments;
    retOpt.isAutoDownloadThumbnail = self.isAutoDownloadThumbnail;
    retOpt.sortMessageByServerTime = self.isSortMessageByServerTime;
    
    retOpt.enableDeliveryAck = self.isAutoDeliveryAck;
    retOpt.enableConsoleLog = YES;
    return retOpt;
}

#pragma mark - Class Methods

+ (instancetype)sharedOptions
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedOptions = [Options getOptionsFromLocal];
    });
    
    return sharedOptions;
}

+ (Options *)getOptionsFromLocal
{
    Options *retModel = nil;
    NSString *fileName = @"emdemo_options.data";
    NSString *file = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:fileName];
    retModel = [NSKeyedUnarchiver unarchiveObjectWithFile:file];
    if (!retModel) {
        retModel = [[Options alloc] init];
        [retModel archive];
    }
    
    return retModel;
}

+ (void)reInitAndSaveServerOptions
{
    Options *demoOptions = [Options sharedOptions];
    [demoOptions _initServerOptions];
    
    [demoOptions archive];
}

+ (void)updateAndSaveServerOptions:(NSDictionary *)aDic
{
    NSString *appkey = [aDic objectForKey:Options_Appkey];
    NSString *apns = [aDic objectForKey:Options_ApnsCertname];
    BOOL httpsOnly = [[aDic objectForKey:Options_HttpsOnly] boolValue];
    if ([appkey length] == 0) {
        appkey = DEF_APPKEY;
    }
    if ([apns length] == 0) {
#if DEBUG
        apns = @"EaseIM_APNS_Developer";
#else
        apns = @"EaseIM_APNS_Product";
#endif
    }
    
    Options *demoOptions = [Options sharedOptions];
    demoOptions.appkey = appkey;
    demoOptions.apnsCertName = apns;
    demoOptions.usingHttpsOnly = httpsOnly;
    
    int specifyServer = [[aDic objectForKey:Options_SpecifyServer] intValue];
    demoOptions.specifyServer = NO;
    if (specifyServer != 0) {
        demoOptions.specifyServer = YES;
        
        NSString *imServer = [aDic objectForKey:Options_IMServer];
        NSString *imPort = [aDic objectForKey:Options_IMPort];
        NSString *restServer = [aDic objectForKey:Options_RestServer];
        if ([imServer length] > 0 && [restServer length] > 0 && [imPort length] > 0) {
            demoOptions.chatPort = [imPort intValue];
            demoOptions.chatServer = imServer;
            demoOptions.restServer = restServer;
        }
    }
    
    [demoOptions archive];
}

@end
