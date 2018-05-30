//
//  MessageTableItemText.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/26/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableItemText.h"
#import "TMElements.h"
#import "NS(Attributed)String+Geometrics.h"
#import "MessagesUtils.h"
#import "NSAttributedString+Hyperlink.h"
#import "NSString+Extended.h"
#import "TGWebpageYTObject.h"
#import "MessageTableCellTextView.h"

@interface MessageTableItemText()<SettingsListener>
@property (nonatomic, strong) NSMutableAttributedString *nameAttritutedString;
@property (nonatomic, strong) NSMutableAttributedString *forwardAttributedString;
@property (nonatomic,strong) id requestKey;

@property (nonatomic,assign) BOOL isEmojiMessage;


@end

@implementation MessageTableItemText

- (id) initWithObject:(TL_localMessage *)object {
    self = [super initWithObject:object];
    
    self.textAttributed = [[NSMutableAttributedString alloc] init];
    NSString *message = [object.message trim];
    [self.textAttributed appendString:message withColor:TEXT_COLOR];
    [self.textAttributed setAlignment:NSLeftTextAlignment range:self.textAttributed.range];
    
    [self updateEntities];
    [self updateWebPage];
    
    return self;
}


-(void)updateLinkAttributesByMessageEntities {
    
    @try {
        [self.textAttributed removeAttribute:NSLinkAttributeName range:self.textAttributed.range];
        
        _links = [[NSArray alloc] init];
        
        NSMutableArray *links = [NSMutableArray array];
        
        if(self.message.entities.count > 0)
        {
            
            __block NSRange nextRange = NSMakeRange(0, self.textAttributed.string.length);
            
            [self.message.entities enumerateObjectsUsingBlock:^(TLMessageEntity *obj, NSUInteger idx, BOOL *stop) {
                
                if([obj isKindOfClass:[TL_messageEntityUrl class]] ||[obj isKindOfClass:[TL_messageEntityTextUrl class]] || [obj isKindOfClass:[TL_messageEntityMention class]] || [obj isKindOfClass:[TL_messageEntityBotCommand class]] || [obj isKindOfClass:[TL_messageEntityHashtag class]] || [obj isKindOfClass:[TL_messageEntityEmail class]] || [obj isKindOfClass:[TL_messageEntityPre class]] || [obj isKindOfClass:[TL_messageEntityCode class]] || [obj isKindOfClass:[TL_messageEntityMentionName class]]) {
                    
                    
                    if([obj isKindOfClass:[TL_messageEntityMention class]] && (self.linkParseTypes() & URLFindTypeMentions) == 0)
                        return;
                    if([obj isKindOfClass:[TL_messageEntityHashtag class]] && (self.linkParseTypes() & URLFindTypeHashtags) == 0)
                        return;
                    if(([obj isKindOfClass:[TL_messageEntityUrl class]] || [obj isKindOfClass:[TL_messageEntityTextUrl class]]) && (self.linkParseTypes() & URLFindTypeLinks) == 0)
                        return;
                    
                    if([obj isKindOfClass:[TL_messageEntityBotCommand class]] && ((self.linkParseTypes() & URLFindTypeBotCommands) == 0) )
                        return;
                    
                    if([obj isKindOfClass:[TL_messageEntityBotCommand class]] && self.message.conversation.type == DialogTypeChat)
                        if(self.message.chat.chatFull && self.message.chat.chatFull.bot_info.count == 0)
                            return;
                    
                    
                    NSRange range = [self checkAndReturnEntityRange:obj];
                    
                    NSString *link = [self.message.message substringWithRange:range];
                    
                    if([obj isKindOfClass:[TL_messageEntityMentionName class]]) {
                        link = [TMInAppLinks peerProfile:[TL_peerUser createWithUser_id:obj.user_id]];
                    }
                    
                    
                    nextRange = NSMakeRange(range.location + range.length, self.textAttributed.length - (range.location + range.length));
                    
                    if(range.location != NSNotFound) {
                        
                        if([obj isKindOfClass:[TL_messageEntityTextUrl class]]) {
                            link = obj.url;
                        }
                        if(([obj isKindOfClass:[TL_messageEntityTextUrl class]] || [obj isKindOfClass:[TL_messageEntityUrl class]]))
                            [links addObject:link];
                        
                        
                        if([obj isKindOfClass:[TL_messageEntityCode class]]) {
                            [self.textAttributed addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:range];
                            
                        } else if([obj isKindOfClass:[TL_messageEntityPre class]]) {
                            [self.textAttributed addAttribute:NSForegroundColorAttributeName value:DARK_GREEN range:range];
                        } else {
                            [self.textAttributed addAttribute:NSLinkAttributeName value:link range:range];
                            [self.textAttributed addAttribute:NSForegroundColorAttributeName value:LINK_COLOR range:range];
                        }
                        
                    }
                    
                }
                
            }];
            
        } else {
            links = (NSMutableArray *) [self.textAttributed detectAndAddLinks:self.linkParseTypes()];
        }
        
        
        _links = links;
        
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
        
        if(_links.count > 0) {
            
            NSString *obj = _links[0];
            
            NSString *header = obj;
            
            if(![obj hasPrefix:@"http://"] && ![obj hasPrefix:@"https://"] && ![obj hasPrefix:@"ftp://"])
            header = obj;
            else  {
                NSURLComponents *components = [[NSURLComponents alloc] initWithString:obj];
                header = components.host;
            }
            
            
            
            NSRange r = [attr appendString:[header stringByAppendingString:@"\n\n"] withColor:TEXT_COLOR];
            [attr setCTFont:TGSystemMediumFont(13) forRange:r];
            
            NSRange range = [attr appendString:obj];
            
            
            
            [attr addAttribute:NSLinkAttributeName value:obj range:range];
            [attr addAttribute:NSForegroundColorAttributeName value:LINK_COLOR range:range];
            [attr addAttribute:NSCursorAttributeName value:[NSCursor pointingHandCursor] range:range];
            [attr addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleNone] range:range];
            
            
            [attr addAttribute:NSFontAttributeName value:TGSystemFont(12.5) range:range];
            

        }

        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineBreakMode = NSLineBreakByTruncatingTail;
        
        [attr addAttribute:NSParagraphStyleAttributeName value:style range:attr.range];
        
        
        _allAttributedLinks = [attr copy];
    }
    @catch (NSException *exception) {
        
    }
    

    
}

-(void)updateEntities {
    [self updateLinkAttributesByMessageEntities];
    [self updateFontAttributesByEntities];
    [self.textAttributed fixEmoji];
}

-(void)updateFontAttributesByEntities {
    
    @try {
        [self.textAttributed removeAttribute: (NSString *)kCTFontAttributeName range:self.textAttributed.range];
        
        
        [self.textAttributed setCTFont:TGSystemFont([self fontSize]) forRange:self.textAttributed.range];
        
        
        NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
        style.lineSpacing = 0;
        style.alignment = NSLeftTextAlignment;
        
        [self.textAttributed addAttribute:NSParagraphStyleAttributeName value:style range:self.textAttributed.range];
        
        [self.message.entities enumerateObjectsUsingBlock:^(TLMessageEntity *obj, NSUInteger idx, BOOL *stop) {
            
            NSRange range = [self checkAndReturnEntityRange:obj];
            
            if([obj isKindOfClass:[TL_messageEntityBold class]]) {
                
                
                
                [self.textAttributed addAttribute:NSFontAttributeName value:TGSystemMediumFont([self fontSize]) range:range];
            } else if([obj isKindOfClass:[TL_messageEntityItalic class]]) {
                
                
                [self.textAttributed addAttribute:NSFontAttributeName value:TGSystemItalicFont([self fontSize]) range:range];
            } else if([obj isKindOfClass:[TL_messageEntityCode class]] || [obj isKindOfClass:[TL_messageEntityPre class]]) {
                [self.textAttributed setCTFont:[NSFont fontWithName:@"Courier" size:[self fontSize]] forRange:range];
            }
            
        }];

    }
    @catch (NSException *exception) {
        int bp = 0;
    }
    
}


-(NSRange)checkAndReturnEntityRange:(TLMessageEntity *)obj {
    
    int location = MIN((int)self.message.message.length, obj.offset);
    
    int length = ((int)self.message.message.length - (location + obj.length)) >= 0 ? obj.length : 0;
    
    return NSMakeRange(location, length);
}

-(void)updateMessageFont {
   
    [self updateFontAttributesByEntities];

    
    if(self.blockWidth != 0)
        [self makeSizeByWidth:self.blockWidth];
}

-(void)didChangeSettingsMask:(SettingsMask)mask {
    [self updateMessageFont];
}

- (BOOL)makeSizeByWidth:(int)width {
    [_webpage makeSize:width - self.defaultOffset];
    
    [_game makeSize:width - self.defaultOffset];
    
    _allAttributedLinksSize = [_allAttributedLinks coreTextSizeForTextFieldForWidth:width];
    _textSize = [_textAttributed coreTextSizeForTextFieldForWidth:width];
    
    _textSize.width = width;
    
    if ([self isGame]) {
        width = self.game.size.width;
    }
    
    self.contentSize = self.blockSize = NSMakeSize(width, _textSize.height + ([self isWebPage] ? [_webpage blockHeight] + self.defaultContentOffset : 0) + ([self isGame] ? _game.size.height + self.defaultContentOffset : 0));
    
    return [super makeSizeByWidth:width];
}


-(void)updateWebPage {
    
    
    if([self isWebPage]) {
        
        remove_global_dispatcher(_requestKey);

        _webpage = [TGWebpageObject objectForWebpage:self.message.media.webpage tableItem:self]; // its only youtube.

    } else if([self isWebPagePending]) {
        
        remove_global_dispatcher(_requestKey);
        
        
        _requestKey = dispatch_in_time(self.message.media.webpage.date, ^{
            
            if([self.message.media.webpage isKindOfClass:[TL_secretWebpage class]]) {
                
                
               
                
                [RPCRequest sendRequest:[TLAPI_messages_getWebPagePreview createWithMessage:self.message.media.webpage.url] successHandler:^(RPCRequest *request, TL_messageMediaWebPage *response) {
                    
                    if([response isKindOfClass:[TL_messageMediaWebPage class]]) {
                        
                        if(![response.webpage isKindOfClass:[TL_webPagePending class]]) {
                            [Storage addWebpage:response.webpage forLink:display_url(response.webpage.url)];
                            
                            self.message.media = response;
                            
                            [self.message save:NO];
                            
                            if([self.message.media.webpage isKindOfClass:[TL_webPage class]]) {
                                [Notification perform:UPDATE_WEB_PAGE_ITEMS data:@{KEY_DATA:@{@(self.message.peer_id):@[@(self.message.n_id)]},KEY_WEBPAGE:self.message.media.webpage}];
                            }
                            
                        } else {
                            self.message.media.webpage.date = response.webpage.date;
                            
                            [self updateWebPage];
                        }
                        
                    } else if([response isKindOfClass:[TL_messageMediaEmpty class]]) {
                        [Storage addWebpage:[TL_webPageEmpty createWithN_id:0] forLink:display_url(self.message.media.webpage.url)];
                    }
                    
                    
                    
                } errorHandler:^(RPCRequest *request, RpcError *error) {
                    
                }];
            } else {
                [RPCRequest sendRequest:[TLAPI_messages_getMessages createWithN_id:[@[@(self.message.n_id)] mutableCopy]] successHandler:^(RPCRequest *request, TL_messages_messages *response) {
                    
                    if(response.messages.count == 1) {
                        
                        TLMessage *msg = response.messages[0];
                        
                        if(![msg isKindOfClass:[TL_messageEmpty class]]) {
                            self.message.media = msg.media;
                        }
                        
                        
                        [self.message save:NO];
                        
                        if([self.message.media.webpage isKindOfClass:[TL_webPage class]]) {
                            [Notification perform:UPDATE_WEB_PAGE_ITEMS data:@{KEY_DATA:@{@(self.message.peer_id):@[@(self.message.n_id)]},KEY_WEBPAGE:self.message.media.webpage}];
                        }
                        
                    }
                    
                    
                } errorHandler:^(RPCRequest *request, RpcError *error) {
                    
                    
                }];
            }
            
        });
        
    } else if ([self isGame]) {
        _game = [[TGGameObject alloc] initWithGame:self.message.media.game message:self.message text:[self.textAttributed copy]];
        self.textAttributed = nil;
    }

}

-(BOOL)isGame {
    return [self.message.media isKindOfClass:[TL_messageMediaGame class]] || [self.message.media.bot_result.type isEqualToString:kBotInlineTypeGame];
}

-(BOOL)isWebPage {
    return [self.message.media.webpage isKindOfClass:[TL_webPage class]];
}

-(BOOL)isWebPagePending {
    return [self.message.media.webpage isKindOfClass:[TL_webPagePending class]] || [self.message.media.webpage isKindOfClass:[TL_secretWebpage class]];
}


-(BOOL)isset {
    
    if([self isWebPage]) {
        
        TLPhotoSize *s = (TLPhotoSize *)[self.message.media.webpage.photo.sizes lastObject];
        
        return [FileUtils checkNormalizedSize:s.location.path checksize:s.size]  && self.downloadItem == nil && self.messageSender == nil;
    }
    
    return YES;
}

-(Class)viewClass {
    return [MessageTableCellTextView class];
}


-(int)fontSize {
    if(_isEmojiMessage)
        return 36;
    else
        return [super fontSize];
}

-(int)contentHeaderOffset {
    return 3;
}

-(void)dealloc {
    //[SettingsArchiver removeEventListener:self];
}

@end
