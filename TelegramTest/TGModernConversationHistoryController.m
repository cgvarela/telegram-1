//
//  TGModernConversationHistoryController.m
//  Telegram
//
//  Created by keepcoder on 24.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGModernConversationHistoryController.h"
#import "TGObservableObject.h"

#import "TLPeer+Extensions.h"

@interface TGModernConversationHistoryController ()

@property (nonatomic,weak) id<TGModernConversationHistoryControllerDelegate> delegate;
@property (nonatomic,assign) BOOL loadNextAfterLoadChannels;
@property (nonatomic,assign) int channelsOffset;

@property (nonatomic,assign) BOOL needMergeChannels;

@end

@implementation TGModernConversationHistoryController

NSString *const kPullPinnedOnce = @"pinned_pulled7";

-(id)initWithQueue:(ASQueue *)queue delegate:(id<TGModernConversationHistoryControllerDelegate>)delegate {
    
    if(self = [super init]) {
        _queue = queue;
        _delegate = delegate;
        _state = TGModernCHStateLocal;
        


    }
    
    return self;
}




-(void)requestNextConversation {
    
    [_queue dispatchOnQueue:^{
        
        if(_isLoading)
            return;
        
        _isLoading = YES;
        
        [self performLoadNext];
        
    }];
    

}

-(void)performLoadNext {
    
    if(_state == TGModernCHStateLocal)
    {
        
        
        [[Storage manager] dialogsWithOffset:_offset limit:_offset > 0 ? 1000 : [self.delegate conversationsLoadingLimit] completeHandler:^(NSArray *d) {
            
            
            
            d = [d filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(TL_conversation * evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                
                if ((evaluatedObject.type == DialogTypeUser && !evaluatedObject.user) || ((evaluatedObject.type == DialogTypeChat || evaluatedObject.type == DialogTypeChannel) && !evaluatedObject.chat)) {
                    return NO;
                }
                
                return YES;
                
            }]];
            
            [[DialogsManager sharedManager] add:d updateCurrent:NO];
            
             [_queue dispatchOnQueue:^{
                 
                if(d.count < [self.delegate conversationsLoadingLimit]) {
                    
                    _state = TGModernCHStateRemote;
                    
                    [self performLoadNext];
                    
                }
                 
                if(d.count > 0)
                    [self dispatchWithFullList:[self mixChannelsWithConversations:d] offset:(int)d.count];
                
            }];
            
            
        }];
    }  else if(_state == TGModernCHStateRemote) {
        
        NSArray *all = [[DialogsManager sharedManager] all];
        
        BOOL fullResort = [[all filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.type != 2"]] count] == 0;
        
        __block TL_conversation *conversation;
        
        [all enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(TL_conversation *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if(obj.type != DialogTypeSecretChat && obj.lastMessage && obj.lastMessage.n_id < TGMINFAKEID && !obj.fake && !obj.isInvisibleChannel && !obj.isPinned) {
                conversation = obj;
                *stop = YES;
            }
            
        }];
        
        id inputPeer = conversation ? conversation.inputPeer : [TL_inputPeerEmpty create];
        int date = conversation.lastMessage.date;
        
        const int limit = 50;
        
        
        [RPCRequest sendRequest:[TLAPI_messages_getDialogs createWithFlags:0 offset_date:date offset_id:conversation.lastMessage.n_id offset_peer:inputPeer limit:limit] successHandler:^(id request, TL_messages_dialogs *response) {
            
            
            [SharedManager proccessGlobalResponse:response];
            
            
            NSArray *converted = [TGModernConversationHistoryController parseDialogs:response];
            
            [[DialogsManager sharedManager] add:converted];
            [[Storage manager] insertDialogs:converted];

            [MessagesManager updateUnreadBadge];
            
            if(converted.count < limit) {
                _state = TGModernCHStateFull;

            }
            
            
            
            [self dispatchWithFullList:converted offset:(int)converted.count];
            
            if(fullResort)
                [Notification perform:DIALOGS_NEED_FULL_RESORT data:@{}];
            
        } errorHandler:^(id request, RpcError *error) {
            
            
        } timeout:0 queue:_queue.nativeQueue];
        
    }

}

+(NSArray*)parseDialogs:(TL_messages_dialogs *)response {
    NSMutableArray *converted = [[NSMutableArray alloc] init];
    
    __block int pinnedTime = [DialogsManager pullPinnedNextTime:chat_pin_limit()];
    
    [response.dialogs enumerateObjectsUsingBlock:^(TL_dialog *dialog, NSUInteger idx, BOOL *stop) {
        
        TL_localMessage *lastMessage = [[response.messages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.n_id == %d",dialog.top_message]] firstObject];
        
        
        TLChat *chat = [[response.chats filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.n_id == %d",-dialog.peer.peer_id]] firstObject];
        
        TL_conversation *conversation;
        
        
        
        if([dialog.peer isKindOfClass:[TL_peerChannel class]]) {
            NSArray *f = [response.messages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.peer_id == %d", dialog.peer.peer_id]];
            
            __block TL_localMessage *topMsg;
            __block TL_localMessage *minMsg;
            
            [f enumerateObjectsUsingBlock:^(TL_localMessage *obj, NSUInteger idx, BOOL *stop) {
                
                if(dialog.top_message == obj.n_id)
                    topMsg = obj;
                
                if(!minMsg || obj.n_id < minMsg.n_id)
                    minMsg = obj;
                
            }];
            
            
            int date = topMsg.date;
            
            if (dialog.isPinned) {
                date = pinnedTime--;
            }
            
            lastMessage = topMsg;
            
            int unread_count = dialog.unread_count;
            
            conversation = [TL_conversation createWithFlags:dialog.flags peer:dialog.peer top_message:dialog.top_message unread_count:unread_count last_message_date:date notify_settings:dialog.notify_settings last_marked_message:unread_count > 0 ? dialog.read_inbox_max_id : lastMessage.n_id top_message_fake:lastMessage.n_id last_marked_date:minMsg.date sync_message_id:topMsg.n_id read_inbox_max_id:dialog.read_inbox_max_id read_outbox_max_id:dialog.read_outbox_max_id draft:dialog.draft lastMessage:lastMessage pts:dialog.pts isInvisibleChannel:NO];
        } else {
            
            int unread_count = chat.migrated_to.channel_id != 0 ? 0 : dialog.unread_count;
            
            int date = lastMessage.date;
            
            if (dialog.isPinned) {
                date = pinnedTime--;
            }
            
            conversation = [TL_conversation createWithFlags:dialog.flags peer:dialog.peer top_message:dialog.top_message unread_count:unread_count last_message_date:date notify_settings:dialog.notify_settings last_marked_message:unread_count > 0 ? dialog.read_inbox_max_id : dialog.top_message top_message_fake:dialog.top_message last_marked_date:lastMessage.date sync_message_id:lastMessage.n_id read_inbox_max_id:dialog.read_inbox_max_id read_outbox_max_id:dialog.read_outbox_max_id draft:dialog.draft lastMessage:lastMessage pts:dialog.pts isInvisibleChannel:NO];
        }
        
        
        [converted addObject:conversation];
        
    }];
    
    return converted;
}

- (NSArray *)mixChannelsWithConversations:(NSArray *)conversations {
    
    NSArray *join = conversations;
    
    return [join sortedArrayUsingComparator:^NSComparisonResult(TL_conversation * obj1, TL_conversation * obj2) {
        return (obj1.last_real_message_date < obj2.last_real_message_date ? NSOrderedDescending : (obj1.last_real_message_date > obj2.last_real_message_date ? NSOrderedAscending : (obj1.top_message < obj2.top_message ? NSOrderedDescending : NSOrderedAscending)));
    }];
    
}

-(void)dispatchWithFullList:(NSArray *)all offset:(int)offset {
    
    [_delegate didLoadedConversations:all withRange:NSMakeRange(_offset, all.count)];
    
    _offset+= offset;
//    _remoteOffset+= [[all filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.type == 0 OR self.type == 1"]] count];
//    _localOffset+= [[all filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.type == 0 OR self.type == 1 OR self.type == 2 OR self.type == 3"]] count];
    _isLoading = NO;

}

-(void)clear {
    _offset = 0;
    _localOffset = 0;
    _remoteOffset = 0;
    _isLoading = NO;
    _delegate = nil;
    _state = TGModernCHStateLocal;
}


@end
