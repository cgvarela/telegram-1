//
//  AppDelegate.h
//  TelegramTest
//
//  Created by keepcoder on 07.09.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#ifdef TGDEBUG
#ifndef TGSTABLE
#import <HockeySDK/HockeySDK.h>
#endif
#endif

#ifdef TGDEBUG
#import <Sparkle/Sparkle.h>
#endif

#import "TelegramWindow.h"
#import "LoginWindow.h"
#import "MainWindow.h"
#import "SPMediaKeyTap.h"
@class Telegram;



@interface AppDelegate : NSObject <NSApplicationDelegate, NSApplicationDelegate,NSWindowDelegate, NSUserNotificationCenterDelegate>



@property (nonatomic, strong) IBOutlet  Telegram *telegram;
@property (nonatomic, strong) MainWindow *mainWindow;
@property (nonatomic, strong) LoginWindow *loginWindow;

@property (nonatomic, strong) SPMediaKeyTap *mediaKeyTap;

@property (nonatomic, strong,readonly) NSStatusItem *statusItem;

- (TelegramWindow *)window;
- (void)logoutWithForce:(BOOL)force;

- (void)setConnectionStatus:(NSString *)status;
- (void)initializeMainWindow;


@end
