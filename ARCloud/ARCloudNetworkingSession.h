//
//  ARCloudNetworkingSession.h
//  ARCloud
//
//  Created by 王冠宇 on 16/7/18.
//  Copyright © 2016年 王冠宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataHandler.h"

@class AFHTTPRequestOperation;
@class UIViewController;

@protocol GYNotificationBarProtocol <NSObject>

- (void)showBarWithString:(NSString *)string;

@end

@protocol ARCloudNetworkingSessionDelegate <NSObject>

- (void)pauseTimer;
- (void)resumTimer;

@end

@interface ARCloudNetworkingSession : NSObject <CoreDataHandler>

@property (strong, nonatomic) NSMutableDictionary *dicRelationClient;
@property (strong, nonatomic) NSMutableArray *arrayModelID;
@property (strong, nonatomic) NSMutableDictionary *dicDownloadStatus;

@property (weak, nonatomic) id<GYNotificationBarProtocol> delegate;
@property (weak, nonatomic) id<ARCloudNetworkingSessionDelegate> timerDelegate;
@property (weak, nonatomic) UIViewController *currentController;

/**
 向服务器发送所有Model的ID。
 */
- (void)sendModelIDsToServer;

/**
 向服务器询问是否需要更新ImageTarget。
 */
- (BOOL)askServerIsUpdateImageTarget;

/**
 向服务器发送扫描信号
 */
- (void)sendScanMessageToServer;

/**
 向服务器发送脱离信号
 */
- (void)sendLeaveMessageToServer;

/**
 向服务器发送手势信号
 */
- (void)sendGestureMessageToServerWithGesture:(NSString *)n;

@end
