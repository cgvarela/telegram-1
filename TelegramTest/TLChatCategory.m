//
//  TLChatCategory.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 2/26/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TLChatCategory.h"
#import "NSNumber+NumberFormatter.h"
@implementation TLChat (Category)

DYNAMIC_PROPERTY(DType);

- (TLChatType) type {
    NSNumber *type = [self getDType];
    if(!type)
        type = [NSNumber numberWithInt:[self rebuildType]];
    return [type intValue];
}

DYNAMIC_PROPERTY(DDialog);

-(TL_conversation *)dialog {
    TL_conversation *dialog = [self getDDialog];
    
    if(!dialog) {
            dialog = [[DialogsManager sharedManager] findByChatId:self.n_id];
        [self setDDialog:dialog];
    }
    
    if(!dialog) {
        dialog = [[Storage manager] selectConversation:self.peer];
        
        if(!dialog) {
            dialog = [[DialogsManager sharedManager] createDialogForChat:self];
                
        } else
            [[DialogsManager sharedManager] add:@[dialog]];
        
        [self setDDialog:dialog];
    }
    
    return dialog;

}

DYNAMIC_PROPERTY(ChatFull);

-(TLChatFull *)chatFull  {
    
    TLChatFull *chatFull = [self getChatFull];
    
    if(!chatFull)
    {
        chatFull = [[ChatFullManager sharedManager] find:self.n_id];
        [self setChatFull:chatFull];
    }
    
    return chatFull;
}

- (void) setType:(TLChatType)type {
    [self setDType:[NSNumber numberWithInt:type]];
}


- (TLChatType)rebuildType {
    int type;
    
    if([self isKindOfClass:[TL_chatForbidden class]] || [self isKindOfClass:[TL_channelForbidden class]])
        type = TLChatTypeForbidden;
    else if([self isKindOfClass:[TL_chatEmpty class]])
        type = TLChatTypeEmpty;
    else
        type = TLChatTypeNormal;
   
    
    [self setType:type];
    return type;
}

DYNAMIC_PROPERTY(DIALOGTITLE);

- (NSAttributedString *) dialogTitle {
    NSMutableAttributedString *dialogTitleAttributedString = [[NSMutableAttributedString alloc] init];

    
    [dialogTitleAttributedString appendString:self.cropTitle withColor:NSColorFromRGB(0x333333)];
    [dialogTitleAttributedString setSelectionColor:NSColorFromRGB(0xffffff) forColor:NSColorFromRGB(0x333333)];
    [dialogTitleAttributedString setFont:TGSystemFont(14) forRange:dialogTitleAttributedString.range];
    

    [self setDIALOGTITLE:dialogTitleAttributedString];
    
    return [self getDIALOGTITLE];

}


- (NSSize)dialogTitleSize {
    return [[self dialogTitle] sizeForTextFieldForWidth:INT32_MAX];
}

DYNAMIC_PROPERTY(TITLEFORMESSAGE);

- (NSAttributedString *) titleForMessage {
    NSMutableAttributedString *dialogTitleAttributedString = [[NSMutableAttributedString alloc] init];
    
    [dialogTitleAttributedString appendString:self.cropTitle withColor:NSColorFromRGB(0x222222)];
    [dialogTitleAttributedString setFont:TGSystemFont(14) forRange:dialogTitleAttributedString.range];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSCenterTextAlignment];
    [dialogTitleAttributedString addAttribute:NSParagraphStyleAttributeName value:style range:dialogTitleAttributedString.range];
    
    [self setTITLEFORMESSAGE:dialogTitleAttributedString];
    
    return [self getTITLEFORMESSAGE];
}

-(NSString *)cropTitle {
    return self.title.length > 50 ? [self.title substringToIndex:50] : self.title;
}

- (NSAttributedString *)titleForChatInfo {
    return [[NSAttributedString alloc] initWithString:self.cropTitle];
}

- (NSAttributedString *)statusAttributedString {
    return [[NSMutableAttributedString alloc] initWithString:@"string"];
}


static NSTextAttachment *channelVerifyAttachment() {
    static NSTextAttachment *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [NSMutableAttributedString textAttachmentByImage:[image_Verify() imageWithInsets:NSEdgeInsetsMake(0, 0, 0, 0)]];
    });
    return instance;
}

static NSTextAttachment *channelVerifySelectedAttachment() {
    static NSTextAttachment *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [NSMutableAttributedString textAttachmentByImage:[image_VerifyWhite() imageWithInsets:NSEdgeInsetsMake(0, 0, 0, 0)]];
    });
    return instance;
}


- (NSAttributedString *)statusForSearchTableView {
    NSMutableAttributedString *str;
    if(!str) {
        str = [[NSMutableAttributedString alloc] init];
        
        
        if([self isChannel])
        {
            
            [str appendString:self.isMegagroup ? NSLocalizedString(@"Conversation.GroupTitle", nil) : NSLocalizedString(@"Conversation.ChannelTitle", nil) withColor:NSColorFromRGB(0xa9a9a9)];
            
            [str setSelectionColor:NSColorFromRGB(0xffffff) forColor:BLUE_UI_COLOR];
            [str setSelectionColor:NSColorFromRGB(0xfffffe) forColor:NSColorFromRGB(0xa9a9a9)];
            [str setFont:TGSystemFont(13) forRange:str.range];
            
            return str;
        }

        [str appendString:[NSString stringWithFormat:@"%d %@", self.participants_count, self.participants_count > 1 ?  NSLocalizedString(@"Conversation.Members", nil) : NSLocalizedString(@"Conversation.Member", nil)] withColor:NSColorFromRGB(0x9b9b9b)];

        
        int online = [[ChatFullManager sharedManager] getOnlineCount:self.n_id];
        if(online > 0) {
            [str appendString:@", " withColor:NSColorFromRGB(0x9b9b9b)];
            [str appendString:[NSString stringWithFormat:@"%d %@", online, NSLocalizedString(@"Account.Online", @"")] withColor:NSColorFromRGB(0x9b9b9b)];
        }
        
        [str setSelectionColor:NSColorFromRGB(0xffffff) forColor:BLUE_UI_COLOR];
        [str setSelectionColor:NSColorFromRGB(0xfffffe) forColor:NSColorFromRGB(0x9b9b9b)];
        [str setFont:TGSystemFont(13) forRange:str.range];
    }
    return str;
}

- (NSAttributedString *)statusForChatHeader {
    return [self statusForMessagesHeaderView];
}

-(NSAttributedString *)statusForGroupInfo {
    return nil;
}

DYNAMIC_PROPERTY(CHATINFOTITLE);


- (NSAttributedString *)chatInfoTitle {
    
    NSMutableAttributedString *chatInfoTitleAttributedString = [[NSMutableAttributedString alloc] init];
    
    [chatInfoTitleAttributedString appendString:self.title withColor:DARK_BLACK];
    [chatInfoTitleAttributedString setSelectionColor:NSColorFromRGB(0xffffff) forColor:DARK_BLACK];
    
    [chatInfoTitleAttributedString setFont:TGSystemFont(12.5) forRange:chatInfoTitleAttributedString.range];
    
    return chatInfoTitleAttributedString;
}

- (NSAttributedString *)profileTitle {
    NSMutableAttributedString *chatInfoTitleAttributedString = [[NSMutableAttributedString alloc] init];
    
    [chatInfoTitleAttributedString appendString:self.title withColor:TEXT_COLOR];
    [chatInfoTitleAttributedString setSelectionColor:NSColorFromRGB(0xffffff) forColor:TEXT_COLOR];
    [chatInfoTitleAttributedString setAlignment:NSLeftTextAlignment range:chatInfoTitleAttributedString.range];
    [chatInfoTitleAttributedString setFont:TGSystemFont(18) forRange:chatInfoTitleAttributedString.range];
    
    return chatInfoTitleAttributedString;
}



- (NSAttributedString *)statusForMessagesHeaderView {
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    
    if([self isChannel])
    {
        
        TLChatFull *fullChat = self.chatFull;
        
        if(fullChat.participants_count > 0) {
            
            if(self.isMegagroup && fullChat.participants_count <= 200) {
                
                 [attributedString appendString:[NSString stringWithFormat:@"%d %@", fullChat.participants_count, fullChat.participants_count > 1 ?  NSLocalizedString(@"Conversation.Members", nil) : NSLocalizedString(@"Conversation.Member", nil)] withColor:NSColorFromRGB(0xa9a9a9)];
                
                int online = [[ChatFullManager sharedManager] getOnlineCount:self.n_id];
                if(online > 0) {
                    [attributedString appendString:@", " withColor:NSColorFromRGB(0xa9a9a9)];
                    [attributedString appendString:[NSString stringWithFormat:@"%d %@", online, NSLocalizedString(@"Account.Online", @"")] withColor:NSColorFromRGB(0x9b9b9b)];
                }
            } else
                [attributedString appendString:[NSString stringWithFormat:@"%d %@", fullChat.participants_count, fullChat.participants_count > 1 ?  NSLocalizedString(@"Conversation.Members", nil) : NSLocalizedString(@"Conversation.Member", nil)] withColor:NSColorFromRGB(0xa9a9a9)];
            
        } else {
            [attributedString appendString:self.isMegagroup ? NSLocalizedString(@"Conversation.GroupTitle", nil) : NSLocalizedString(@"Conversation.ChannelTitle", nil) withColor:NSColorFromRGB(0xa9a9a9)];
        }
        
        return attributedString;
    }
    
    [attributedString appendString:[NSString stringWithFormat:@"%d %@", self.participants_count, self.participants_count > 1 ?  NSLocalizedString(@"Conversation.Members", nil) : NSLocalizedString(@"Conversation.Member", nil)] withColor:NSColorFromRGB(0xa9a9a9)];
    
    int online = [[ChatFullManager sharedManager] getOnlineCount:self.n_id];
    if(online > 0) {
        [attributedString appendString:@", " withColor:NSColorFromRGB(0xa9a9a9)];
        [attributedString appendString:[NSString stringWithFormat:@"%d %@", online, NSLocalizedString(@"Account.Online", @"")] withColor:NSColorFromRGB(0x9b9b9b)];
    }
    
    
    [attributedString setFont:TGSystemFont(12) forRange:attributedString.range];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:2];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedString.length)];

    
    return attributedString;
}


- (NSAttributedString *)statusForUserInfoView {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    
    if([self isChannel])
    {
        
        TLChatFull *fullChat = self.chatFull;
        
        if(fullChat.participants_count > 0) {
            
            if(self.isMegagroup && fullChat.participants_count <= 200) {
                
                [attributedString appendString:[NSString stringWithFormat:@"%d %@", fullChat.participants_count, fullChat.participants_count > 1 ?  NSLocalizedString(@"Conversation.Members", nil) : NSLocalizedString(@"Conversation.Member", nil)] withColor:NSColorFromRGB(0xa9a9a9)];
                
                int online = [[ChatFullManager sharedManager] getOnlineCount:self.n_id];
                if(online > 0) {
                    [attributedString appendString:@", " withColor:NSColorFromRGB(0xa9a9a9)];
                    [attributedString appendString:[NSString stringWithFormat:@"%d %@", online, NSLocalizedString(@"Account.Online", @"")] withColor:NSColorFromRGB(0x9b9b9b)];
                }
            } else
            [attributedString appendString:[NSString stringWithFormat:@"%d %@", fullChat.participants_count, fullChat.participants_count > 1 ?  NSLocalizedString(@"Conversation.Members", nil) : NSLocalizedString(@"Conversation.Member", nil)] withColor:NSColorFromRGB(0xa9a9a9)];
            
        } else {
            [attributedString appendString:self.isMegagroup ? NSLocalizedString(@"Conversation.GroupTitle", nil) : NSLocalizedString(@"Conversation.ChannelTitle", nil) withColor:NSColorFromRGB(0xa9a9a9)];
        }
        
        return attributedString;
    }
    
    [attributedString appendString:[NSString stringWithFormat:@"%d %@", self.participants_count, self.participants_count > 1 ?  NSLocalizedString(@"Conversation.Members", nil) : NSLocalizedString(@"Conversation.Member", nil)] withColor:NSColorFromRGB(0xa9a9a9)];
    
    int online = [[ChatFullManager sharedManager] getOnlineCount:self.n_id];
    if(online > 0) {
        [attributedString appendString:@", " withColor:NSColorFromRGB(0xa9a9a9)];
        [attributedString appendString:[NSString stringWithFormat:@"%d %@", online, NSLocalizedString(@"Account.Online", @"")] withColor:NSColorFromRGB(0x9b9b9b)];
    }
    
    
    [attributedString setFont:TGSystemFont(12.5) forRange:attributedString.range];
    
    
    return attributedString;
}

-(id)inputPeer {
    return self.isChannel || [self isKindOfClass:[TL_channelForbidden class]] ? [TL_inputChannel createWithChannel_id:self.n_id access_hash:self.access_hash] : ([self isKindOfClass:[TL_peerSecret class]] ? [TL_inputEncryptedChat createWithChat_id:self.n_id access_hash:self.access_hash] : nil);
}

-(TLPeer *)peer {
    return self.isChannel ? [TL_peerChannel createWithChannel_id:self.n_id] : [TL_peerChat createWithChat_id:self.n_id];
}


-(NSString *)searchString {
    
    NSString *search = [[self.title trim] lowercaseString];
    
    
    NSMutableString *transform = [search mutableCopy];
    CFMutableStringRef bufferRef = (__bridge CFMutableStringRef)transform;
    CFStringTransform(bufferRef, NULL, kCFStringTransformLatinCyrillic, false);
    
    NSMutableString *transformReverse = [search mutableCopy];
    bufferRef = (__bridge CFMutableStringRef)transformReverse;
    CFStringTransform(bufferRef, NULL, kCFStringTransformLatinCyrillic, true);
    
    
    search = [[[[search stringByAppendingString:@" "] stringByAppendingString:transform] stringByAppendingString:@" "] stringByAppendingString:transformReverse];
    
    if(self.username.length > 0)
        search = [[search stringByAppendingString:@" "] stringByAppendingString:self.username];
    
    return search;
    
}

-(BOOL)isKicked {
    return self.flags & (1 << 1);
}


-(BOOL)isModerator {
    return self.flags & (1 << 4);
}

-(BOOL)isVerify {
    return self.flags & (1 << 7);
}

        
-(BOOL)isChannel {
    return [self isKindOfClass:[TL_channel_old43 class]] || [self isKindOfClass:[TL_channel class]] || [self isKindOfClass:[TL_channelForbidden class]] || [self isKindOfClass:[TL_channel_old48 class]];
}

-(BOOL)isManager {
    return [self isAdmin] || [self isEditor] || [self isModerator] || [self isCreator];
}

-(NSString *)usernameLink {
    return self.username.length > 0 ? [NSString stringWithFormat:@"https://telegram.me/%@",self.username] : @"";
}



@end
