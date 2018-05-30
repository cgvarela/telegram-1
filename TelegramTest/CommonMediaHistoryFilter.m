//
//  CommonMediaHistoryFilter.m
//  Telegram
//
//  Created by keepcoder on 09/11/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "CommonMediaHistoryFilter.h"
#import "ChatHistoryController.h"
@implementation CommonMediaHistoryFilter


-(instancetype)init {
    if(self = [super init]) {
        
    }
    
    return self;
}

-(void)remoteRequest:(BOOL)next max_id:(int)max_id hole:(TGMessageHole *)hole callback:(void (^)(id response,ChatHistoryState state))callback {
    
    int maxDate = next ? self.minDate : INT32_MAX;
    int minDate = next ? 0 : self.maxDate;
    
    weak();
    
    self.request = [RPCRequest sendRequest:[TLAPI_messages_search createWithFlags:0 peer:[self.peer inputPeer] q:@"" filter:self.messagesFilter min_date:minDate max_date:maxDate offset:0 max_id:INT32_MAX limit:(int)self.controller.selectLimit] successHandler:^(RPCRequest *request, TL_messages_messages *response) {
        
        NSMutableArray *messages = [response.messages mutableCopy];
        
        [TL_localMessage convertReceivedMessages:messages];
        
        [response.messages removeAllObjects];
        
        [SharedManager proccessGlobalResponse:response];
        
        [messages filterUsingPredicate:[NSPredicate predicateWithFormat:@"self.class != %@",[TL_messageEmpty class]]];
        
        if(callback) {
            callback(messages,messages.count < weakSelf.controller.selectLimit ? ChatHistoryStateFull : ChatHistoryStateRemote);
        }
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
        if(callback) {
            callback(nil,ChatHistoryStateRemote);
        }
        
    } timeout:0 queue:[ChatHistoryController nativeQueue]];
    
}


@end
