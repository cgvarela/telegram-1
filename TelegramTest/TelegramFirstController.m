//
//  TelegramFirstResponder.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/10/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TelegramFirstController.h"
#define PERFORM_SELECTOR()  if([self.viewController respondsToSelector:sender.action]) [self controller:self.viewController performSelector:sender.action withObject:sender];
#import "TMMediaController.h"
#import "Rebel/Rebel.h"
#import "TGPhotoViewer.h"
#import "TGAudioPlayerWindow.h"
@interface TelegramFirstController ()



@end

@implementation TelegramFirstController

- (id)init {
    self = [super init];
    if(self) {
      
    }
    return self;
}

-(void)awakeFromNib {
    
    
#ifndef TGDEBUG
    
    
    NSMenu *menu = [NSApp mainMenu];
    NSMenuItem *main = [menu itemAtIndex:0];
    
    [main.submenu removeItem:[main.submenu itemWithTag:1000]];
    
    
#endif
    
    
}

- (IBAction)findAction:(id)sender {
    [appWindow().navigationController.messagesViewController showSearchBox];
}

- (IBAction)findNextAction:(id)sender {
    [appWindow().navigationController.messagesViewController nextSearchResult];
}

- (IBAction)findPreviousAction:(id)sender {
    [appWindow().navigationController.messagesViewController prevSearchResult];
}

- (void)controller:(TMViewController *)controller performSelector:(SEL)aSelector withObject:(id)anArgument {
    IMP imp = [controller methodForSelector:aSelector];
    if(imp) {
        void (*func)(id, SEL, id) = (void *)imp;
        func(controller, aSelector, anArgument);
    }
}

- (IBAction)newMessage:(NSMenuItem *)sender {
    [self controller:[Telegram leftViewController] performSelector:sender.action withObject:sender];
}

- (IBAction)newGroup:(NSMenuItem *)sender {
    [self controller:[Telegram leftViewController] performSelector:sender.action withObject:sender];
}

- (IBAction)newSecretChat:(NSMenuItem *)sender {
    [self controller:[Telegram leftViewController] performSelector:sender.action withObject:sender];
}

- (IBAction)logout:(NSMenuItem *)sender {
    [[Telegram delegate] logoutWithForce:NO];
}


- (IBAction)openSettings:(id)sender {
    if (![Telegram isSingleLayout]) {
        [[Telegram leftViewController] showTabControllerAtIndex:2];
    } else {
        [[Telegram rightViewController] showGeneralSettings];
    }
    
}

- (IBAction)clearChatHistory:(NSMenuItem *)sender {
    PERFORM_SELECTOR();
}
- (IBAction)askQuestion:(id)sender {
    
    NSUInteger supportUserId = [SettingsArchiver supportUserId];
    
    __block TLUser *supportUser;
    
    
    dispatch_block_t block = ^ {
        TL_conversation *dialog = [[DialogsManager sharedManager] findByUserId:supportUser.n_id];
        
        if(!dialog) {
            dialog = [[DialogsManager sharedManager] createDialogForUser:supportUser];
            [dialog save];
        }
        
        [appWindow().navigationController showMessagesViewController:dialog];
    };
    
    
    

    if(supportUserId) {
        supportUser = [[UsersManager sharedManager] find:supportUserId];
        if(supportUser) {
            block();
            return;
        }
    }
    
    [RPCRequest sendRequest:[TLAPI_help_getSupport create] successHandler:^(RPCRequest *request, TL_help_support *response) {
        
        supportUser = response.user;
        [[UsersManager sharedManager] add:@[supportUser]];
        
        [SettingsArchiver setSupportUserId:response.user.n_id];
        block();
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {

    } timeout:5];

}

- (IBAction)settings:(id)sender {
    [[Telegram leftViewController] showUserSettings];
}
- (IBAction)showMedia:(id)sender {
    
    TMCollectionPageController *collectionViewController = [[TMCollectionPageController alloc] initWithFrame:NSZeroRect];
    
    [collectionViewController setConversation:[Telegram conversation]];
    
    [appWindow().navigationController pushViewController:collectionViewController animated:YES];
    
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    if(!self.viewController)
        return NO;
    
    if([Telegram delegate].mainWindow) {
        
        if(![Telegram delegate].mainWindow.isKeyWindow) {
            return NO;
        }
        
        if(menuItem.action == @selector(newMessage:)) {
            return YES;
        } else if(menuItem.action == @selector(newGroup:)) {
            return YES;
        } else if(menuItem.action == @selector(newSecretChat:)) {
            return YES;
        } else if(menuItem.action == @selector(logout:)) {
            return YES;
        } else if(menuItem.action == @selector(importContacts:)) {
            return YES;
        } else if(menuItem.action == @selector(settings:)) {
            return YES;
        } else if(menuItem.action == @selector(showMedia:)) {
            return [[Telegram rightViewController] isActiveDialog];
        } else if(menuItem.action == @selector(openSettings:)) {
            return YES;
        } else if(menuItem.action == @selector(askQuestion:)) {
            return YES;
        } else if(menuItem.action == @selector(checkForUpdates:)) {
            return YES;
        } else if(menuItem.action == @selector(showAudioMiniPlayer:)) {
            return [Telegram conversation] && [Telegram conversation].type != DialogTypeSecretChat && [Telegram conversation].type != DialogTypeBroadcast;
        } else if(menuItem.action == @selector(findAction:)) {
            return [appWindow().navigationController.currentController isKindOfClass:[MessagesViewController class]];
        }else if(menuItem.action == @selector(findPreviousAction:)) {
            return [appWindow().navigationController.currentController isKindOfClass:[MessagesViewController class]] && [appWindow().navigationController.messagesViewController searchBoxIsVisible];
        }
        else if(menuItem.action == @selector(findNextAction:)) {
            return [appWindow().navigationController.currentController isKindOfClass:[MessagesViewController class]] && [appWindow().navigationController.messagesViewController searchBoxIsVisible];
        }

    }
    
    if(menuItem.action == @selector(aboutAction:))
        return YES;
    
    BOOL isRespondToSelector = [self.viewController respondsToSelector:menuItem.action];
    return isRespondToSelector;
}


- (IBAction)showAudioMiniPlayer:(id)sender {
    [TGAudioPlayerWindow show:[Telegram conversation]  navigation:appWindow().navigationController];
}


- (IBAction)aboutAction:(id)sender {
    [[Telegram rightViewController] showAbout];
}

- (BOOL)closeAllPopovers {
    BOOL result = NO;
    NSWindow *mainWindow = [Telegram delegate].window;
    if(mainWindow.childWindows.count) {
        for(TMMenuPopoverWindow *window in mainWindow.childWindows) {
            if(([window isKindOfClass:[TMMenuPopoverWindow class]] || [window isKindOfClass:[RBLPopoverWindow class]]) && window.popover) {
                [window.popover close];
                result = YES;
            }
        }
    }
    return result;
}
- (IBAction)toogleFloatOnTop:(NSMenuItem *)sender {
    
    [[Telegram delegate].mainWindow setLevel:!sender.state ? NSScreenSaverWindowLevel : NSNormalWindowLevel];
    
    [sender setState:!sender.state];
}

- (void)backOrClose:(NSMenuItem *)sender {
    
    NSWindow *mainWindow = [Telegram delegate].window;
    if([self closeAllPopovers])
        return;
    
    if(mainWindow.attachedSheet) {
        [mainWindow.attachedSheet close];
        return;
    }
    
    if([[Telegram rightViewController] isModalViewActive]) {
        
        [[Telegram rightViewController] hideModalView:YES animation:YES];
        
        if(![Telegram isSingleLayout])
        {
            return;
        }
    }
    
    if([self.viewController respondsToSelector:@selector(backOrClose:)]) {
        [self controller:self.viewController performSelector:@selector(backOrClose:) withObject:nil];
        return;
    }
    
    [[Telegram rightViewController] navigationGoBack];
    return;
}

@end
