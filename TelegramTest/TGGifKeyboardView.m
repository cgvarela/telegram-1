#import "TGGifKeyboardView.h"
#import "TMSearchTextField.h"
#import "SpacemanBlocks.h"
#import "TGMediaContextTableView.h"
#import "TGModernStickRowItem.h"
#import "TGModernESGViewController.h"
@interface TGGifKeyboardView () <TMSearchTextFieldDelegate> {
    __block SMDelayedBlockHandle _delayedBlockHandle;
}
@property (nonatomic,strong) TGMediaContextTableView *tableView;
@property (nonatomic,strong) TMSearchTextField *searchField;

@property (nonatomic,weak) RPCRequest *request;

@property (nonatomic,strong) NSMutableArray *items;

@property (nonatomic,strong) NSImageView *emptyImageView;

@end

@implementation TGGifKeyboardView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        [self initialize];
    }
    
    return self;
}


-(void)initialize {
    _tableView = [[TGMediaContextTableView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.frame), NSHeight(self.frame))];
    [self addSubview:_tableView.containerView];
    

    _tableView.needCheckKeyWindow = NO;
    _emptyImageView = imageViewWithImage(image_noResults());
    [_emptyImageView setCenterByView:self];
    [self addSubview:_emptyImageView];
    
    [_emptyImageView setHidden:YES];
    
    weak();
    
    [_tableView setChoiceHandler:^(TLBotInlineResult *result) {
        __strong TGGifKeyboardView *strongSelf = weakSelf;
        
        if(strongSelf != nil) {
            
            [[TGModernESGViewController controller] forceClose];
            
            dispatch_after_seconds(0.1, ^{
                
                
                [strongSelf.messagesViewController sendFoundGif:[TL_messageMediaDocument createWithDocument:result.document caption:@""] forConversation:strongSelf.messagesViewController.conversation];
            });
            
            
        }
    }];
    
}




-(void)didReceiveMessage:(NSNotification *)notification {
    
    [ASQueue dispatchOnMainQueue:^{
        
        TL_localMessage *message = notification.userInfo[KEY_MESSAGE];
        
        BOOL c = [self proccessMessage:message];
        
        if(!self.isHidden && c) {
            [self proccessAndSendToDraw:_items];
        }
        
    }];
}

-(void)didReceiveMessages:(NSNotification *)notification {
    
    [ASQueue dispatchOnMainQueue:^{
        NSArray *messages = notification.object;
        
        __block BOOL changed;
        
        [messages enumerateObjectsUsingBlock:^(TL_localMessage *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            BOOL c = [self proccessMessage:obj];
            
            if(!changed && c)
                changed = c;
            
        }];
        
        if(!self.isHidden && changed) {
           [self proccessAndSendToDraw:_items];
        }
    }];
    
}


-(BOOL)proccessMessage:(TL_localMessage *)message {
    
    if(message.isN_out && [message.media.document.mime_type isEqualToString:@"video/mp4"] && [message.media.document attributeWithClass:[TL_documentAttributeVideo class]] != nil) {
        
        
        TL_document *item = [[_items filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.n_id == %ld",message.media.document.n_id]] firstObject];
        
        if(item) {
            [_items removeObjectAtIndex:[_items indexOfObject:item]];
        } else {
           
        }
        [_items insertObject:message.media.document atIndex:0];
        
        return YES;
    }
    
    return NO;
    
}

-(void)viewDidUnhide {
    [Notification addObserver:self selector:@selector(didReceiveMessage:) name:MESSAGE_RECEIVE_EVENT];
    [Notification addObserver:self selector:@selector(didReceiveMessages:) name:MESSAGE_LIST_RECEIVE];
}

-(void)viewDidHide {
    [Notification removeObserver:self];
}

-(void)dealloc {
    [Notification removeObserver:self];
}


-(int)gifsHash {
    
    __block int acc = 0;
    
    [_items enumerateObjectsUsingBlock:^(TLDocument *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        acc = (acc * 20261) + (obj.n_id >> 32);
        acc = (acc * 20261) + (obj.n_id & 0xFFFFFFFF);
    }];
     
    return (int)(acc & 0x7FFFFFFF);
}

-(void)prepareSavedGifvs {
    
    
    [[Storage yap] asyncReadWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
        
        NSMutableArray *result = [transaction objectForKey:@"gifs" inCollection:RECENT_GIFS];
        
        [ASQueue dispatchOnMainQueue:^{
            [self proccessAndSendToDraw:result];
            
            [self checkRemoteWithHash];
        }];
        
    }];
    
    
}

-(void)updateSavedGifs:(NSArray *)docs {
    [[Storage yap] asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction) {
        
        
        [transaction setObject:docs forKey:@"gifs" inCollection:RECENT_GIFS];
        
        [ASQueue dispatchOnMainQueue:^{
            [self proccessAndSendToDraw:docs];
            
        }];
        
    }];
}

-(void)checkRemoteWithHash {
    [RPCRequest sendRequest:[TLAPI_messages_getSavedGifs createWithN_hash:[self gifsHash]] successHandler:^(id request, TL_messages_savedGifs *response) {
        
        if([response isKindOfClass:[TL_messages_savedGifs class]]) {
            
            [self proccessAndSendToDraw:[response.gifs copy]];
            
            [[Storage yap] asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction) {
                [transaction setObject:response.gifs forKey:@"gifs" inCollection:RECENT_GIFS];
            }];
        }
        
    } errorHandler:^(id request, RpcError *error) {
        
    }];
}

-(void)proccessAndSendToDraw:(NSArray *)items {
    
    NSMutableArray *result = [NSMutableArray array];
    
    [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TLBotInlineResult *botResult = [[TLBotInlineResult alloc] init];
        botResult.document = obj;
        botResult.type = @"gifv";
        [result addObject:botResult];
    }];
    
    _items = [items mutableCopy];
    
    [_tableView clear];
    
    weak();
    
    [_tableView setDeleteLocalGif:^(TLBotInlineResult *gif) {
        
        [result removeObject:gif];
        
        NSMutableArray *docs = [[NSMutableArray alloc] init];
        
        [result enumerateObjectsUsingBlock:^(TLBotInlineResult * obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [docs addObject:obj.document];
            
        }];
        
        [weakSelf updateSavedGifs:docs];
        
        [RPCRequest sendRequest:[TLAPI_messages_saveGif createWithN_id:[TL_inputDocument createWithN_id:gif.document.n_id access_hash:gif.document.access_hash] unsave:YES] successHandler:^(id request, id response) {
            
            if([response isKindOfClass:[TL_boolTrue class]]) {
                [weakSelf checkRemoteWithHash];
            }
            
        } errorHandler:^(id request, RpcError *error) {
            
        }];

        
    }];
    
    [_tableView addItem:[[TGModernStickRowItem alloc] initWithObject:NSLocalizedString(@"Gifs.SavedGifs", nil)] tableRedraw:YES];
    [_tableView drawResponse:result];
    
    [_tableView setStickClass:[TGModernStickRowItem class]];
    
    [_tableView.containerView setHidden:items.count == 0];
    [_emptyImageView setHidden:items.count > 0];
}

-(void)clear {
    [_tableView clear];
}

@end