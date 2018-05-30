//
//  ShareContactSenterItem.m
//  Messenger for Telegram
//
//  Created by keepcoder on 18.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "ShareContactSenterItem.h"

@interface ShareContactSenterItem ()
@end

@implementation ShareContactSenterItem

-(void)setState:(MessageState)state {
    [super setState:state];
}


-(id)initWithContact:(TLUser *)contact forConversation:(TL_conversation *)conversation additionFlags:(int)additionFlags {
    if(self = [super init]) {
        self.conversation = conversation;
        TL_messageMediaContact *media = [TL_messageMediaContact createWithPhone_number:contact.phone  first_name:contact.first_name last_name:contact.last_name user_id:contact.n_id];
        
        self.message = [MessageSender createOutMessage:@"" media:media conversation:conversation additionFlags:additionFlags];
        

        
        [self.message save:YES];

    }
    return self;
}


-(void)performRequest {
    
    
    TLInputMedia *media = [TL_inputMediaContact createWithPhone_number:self.message.media.phone_number first_name:self.message.media.first_name last_name:self.message.media.last_name];
    
    id request = [TLAPI_messages_sendMedia createWithFlags:[self senderFlags] peer:self.conversation.inputPeer reply_to_msg_id:self.message.reply_to_msg_id media:media random_id:self.message.randomId  reply_markup:[TL_replyKeyboardMarkup createWithFlags:0 rows:[@[]mutableCopy]]];

    
    weak();
    
    self.rpc_request = [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, TLUpdates * response) {
        
        strongWeak();
        
        if(strongSelf != nil) {
            [strongSelf updateMessageId:response];
            
            TL_localMessage *msg = [TL_localMessage convertReceivedMessage:[[strongSelf updateNewMessageWithUpdates:response] message]];
            
            if(msg == nil)
            {
                [strongSelf cancel];
                return;
            }
            
            if(strongSelf.conversation.type != DialogTypeBroadcast)  {
                strongSelf.message.n_id = msg.n_id;
                strongSelf.message.date = msg.date;
                
            }
            
            
            strongSelf.message.dstate = DeliveryStateNormal;
            
            [SharedManager proccessGlobalResponse:response];
            
            [strongSelf.message save:YES];
            
            strongSelf.state = MessageSendingStateSent;
        }
        
       
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        weakSelf.state = MessageSendingStateError;
    } timeout:0 queue:[ASQueue globalQueue]._dispatch_queue];

}


@end
