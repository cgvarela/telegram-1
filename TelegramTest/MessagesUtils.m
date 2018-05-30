//
//  MessagesUtils.m
//  TelegramTest
//
//  Created by keepcoder on 04.11.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "MessagesUtils.h"
#import "Extended.h"
#import "TMAttributedString.h"
#import "TMInAppLinks.h"
#import "NSNumber+NumberFormatter.h"
#import "TGDateUtils.h"
@implementation MessagesUtils


+(NSString *)joinUsersByUsers:(NSArray *)users {
    __block NSString *resUsers;
    
    [users enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TLUser *userAdd = [[UsersManager sharedManager] find:[obj intValue]];
        
        
        resUsers = [NSString stringWithFormat:@"%@",[userAdd fullName]];
        
        if(idx != users.count -1 ) {
            resUsers = [resUsers stringByAppendingString:@", "];
        }
        
        
    }];

    return resUsers;
    
}

+(NSString *)serviceMessage:(TL_localMessage *)message forAction:(TLMessageAction *)action {
    
    TLUser *user = [[UsersManager sharedManager] find:message.from_id];
    NSString *text;
    if([action isKindOfClass:[TL_messageActionChatEditTitle class]]) {
        text = [NSString stringWithFormat:NSLocalizedString(message.isChannelMessage && !message.chat.isMegagroup  ? @"MessageAction.Service.ChannelGroupName" : @"MessageAction.ServiceMessage.ChangedGroupName", nil), message.isChannelMessage && !message.chat.isMegagroup ? message.chat.title : [user fullName], action.title];
    } else if([action isKindOfClass:[TL_messageActionChatDeletePhoto class]]) {
        text = [NSString stringWithFormat:NSLocalizedString(message.isChannelMessage && !message.chat.isMegagroup  ? @"MessageAction.ServiceMessage.RemovedChannelPhoto" : @"MessageAction.ServiceMessage.RemovedGroupPhoto", nil), message.isChannelMessage && !message.chat.isMegagroup  ? message.chat.title : [user fullName]];
    } else if([action isKindOfClass:[TL_messageActionChatEditPhoto class]]) {
        text = [NSString stringWithFormat:NSLocalizedString(message.isChannelMessage && !message.chat.isMegagroup  ? @"MessageAction.ServiceMessage.ChangedChannelPhoto" : @"MessageAction.ServiceMessage.ChangedGroupPhoto", nil), message.isChannelMessage && !message.chat.isMegagroup  ? message.chat.title : [user fullName]];
    } else if([action isKindOfClass:[TL_messageActionChatAddUser class]]) {
        
        if(message.isChannelMessage && !message.chat.isMegagroup ) {
            
            if(action.users.count == 1 && [action.users[0] intValue] == [UsersManager currentUserId]) {
                text = NSLocalizedString(@"MessageAction.Service.InvitedYouToChannel",nil);
            } else {
                
                text = [NSString stringWithFormat:NSLocalizedString(@"MessageAction.ServiceMessage.InvitedGroup", nil), [user fullName], [self joinUsersByUsers:action.users]];
            }

            if(message.from_id == [UsersManager currentUserId]) {
                text = NSLocalizedString(@"MessageAction.Service.YouChoinedToChannel", nil);
            }
            
        } else {
            
            text = [NSString stringWithFormat:NSLocalizedString(@"MessageAction.ServiceMessage.InvitedGroup", nil), [user fullName], [self joinUsersByUsers:action.users]];
        }
        
        
        
        
    }else if([action isKindOfClass:[TL_messageActionChatCreate class]]) {
        text = [NSString stringWithFormat:NSLocalizedString(@"MessageAction.ServiceMessage.CreatedChat", nil), [user fullName],action.title];
    } else if([action isKindOfClass:[TL_messageActionChatDeleteUser class]]) {
        if(action.user_id != message.from_id) {
            TLUser *userDelete = [[UsersManager sharedManager] find:action.user_id];
            text = [NSString stringWithFormat:NSLocalizedString(@"MessageAction.ServiceMessage.KickedGroup", nil), [user fullName], [userDelete fullName]];
        } else {
            text = [NSString stringWithFormat:NSLocalizedString(@"MessageAction.ServiceMessage.LeftGroup", nil), [user fullName]];
        }
    } else if([action isKindOfClass:[TL_messageActionEncryptedChat class]] || [action isKindOfClass:[TL_messageActionBotDescription class]]) {
        text = action.title;
    } else if([action isKindOfClass:[TL_messageActionChatJoinedByLink class]]) {
        
        NSString *fullName = message.isPost ? message.chat.title : [user fullName];
        
        text = [NSString stringWithFormat:@"%@ %@", fullName,NSLocalizedString(@"MessageAction.Service.JoinedGroupByLink", nil)];
        
    }else if([action isKindOfClass:[TL_messageActionChannelCreate class]]) {
        text = message.isChannelMessage && !message.chat.isMegagroup ? NSLocalizedString(@"MessageAction.Service.ChannelCreated", nil) : NSLocalizedString(@"MessageAction.ServiceMessage.CreatedChat", nil);
        
    } else if([action isKindOfClass:[TL_messageActionChatMigrateTo class]] || [action isKindOfClass:[TL_messageActionChannelMigrateFrom class]]) {
        text = NSLocalizedString(@"MessageAction.Service.ChatMigrated", nil);
    } else if([action isKindOfClass:[TL_messageActionPinMessage class]]) {
        text = NSLocalizedString(@"MessageAction.Service.PinnedMessage", nil);
    } else if([action isKindOfClass:[TL_messageActionGameScore class]]) {
        NSString *fullName = [user fullName];
        
        text = [NSString stringWithFormat:@"%@ %@", fullName,[NSString stringWithFormat:NSLocalizedString(action.score > 1 ? @"Message.Action.GameScoredShortPluar" : action.score == 0 ? @"Message.Action.GameScoredShortZero" : @"Message.Action.GameScoredShortSingular", nil),action.score]];
    }
   
    return text;
}

+(NSString *)selfDestructTimer:(int)ttl {
    
    
    NSString *localized = @"";
    
    if(ttl == 0)
        return NSLocalizedString(@"SelfDestruction.DisableTimer", nil);
    else if(ttl <= 59) {
        localized = [NSString stringWithFormat:NSLocalizedString(@"Notification.MessageLifetimeSeconds", nil),ttl,ttl == 1 ? @"": @"s"];
    } else if(ttl <= 3599) {
        int minutes = ttl / 60;
        localized = [NSString stringWithFormat:NSLocalizedString(@"Notification.MessageLifetimeMinutes", nil),minutes,minutes == 1 ? @"": @"s"];
    } else if(ttl <= 86399) {
        int hours = ttl / 60 / 60;
        localized = [NSString stringWithFormat:NSLocalizedString(@"Notification.MessageLifetimeHours", nil),hours,hours == 1 ? @"": @"s"];
    } else if(ttl <= 604799) {
        int days = ttl / 60 / 60 / 24;
        localized = [NSString stringWithFormat:NSLocalizedString(@"Notification.MessageLifetimeDays", nil),days,days == 1 ? @"": @"s"];
    } else {
        int weeks = ttl / 60 / 60 / 24 / 7;
        localized = [NSString stringWithFormat:NSLocalizedString(@"Notification.MessageLifetimeWeeks", nil),weeks,weeks == 1 ? @"": @"s"];

    }
    
    return [NSString stringWithFormat:NSLocalizedString(@"SelfDestruction.SetTimer", nil),localized];
}


+(NSString *)shortTTL:(int)ttl {
    if(ttl == 0 || ttl == -1) {
        return NSLocalizedString(@"Secret.SelfDestruct.Off", nil);
    }

    if(ttl <= 59) {
        return [NSString stringWithFormat:NSLocalizedString(@"Notification.MessageLifetimeSeconds", nil),ttl,ttl == 1 ? @"": @"s"];
    } else if(ttl <= 3599) {
        int minutes = ttl / 60;
        return [NSString stringWithFormat:NSLocalizedString(@"Notification.MessageLifetimeMinutes", nil),minutes,minutes == 1 ? @"": @"s"];
    } else if(ttl <= 86399) {
        int hours = ttl / 60 / 60;
        return [NSString stringWithFormat:NSLocalizedString(@"Notification.MessageLifetimeHours", nil),hours,hours == 1 ? @"": @"s"];
    } else if(ttl <= 604799) {
        int days = ttl / 60 / 60 / 24;
        return [NSString stringWithFormat:NSLocalizedString(@"Notification.MessageLifetimeDays", nil),days,days == 1 ? @"": @"s"];
    } else {
        int weeks = ttl / 60 / 60 / 24 / 7;
        return [NSString stringWithFormat:NSLocalizedString(@"Notification.MessageLifetimeWeeks", nil),weeks,weeks == 1 ? @"": @"s"];
        
    }
    
    return [NSString stringWithFormat:@"%d s",ttl];
}



+(NSMutableAttributedString *)conversationLastText:(TL_localMessage *)message conversation:(TL_conversation *)conversation {
    
    NSMutableAttributedString *messageText = [[NSMutableAttributedString alloc] init];
    [messageText setSelectionColor:NSColorFromRGB(0xfffffe) forColor:DARK_BLACK];
    [messageText setSelectionColor:NSColorFromRGB(0xffffff) forColor:GRAY_TEXT_COLOR];
    
    
    
    if(conversation.type == DialogTypeSecretChat) {
        EncryptedParams *params = conversation.encryptedChat.encryptedParams;
        
        if(params.state == EncryptedDiscarted) {
            
            [messageText appendString:NSLocalizedString(@"MessageAction.Secret.CancelledSecretChat",nil) withColor:GRAY_TEXT_COLOR];
            
            
            [messageText endEditing];
            return messageText;
        } else if(params.state == EncryptedWaitOnline) {
            
            [messageText appendString:[NSString stringWithFormat:NSLocalizedString(@"MessageAction.Secret.WaitingToGetOnline",nil), conversation.encryptedChat.peerUser.first_name] withColor:GRAY_TEXT_COLOR];
            
            [messageText endEditing];
            return messageText;
        } else if(params.state == EncryptedAllowed && conversation.top_message == -1) {
            
            NSString *actionFormat = [UsersManager currentUserId] == conversation.encryptedChat.admin_id ? NSLocalizedString(@"MessageAction.Secret.UserJoined",nil) : NSLocalizedString(@"MessageAction.Secret.CreatedSecretChat",nil);
            
            [messageText appendString:[NSString stringWithFormat:actionFormat,conversation.encryptedChat.peerUser.first_name] withColor:GRAY_TEXT_COLOR];
            
            
            [messageText endEditing];
            return messageText;
        }
    }
    
    
    
    [messageText beginEditing];
    if(message && ![message.action isKindOfClass:[TL_messageActionHistoryClear class]]) {
        
        NSString *msgText = @"";
        NSMutableArray *users = [NSMutableArray array];
        TLUser *userLast;
        NSString *chatUserNameString;
        
        
        
        if(((message.conversation.type == DialogTypeChannel && message.from_id != 0 && !message.isPost && message.chat.isMegagroup) || message.conversation.type == DialogTypeChat) ) {
            
            if(!message.n_out) {
                userLast = message.fromUser;
                chatUserNameString = [userLast ? userLast.fullName : @"" stringByAppendingString:@"\n"];
            } else {
                chatUserNameString = [NSLocalizedString(@"Profile.You", nil) stringByAppendingString:@"\n"];
            }
            
            if(message.action)
                userLast = message.fromUser;
            
        }
        
        
        
        BOOL isAction = NO;
        
        if(message.action) {
            isAction = YES;
             if(message.conversation.type != DialogTypeSecretChat && userLast)
                chatUserNameString = userLast ? userLast.fullName : NSLocalizedString(@"MessageAction.Service.LeaveChat", nil);

            
            TLMessageAction *action = message.action;
            if([action isKindOfClass:[TL_messageActionChatEditTitle class]]) {
                msgText =message.isChannelMessage && !message.chat.isMegagroup  ? NSLocalizedString(@"MessageAction.Service.ChannelGroupName", nil) : NSLocalizedString(@"MessageAction.Service.ChangedGroupName", nil);
            } else if([action isKindOfClass:[TL_messageActionChatDeletePhoto class]]) {
                msgText =message.isChannelMessage && !message.chat.isMegagroup  ? NSLocalizedString(@"MessageAction.Service.RemovedChannelPhoto", nil) : NSLocalizedString(@"MessageAction.Service.RemovedGroupPhoto", nil);
            } else if([action isKindOfClass:[TL_messageActionChatEditPhoto class]]) {
                 msgText =message.isChannelMessage && !message.chat.isMegagroup  ? NSLocalizedString(@"MessageAction.Service.ChangedChannelPhoto", nil) : NSLocalizedString(@"MessageAction.Service.ChangedGroupPhoto", nil);
            } else if([action isKindOfClass:[TL_messageActionChatAddUser class]]) {
                
                if(message.isChannelMessage && !message.chat.isMegagroup ) {
                    
                    if(action.users.count == 1 && [action.users[0] intValue] == [UsersManager currentUserId]) {
                        msgText = NSLocalizedString(@"MessageAction.Service.InvitedYouToChannel",nil);
                    } else {
                        msgText = NSLocalizedString(@"MessageAction.Service.InvitedGroup", nil);
                        [users addObjectsFromArray:action.users];
                    }
                    
                    if(message.from_id  == [UsersManager currentUserId]) {
                        msgText = NSLocalizedString(@"MessageAction.Service.YouChoinedToChannel", nil);
                    }
                } else {
                    
                    if(action.users.count == 1 && [action.users[0] intValue] == message.from_id) {
                        msgText = NSLocalizedString(@"MessageAction.Service.JoinedGroup", nil);
                    } else {
                        msgText = NSLocalizedString(@"MessageAction.Service.InvitedGroup", nil);
                        [users addObjectsFromArray:action.users];
                    }
                    
                }
                
                
                
                
            } else if([action isKindOfClass:[TL_messageActionChatCreate class]]) {
                msgText = [NSString stringWithFormat:NSLocalizedString(@"MessageAction.Service.CreatedChat", nil),action.title];
            } else if([action isKindOfClass:[TL_messageActionChatDeleteUser class]]) {
                
                if(action.user_id != message.from_id) {
                    
                    [users addObject:@(action.user_id)];
                    
                    msgText = NSLocalizedString(@"MessageAction.Service.KickedGroup", nil);
                } else {
                    msgText = NSLocalizedString(@"MessageAction.Service.LeftGroup", nil);
                }
            } else if([action isKindOfClass:[TL_messageActionEncryptedChat class]]) {
                msgText = action.title;
            } else if([action isKindOfClass:[TL_messageActionSetMessageTTL class]]) {
                msgText = [MessagesUtils selfDestructTimer:[(TL_messageActionSetMessageTTL *)action ttl]];
            } else if([action isKindOfClass:[TL_messageActionChatJoinedByLink class]]) {
                
                
                msgText = NSLocalizedString(@"MessageAction.Service.JoinedGroupByLink", nil);
                
            } else if([action isKindOfClass:[TL_messageActionChannelCreate class]]) {
                
                msgText = NSLocalizedString(@"MessageAction.Service.ChannelCreated", nil);
                
            } else if([action isKindOfClass:[TL_messageActionChannelMigrateFrom class]] || [action isKindOfClass:[TL_messageActionChatMigrateTo class]]) {
                msgText = NSLocalizedString(@"MessageAction.Service.ChatMigrated", nil);
                chatUserNameString = nil;
            } else if([action isKindOfClass:[TL_messageActionPinMessage class]]) {
                msgText = NSLocalizedString(@"MessageAction.Service.PinnedMessage", nil);

            } else if([action isKindOfClass:[TL_messageActionGameScore class]]) {
                msgText = [NSString stringWithFormat:NSLocalizedString(action.score > 1 ? @"Message.Action.ConversationGamePluar" : action.score == 0 ? @"Message.Action.ConversationGameZero" : @"Message.Action.ConversationGameSingular", nil),action.score];
            } else if([action isKindOfClass:[TL_messageActionPhoneCall class]]) {
                msgText = @"phone call";
            }

            
            if(chatUserNameString)
                msgText = [NSString stringWithFormat:@" %@", msgText];
            
        }
        
        
        if(conversation.draft.message.length > 0 && conversation.unread_count == 0 && conversation.canSendMessage) {
            [messageText appendString:[NSLocalizedString(@"Conversation.Draft", nil) stringByAppendingString:@"\n"] withColor:[NSColor redColor]];
            [messageText setSelectionColor:[NSColor whiteColor] forColor:[NSColor redColor]];
        } else {
            if(chatUserNameString)
                [messageText appendString:chatUserNameString withColor:!message.action ? DARK_BLACK : GRAY_TEXT_COLOR];
        }
        

        if(!message.action) {
            if(message.media && ![message.media isKindOfClass:[TL_messageMediaEmpty class]] && ![message.media isKindOfClass:[TL_messageMediaWebPage class]]) {
                msgText = [MessagesUtils mediaMessage:message];
            } else {
                msgText = message.message ? [message.message fixEmoji] : @"";
                msgText = [msgText trim];
            }
            
            if(!msgText.length)
                msgText = @"";
        }
        
        msgText = [msgText stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        
        msgText = [msgText fixEmoji];
        
        if(conversation.draft.message.length > 0 && conversation.unread_count == 0 && conversation.canSendMessage) {
            msgText = conversation.draft.message;
        }
        
        if(msgText) {
            [messageText appendString:msgText withColor:GRAY_TEXT_COLOR];
        }
        
        NSString *joinUsers = [self joinUsersByUsers:users];
        
        if(joinUsers.length > 0) {
            [messageText appendString:[NSString stringWithFormat:@" %@",joinUsers] withColor:GRAY_TEXT_COLOR];
        }
        
    } else {
        [messageText appendString:@"" withColor:LIGHT_GRAY];
    }
    
    [messageText setFont:TGSystemFont(13) forRange:messageText.range];
    
    
    static NSMutableParagraphStyle *paragraph;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        paragraph = [[NSMutableParagraphStyle alloc] init];
        [paragraph setLineSpacing:0];
        [paragraph setMinimumLineHeight:5];
        [paragraph setMaximumLineHeight:16];
      //  [paragraph ]
        
    });
    
    [messageText setAlignment:NSLeftTextAlignment range:NSMakeRange(0, messageText.length)];
    
    [messageText addAttribute:NSParagraphStyleAttributeName value:paragraph range:messageText.range];
    
    [messageText endEditing];
    
    return messageText;
}

+ (NSAttributedString *) serviceAttributedMessage:(TL_localMessage *)message forAction:(TLMessageAction *)action {
    
    TLUser *user = [message.chat isKindOfClass:[TLChat class]] && message.chat.isChannel && !message.chat.isMegagroup ? nil : [[UsersManager sharedManager] find:message.from_id];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    NSMutableArray *users = [NSMutableArray array];
    NSString *actionText;
    
    NSString *title;
    
    if([action isKindOfClass:[TL_messageActionChatEditTitle class]]) {
        
        actionText = NSLocalizedString(message.isChannelMessage && !message.chat.isMegagroup ? @"MessageAction.Service.ChannelGroupName" : @"MessageAction.Service.ChangedGroupName",nil);
        title = action.title;
        
    } else if([action isKindOfClass:[TL_messageActionChatDeletePhoto class]]) {
        
        actionText = NSLocalizedString(message.isChannelMessage && !message.chat.isMegagroup  ? @"MessageAction.Service.RemovedChannelPhoto" : @"MessageAction.Service.RemovedGroupPhoto",nil);
        
    } else if([action isKindOfClass:[TL_messageActionChatEditPhoto class]]) {
        
        actionText = NSLocalizedString(message.isChannelMessage && !message.chat.isMegagroup  ? @"MessageAction.Service.ChangedChannelPhoto" : @"MessageAction.Service.ChangedGroupPhoto",nil);
        
    } else if([action isKindOfClass:[TL_messageActionChatAddUser class]]) {
        
        if(message.isChannelMessage && !message.chat.isMegagroup ) {
            
            if(action.users.count == 1 && [action.users[0] intValue] == [UsersManager currentUserId]) {
               actionText = NSLocalizedString(@"MessageAction.Service.InvitedYouToChannel",nil);
            } else {
                
                [action.users enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    TLUser *user = [[UsersManager sharedManager] find:[obj intValue]];
                    
                    if(user != nil) {
                        [users addObject:user];
                    }
                }];
                
                actionText = NSLocalizedString(@"MessageAction.Service.Invited",nil);
            }
            if(message.from_id  == [UsersManager currentUserId]) {
                actionText = NSLocalizedString(@"MessageAction.Service.YouChoinedToChannel", nil);
            }
        } else {
            if(action.users.count == 1 && [action.users[0] intValue] == message.from_id) {
                actionText = NSLocalizedString(@"MessageAction.Service.JoinedGroup", nil);
            } else {
                actionText = NSLocalizedString(@"MessageAction.Service.InvitedGroup",nil);
                
                [action.users enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    TLUser *user = [[UsersManager sharedManager] find:[obj intValue]];
                    
                    if(user != nil) {
                        [users addObject:user];
                    }
                }];
            }
        }
        
    } else if([action isKindOfClass:[TL_messageActionChatCreate class]]) {
        
        actionText = [NSString stringWithFormat:NSLocalizedString(@"MessageAction.Service.CreatedChat",nil), action.title];
        
    } else if([action isKindOfClass:[TL_messageActionChatDeleteUser class]]) {
        
        if(action.user_id != message.from_id) {
            TLUser *user = [[UsersManager sharedManager] find:action.user_id];
            if(user != nil) {
                [users addObject:user];
            }
            actionText = NSLocalizedString(@"MessageAction.Service.KickedGroup",nil);
        } else {
            actionText = NSLocalizedString(@"MessageAction.Service.LeftGroup",nil);
        }
    } else if([action isKindOfClass:[TL_messageActionEncryptedChat class]] || [action isKindOfClass:[TL_messageActionBotDescription class]]) {
        actionText = action.title;
    } else if([action isKindOfClass:[TL_messageActionSetMessageTTL class]]) {
        actionText = [MessagesUtils selfDestructTimer:[(TL_messageActionSetMessageTTL *)action ttl]];
    } else if([action isKindOfClass:[TL_messageActionChatJoinedByLink class]]) {
        actionText = NSLocalizedString(@"MessageAction.Service.JoinedGroupByLink", nil);
    } else if([action isKindOfClass:[TL_messageActionChannelCreate class]]) {
         actionText = NSLocalizedString(@"MessageAction.Service.ChannelCreated", nil);
    }  else if([action isKindOfClass:[TL_messageActionChannelMigrateFrom class]] || [action isKindOfClass:[TL_messageActionChatMigrateTo class]]) {
        actionText = NSLocalizedString(@"MessageAction.Service.ChatMigrated", nil);
        user = nil;
    } else if([action isKindOfClass:[TL_messageActionPinMessage class]]) {
        actionText = NSLocalizedString(@"MessageAction.Service.PinMessage", nil);
        
        if(!message.replyMessage || (message.replyMessage.media == nil && message.replyMessage.message.length == 0)) {
            actionText = NSLocalizedString(@"Message.PinnedDeletedMessage", nil);
        } else if(message.replyMessage.media == nil || [message.replyMessage.media isKindOfClass:[TL_messageMediaWebPage class]]) {
            
            BOOL addDot = message.replyMessage.message.length > 30;
            
            actionText = [NSString stringWithFormat:actionText, [[message.replyMessage.message stringByReplacingOccurrencesOfString:@"\n" withString:@" "] substringWithRange:NSMakeRange(0, MIN(30,message.replyMessage.message.length))]];
            
            if(addDot) {
                actionText = [actionText stringByAppendingString:@"..."];
            }
        } else {
            
            NSString *caption = message.replyMessage.media.caption;
            message.replyMessage.media.caption = @"";
            NSString *media = [self mediaMessage:message.replyMessage];
            message.replyMessage.media.caption = caption;
            if(![media isEqualToString:@"GIF"]) {
                media = [media lowercaseString];
            }
            
            actionText = [NSString stringWithFormat:NSLocalizedString(@"Message.PinnedMediaHeader", nil),media];
        }
        
        
    } else if([action isKindOfClass:[TL_messageActionGameScore class]]) {
        
        actionText = [NSString stringWithFormat:NSLocalizedString(action.score > 1 ? @"Message.Action.GameScoredPluar" : action.score == 0 ? @"Message.Action.GameScoredZero" : @"Message.Action.GameScoredSingular", nil),action.score];
    } else if ([action isKindOfClass:[TL_messageActionPhoneCall class]]) {
        NSString *name = action.reason.className;
        if ([action.reason isKindOfClass:[TL_phoneCallDiscardReasonHangup class]]) {
            name = [name stringByAppendingString:@"_incoming"];
            actionText = NSLocalizedString(name, nil);
            actionText = [NSString stringWithFormat:actionText, [NSString durationTransformedValue:action.duration],@""];
        } else {
            actionText = NSLocalizedString(name, nil);
        }
        user = nil;
    }
    
    if([action isKindOfClass:[TL_messageActionBotDescription class]]) {
        
        attributedString = [[NSMutableAttributedString alloc] init];
        
        NSRange range = [attributedString appendString:NSLocalizedString(@"Bot.WhatBotCanDo", nil) withColor:TEXT_COLOR];
        [attributedString setFont:[SettingsArchiver fontMedium13] forRange:range];
        [attributedString setAlignment:NSCenterTextAlignment range:range];
        [attributedString appendString:@"\n\n"];
        range = [attributedString appendString:actionText withColor:TEXT_COLOR];
        [attributedString setFont:[SettingsArchiver font13] forRange:range];
        [attributedString setAlignment:NSLeftTextAlignment range:range];
        
        return attributedString;
    }
    
    NSRange start = NSMakeRange(NSNotFound, 0);
    if(user)
        start = [attributedString appendString:[user fullName] withColor:LINK_COLOR];
    
    if(message.from_id > 0 && start.location != NSNotFound) {
        [attributedString setLink:[TMInAppLinks userProfile:user.n_id] forRange:start];
        [attributedString setFont:[SettingsArchiver fontMedium125] forRange:start];
    }
    
    start = [attributedString appendString:[NSString stringWithFormat:@" %@ ", actionText] withColor:NSColorFromRGB(0xaeaeae)];
    [attributedString setFont:[SettingsArchiver font125] forRange:start];
    
    
    if([action isKindOfClass:[TL_messageActionGameScore class]]) {
        __block TLGame *game = message.replyMessage.media.game;
        
       
        if(game) {
            //[attributedString appendString:@" "];
            NSRange gameLink = [attributedString appendString:game.short_name withColor:LINK_COLOR];
            [attributedString setLink:[NSString stringWithFormat:@"chat://showreplymessage/?peer_class=%@&peer_id=%d&msg_id=%d&from_msg_id=%d",NSStringFromClass(message.to_id.class),message.peer_id,message.reply_to_msg_id,message.n_id] forRange:gameLink];
            [attributedString setFont:[SettingsArchiver fontMedium125] forRange:gameLink];
        }
        
        
    }
    
    if(users.count > 0) {
        
        [users enumerateObjectsUsingBlock:^(TLUser *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSRange start = [attributedString appendString:[obj fullName] withColor:LINK_COLOR];
            [attributedString setLink:[TMInAppLinks userProfile:obj.n_id] forRange:start];
            [attributedString setFont:[SettingsArchiver fontMedium125] forRange:start];
            
            if(idx != users.count -1) {
                [attributedString appendString:@", " withColor:NSColorFromRGB(0xaeaeae)];
            }
            
        }];
        
    }
    
    if(title) {
        start = [attributedString appendString:[NSString stringWithFormat:@"\"%@\"", title] withColor:NSColorFromRGB(0xaeaeae)];
        [attributedString setFont:[SettingsArchiver fontMedium125] forRange:start];
    }
    
    return attributedString;
}

+ (NSImage *) dialogPhotoForUid:(int)uid {
    int avatar = abs(uid) % 8;
    return [NSImage imageNamed:[NSString stringWithFormat:@"DialogListAvatar%d", avatar + 1]];
}

+ (NSImage *) messagePhotoForUid:(int)uid {
    int avatar = abs(uid) % 8;
    return [NSImage imageNamed:[NSString stringWithFormat:@"ConversationAvatar%d", avatar + 1]];
}


+ (NSColor *) colorForUserId:(int)uid {
    //e76568 - e88f4e - 49ae5a - 3991c7 - 606ce5 - a663d0
    
    static NSMutableDictionary *cacheColorIds;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cacheColorIds = [[NSMutableDictionary alloc] init];
    });
    
    
    int colorMask;
    
    if(cacheColorIds[@(uid)]) {
        colorMask = [cacheColorIds[@(uid)] intValue];
    } else {
        const int numColors = 8;
        
        if(uid != -1) {
            char buf[16];
            snprintf(buf, 16, "%d%d", uid, [UsersManager currentUserId]);
            unsigned char digest[CC_MD5_DIGEST_LENGTH];
            CC_MD5(buf, (unsigned) strlen(buf), digest);
            colorMask = ABS(digest[ABS(uid % 16)]) % numColors;
        } else {
            colorMask = -1;
        }
        
        cacheColorIds[@(uid)] = @(colorMask);
    }
    
    
    static const int colors[] = {0xe76568,0xe88f4e,0x49ae5a,0x3991c7,0x606ce5,0xa663d0};
    
    int color = colors[colorMask % (sizeof(colors) / sizeof(colors[0]))];
    
    return  NSColorFromRGB(color);
}

+ (NSString *) mediaMessage:(TLMessage *)message {
    
    if(message.media.caption.length > 0) {
        return message.media.caption;
    }
    
    TLDocument *document = message.media.document ? message.media.document : message.media.bot_result.document;
    
    if([message.media isKindOfClass:[TL_messageMediaPhoto class]]) {
        return  NSLocalizedString(@"ChatMedia.Photo", nil);
    } else if([message.media isKindOfClass:[TL_messageMediaContact class]]) {
        return NSLocalizedString(@"ChatMedia.Contact", nil);
    } else if([message.media isKindOfClass:[TL_messageMediaVideo class]]) {
        return NSLocalizedString(@"ChatMedia.Video", nil);
    } else if([message.media isKindOfClass:[TL_messageMediaGeo class]] || [message.media isKindOfClass:[TL_messageMediaVenue class]]) {
        return NSLocalizedString(@"ChatMedia.Location", nil);
    }  else if(document) {
        
        if(document.isGif) {
            return @"GIF";
        }
        
        if(document.isVideo) {
            return NSLocalizedString(@"ChatMedia.Video", nil);
        }
        
        if(message.media.document.isVoice) {
            return NSLocalizedString(@"ChatMedia.Voice", nil);
        }
        if(message.media.document.isAudio) {
            
            TL_documentAttributeAudio *audio = ( TL_documentAttributeAudio *) [message.media.document attributeWithClass:[TL_documentAttributeAudio class]];
            
            NSString *perfomer = [audio.performer trim];
            NSString *title = [audio.title trim];
            
            NSString *result = NSLocalizedString(@"ChatMedia.File", nil);
            if(perfomer.length > 0 || title.length > 0) {
                result = [NSString stringWithFormat:@"%@ — %@",perfomer,title];
            }
            
            return result;
        }
        

        return [message.media.document isSticker] ? message.media.document.stickerAttr.alt.length > 0 ? [NSString stringWithFormat:@"%@ %@",message.media.document.stickerAttr.alt,NSLocalizedString(@"Sticker", nil)] : NSLocalizedString(@"Sticker", nil) : (message.media.document.file_name.length == 0 ? NSLocalizedString(@"ChatMedia.File", nil) : message.media.document.file_name);
    } else if([message.media isKindOfClass:[TL_messageMediaGame class]]) {
         return [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"ChatMedia.Game", nil),message.media.game.title];
    } else {
        
        if([message.media.bot_result.send_message isKindOfClass:[TL_botInlineMessageText class]]) {
            return message.message;
        }
        
        NSString *mime_type = message.media.bot_result.document ? message.media.bot_result.document.mime_type : message.media.bot_result.content_type;
        
        if(([message.media.bot_result.type isEqualToString:kBotInlineTypeGif])) {
            return @"GIF";
        } else if([message.media.bot_result.type isEqualToString:kBotInlineTypePhoto]) {
            return  NSLocalizedString(@"ChatMedia.Photo", nil);
        } else if([message.media.bot_result.type isEqualToString:kBotInlineTypeAudio]) {
            
            if([mime_type isEqualToString:@"audio/ogg"])
                 return  NSLocalizedString(@"ChatMedia.Voice", nil);
            else
                return  NSLocalizedString(@"ChatMedia.Audio", nil);
            
        } else if([message.media.bot_result.type isEqualToString:kBotInlineTypeVideo]) {
            return  NSLocalizedString(@"ChatMedia.Video", nil);
        } else if([message.media.bot_result.type isEqualToString:kBotInlineTypeFile]) {
            return  NSLocalizedString(@"ChatMedia.File", nil);
        } else if([message.media.bot_result.type isEqualToString:kBotInlineTypeVenue]) {
            return  NSLocalizedString(@"ChatMedia.Location", nil);
        } else if([message.media.bot_result.type isEqualToString:kBotInlineTypeContact]) {
            return  NSLocalizedString(@"ChatMedia.Contact", nil);
        } else if([message.media.bot_result.type isEqualToString:kBotInlineTypeSticker]) {
            return NSLocalizedString(@"Sticker", nil);
        } else if([message.media.bot_result.type isEqualToString:kBotInlineTypeGame]) {
            return [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"ChatMedia.Game", nil),message.media.bot_result.title];
        }

        
        if(message.action != nil) {
            return [self serviceMessage:message forAction:message.action];
        }
        
        if([message.media isKindOfClass:[TL_messageMediaEmpty class]] || message.media == nil || [message.media isKindOfClass:[TL_messageMediaWebPage class]]) {
            return message.message;
        }
        
        return NSLocalizedString(@"ChatMedia.Unsupported", nil);
    }
    
}


+(NSString *)muteUntil:(int)mute_until {
    
    int until = mute_until - [[MTNetwork instance] getTime];
    
    
    
    int days = until / (60 * 60 * 24);
    int hours = until / (60 * 60);
    int minutes = until / 60;
    int seconds = until;
    
    if(until < 0) {
        return NSLocalizedString(@"Notification.Enabled", nil);
    }
    
    if(days > 100) {
        return NSLocalizedString(@"Notification.Disabled", nil);
    }
    
    if(days > 0) {
        return [NSString stringWithFormat:NSLocalizedString(days > 1 ? @"Notification.EnableInDays" : @"Notification.EnableInDay", nil),days];
    } else if(hours > 0) {
        return [NSString stringWithFormat:NSLocalizedString(hours > 1 ? @"Notification.EnableInHours" : @"Notification.EnableInHour", nil),hours];
    } else if(minutes > 0) {
        return [NSString stringWithFormat:NSLocalizedString(minutes > 1 ? @"Notification.EnableInMinutes" : @"Notification.EnableInMinute", nil),minutes];
    } else if(seconds > 0) {
        return [NSString stringWithFormat:NSLocalizedString(seconds > 1 ? @"Notification.EnableInSeconds" : @"Notification.EnableInSecond", nil),minutes];
    }
    
    
    return @"";
}


+(NSDictionary *)conversationLastData:(TL_conversation *)conversation {
    
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    
    NSAttributedString *messageText = [MessagesUtils conversationLastText:conversation.lastMessage conversation:conversation];
    
    int time = conversation.isPinned ? conversation.lastMessage ? conversation.lastMessage.date : [[MTNetwork instance] getTime] : conversation.last_message_date;
    time -= [[MTNetwork instance] getTime] - [[NSDate date] timeIntervalSince1970];
    
    
    NSMutableAttributedString *dateText = [[NSMutableAttributedString alloc] init];
    [dateText setSelectionColor:NSColorFromRGB(0xffffff) forColor:GRAY_TEXT_COLOR];
    [dateText setSelectionColor:GRAY_TEXT_COLOR forColor:NSColorFromRGB(0x333333)];
    [dateText setSelectionColor:NSColorFromRGB(0xcbe1f2) forColor:DARK_BLUE];
    
    if(messageText.length > 0) {
        NSString *dateStr = [TGDateUtils stringForMessageListDate:time];
        [dateText appendString:dateStr withColor:GRAY_TEXT_COLOR];
        data[@"messageText"] = messageText;
    } else {
        [dateText appendString:@"" withColor:NSColorFromRGB(0xaeaeae)];
    }
    
    [dateText setFont:TGSystemFont(12) forRange:dateText.range];
   
     data[@"dateText"] = dateText;
    
    NSSize dateSize;
    
    dateSize = [dateText size];
    dateSize.width+=5;
    dateSize.width = ceil(dateSize.width);
    dateSize.height = ceil(dateSize.height);
    
    data[@"dateSize"] = [NSValue valueWithSize:dateSize];
    
    
    
    NSString *unreadText;
    NSSize unreadTextSize;
    
    if(conversation.unread_count > 0) {
        NSString *unreadTextCount;
        
        if(conversation.unread_count < 1000)
            unreadTextCount = [NSString stringWithFormat:@"%d", conversation.unread_count];
        else
            unreadTextCount = [@(conversation.unread_count) prettyNumber];
        
        NSDictionary *attributes =@{
                                    NSForegroundColorAttributeName: [NSColor whiteColor],
                                    NSFontAttributeName: TGSystemBoldFont(10)
                                    };
        unreadText = unreadTextCount;
        NSSize size = [unreadTextCount sizeWithAttributes:attributes];
        size.width = ceil(size.width);
        size.height = ceil(size.height);
        unreadTextSize = size;
        
        
        data[@"unreadText"] = unreadText;
        
        data[@"unreadTextSize"] = [NSValue valueWithSize:unreadTextSize];
        
    }
    
    
    return data;
    
}

+(NSString *)timerString:(int)until {
    int days = until / (60 * 60 * 24);
    int hours = until / (60 * 60);
    int minutes = until / 60 % 60;
    int seconds = until;
    
    NSString *s = @"";
    
    
    if(days) {
        if(days == 1)
            s = [s stringByAppendingString:[NSString stringWithFormat:NSLocalizedString(@"Timer.DayDate", nil),days]];
        else if(days > 1)
            s = [s stringByAppendingString:[NSString stringWithFormat:NSLocalizedString(@"Timer.DaysDate", nil),days]];
    }
    if(hours) {
        
        if(days)
            s = [s stringByAppendingString:@" "];
        
        if(hours == 1)
            s = [s stringByAppendingString:[NSString stringWithFormat:NSLocalizedString(@"Timer.HourDate", nil),hours]];
        else if(hours > 1)
            s = [s stringByAppendingString:[NSString stringWithFormat:NSLocalizedString(@"Timer.HoursDate", nil),hours]];
    }
    if(minutes) {
        
        if(hours)
            s = [s stringByAppendingString:@" "];
        
        if(minutes == 1)
            s = [s stringByAppendingString:[NSString stringWithFormat:NSLocalizedString(@"Timer.MinuteDate", nil),minutes]];
        else if(minutes > 1)
            s = [s stringByAppendingString:[NSString stringWithFormat:NSLocalizedString(@"Timer.MinutesDate", nil),minutes]];
    }
    
    if(seconds) {
        if(days == 0 && hours == 0 ) {
            
            if(minutes)
                s = [s stringByAppendingString:@" "];
            
            s = seconds == 1 ? [s stringByAppendingString:[NSString stringWithFormat:NSLocalizedString(@"Timer.SecondDate", nil),seconds]] : [s stringByAppendingString:[NSString stringWithFormat:NSLocalizedString(@"Timer.SecondsDate", nil),seconds]];
        }
    }
    
    

    
   
    
   
    return s;
}


@end
