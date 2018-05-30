//
//  StickerSenderItem.m
//  Telegram
//
//  Created by keepcoder on 19.12.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "StickerSenderItem.h"

@implementation StickerSenderItem


-(id)initWithDocument:(TLDocument *)document forConversation:(TL_conversation*)conversation additionFlags:(int)additionFlags {
    if(self = [super initWithConversation:conversation]) {
        
        self.message = [MessageSender createOutMessage:@"" media:[TL_messageMediaDocument createWithDocument:document caption:@""] conversation:conversation additionFlags:additionFlags];
        
        
        [self.message save:YES];
    }
    
    return self;
}

-(void)performRequest {
    
    id request;
    
    id media = [TL_inputMediaDocument createWithN_id:[TL_inputDocument createWithN_id:self.message.media.document.n_id access_hash:self.message.media.document.access_hash] caption:@""];
    
    request = [TLAPI_messages_sendMedia createWithFlags:[self senderFlags] peer:self.conversation.inputPeer reply_to_msg_id:self.message.reply_to_msg_id media:media random_id:self.message.randomId reply_markup:[TL_replyKeyboardMarkup createWithFlags:0 rows:[@[]mutableCopy]]];

    
    NSMutableArray *signals = [NSMutableArray array];
    
    [signals addObject:[[MTNetwork instance] requestSignal:request queue:[ASQueue globalQueue]]];

    
    [[[SSignal combineSignals:signals] map:^id(NSArray *next) {
        
        return next[0];
        
    }] startWithNext:^(TLUpdates * response) {
        
        [self updateMessageId:response];
        
        TL_localMessage *msg = [TL_localMessage convertReceivedMessage:[[self updateNewMessageWithUpdates:response] message]];
        
        if(msg == nil)
        {
            [self cancel];
            return;
        }
        
        self.message.n_id = msg.n_id;
        self.message.date = msg.date;
        
        self.message.dstate = DeliveryStateNormal;
        
        [self.message save:YES];
        
        self.state = MessageSendingStateSent;
        

        
    } error:^(id error) {
        self.state = MessageSendingStateError;
    } completed:^{
        
    }];
    
}

@end
