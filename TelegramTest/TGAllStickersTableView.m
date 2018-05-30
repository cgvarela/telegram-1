//
//  TGAllStickersTableView.m
//  Telegram
//
//  Created by keepcoder on 25.12.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGAllStickersTableView.h"
#import "TGStickerImageView.h"
#import "TGMessagesStickerImageObject.h"
#import "StickersPanelView.h"
#import "TGStickerPreviewModalView.h"
#import "TGModernStickRowItem.h"



@interface TGAllStickersTableView ()<TMTableViewDelegate>
@property (nonatomic,strong) TMView *noEmojiView;
@property (nonatomic,strong) NSMutableDictionary *stickers;
@property (nonatomic,strong) NSMutableArray *sets;
@property (nonatomic,assign) BOOL isCustomStickerPack;
@property (nonatomic,strong) TGStickerPreviewModalView *previewModal;
@property (nonatomic,assign) BOOL notSendUpSticker;
@property (nonatomic,strong) NSMutableArray *cItems;
@end





@implementation TGAllStickersTableItem


-(id)initWithObject:(NSArray *)object packId:(long)packId {
    if(self = [super initWithObject:object]) {
        _stickers = [object mutableCopy];
        _packId = packId;
        
        _objects = [[NSMutableArray alloc] init];
        
        [_stickers enumerateObjectsUsingBlock:^(TL_document *obj, NSUInteger idx, BOOL *stop) {
            
            NSImage *placeholder = [[NSImage alloc] initWithData:obj.thumb.bytes];
            
            if(!placeholder)
                placeholder = [NSImage imageWithWebpData:obj.thumb.bytes error:nil];
            
            if(!placeholder)
                placeholder = white_background_color();
            
            TGMessagesStickerImageObject *imgObj = [[TGMessagesStickerImageObject alloc] initWithLocation:obj.thumb.location placeHolder:placeholder];
            
            imgObj.imageSize = strongsize(NSMakeSize(obj.thumb.w, obj.thumb.h), 65);
            
            [_objects addObject:imgObj];
            
        }];
    }
    
    return self;
}

-(int)height {
    return 80;
}

-(Class)viewClass {
    return [TGAllStickerTableItemView class];
}


-(NSUInteger)hash {
    
    __block NSString *hashString = @"";
    
    [_stickers enumerateObjectsUsingBlock:^(TL_document *obj, NSUInteger idx, BOOL *stop) {
        hashString = [hashString stringByAppendingFormat:@"%ld - ",obj.n_id];
    }];
    
    return [hashString hash];
}

@end






@implementation TGAllStickerTableItemView

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        __block int xOffset = 0;
        
        int width = round(NSWidth(self.bounds)/5);
        
        weak();
        
        for (int i = 0; i < 5; i++) {
            BTRButton *button = [[BTRButton alloc] initWithFrame:NSMakeRect(xOffset, 0, width, NSHeight(self.bounds))];
            
            
            
            [button addBlock:^(BTRControlEvents events) {
                
                TGAllStickersTableItem *item = (TGAllStickersTableItem *)[weakSelf rowItem];
                
                if([weakSelf.tableView.previewModal isKindOfClass:[NSNull class]]) {
                    [weakSelf.tableView selectionDidChange:item.rowId item:item];
                    return;
                }
                
                if(weakSelf.tableView.previewModal.isShown) {
                    [weakSelf.tableView.previewModal close:YES];
                    weakSelf.tableView.previewModal = nil;
                    
                    return;
                }
                
                if(weakSelf.tableView.notSendUpSticker)
                {
                    weakSelf.tableView.notSendUpSticker = NO;
                    return;
                }
                
                if(!weakSelf.tableView.isCustomStickerPack || weakSelf.tableView.canSendStickerAlways)
                {
                    TLDocument *sticker = item.stickers[i];
                    if (!sticker.stickerAttr.isMask)
                        [weakSelf.tableView.messagesViewController sendSticker:sticker forConversation:weakSelf.tableView.messagesViewController.conversation addCompletionHandler:nil];

                }
                
                if(weakSelf.tableView.canSendStickerAlways) {
                    [TMViewController closeAllModals];
                }
                
                
            } forControlEvents:BTRControlEventMouseUpInside];
            
            [button addBlock:^(BTRControlEvents events) {
                
                TGAllStickersTableItem *item = (TGAllStickersTableItem *)[weakSelf rowItem];
                
                TGStickerPreviewModalView *preview = [[TGStickerPreviewModalView alloc] init];
                
                [preview setSticker:item.stickers[i]];
                
                [preview show:appWindow() animated:YES];
                
                weakSelf.tableView.previewModal = preview;
                
            } forControlEvents:BTRControlEventLongLeftClick];
            
            
            TGStickerImageView *imageView = [[TGStickerImageView alloc] initWithFrame:NSZeroRect];
            [button addSubview:imageView];
            [self addSubview:button];
            xOffset+=width;
        }
    }
    
    return self;
}


static NSImage *higlightedImage() {
    static NSImage *image;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        image = [[NSImage alloc] initWithSize:NSMakeSize(67, 67)];
        [image lockFocus];
        NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(0, 0, 67, 67) xRadius:3 yRadius:3];
        [NSColorFromRGB(0xdedede) set];
        [path fill];
        [image unlockFocus];
    });
    return image;
}

-(TGAllStickersTableView *)tableView {
    return (TGAllStickersTableView *) self.rowItem.table;
}


-(void)redrawRow {
    
    TGAllStickersTableItem *item = (TGAllStickersTableItem *)[self rowItem];
    
    [self.subviews enumerateObjectsUsingBlock:^(__kindof NSView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [obj setHidden:idx >= item.stickers.count];
        
    }];
   
   

    [item.stickers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        @try {
            BTRButton *button = self.subviews[idx];
            TGStickerImageView *imageView = [button.subviews lastObject];
            
            [button setBackgroundImage:higlightedImage() forControlState:BTRControlStateHighlighted];
            
            [imageView setFrameSize:[item.objects[idx] imageSize]];
            
            imageView.object = item.objects[idx];
            
            [imageView setCenterByView:button];
        } @catch (NSException *exception) {
            int bp = 0;
        }
        
     
        
        
    }];
    
    
}



-(void)dealloc {
    
}

@end





@implementation TGAllStickersTableView

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _stickers = [[NSMutableDictionary alloc] init];
        self.tm_delegate = self;
        
        [Notification addObserver:self selector:@selector(stickersNeedFullReload:) name:STICKERS_ALL_CHANGED];
        [Notification addObserver:self selector:@selector(stickersNeedReorder:) name:STICKERS_REORDER];
        [Notification addObserver:self selector:@selector(stickersNewPackAdded:) name:STICKERS_NEW_PACK];
        
    }
    
    return self;
}

+(void)initialize {
    [TGCache setMemoryLimit:300*1024*1024 group:STICKERSCACHE];
}


-(void)stickersNeedFullReload:(NSNotification *)notification {
    [self load:YES];
    
}


-(void)loadFeatured:(BOOL)force {
    
    
    if(force || !isRemoteStickersLoaded()) {
        __block int nhash = 0;
        
        __block NSArray *sets;
        
        [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
            
            nhash = [[transaction objectForKey:@"featured_hash1" inCollection:STICKERS_COLLECTION] intValue];
            sets = [transaction objectForKey:@"featuredSets" inCollection:STICKERS_COLLECTION];
        }];
        
        [RPCRequest sendRequest:[TLAPI_messages_getFeaturedStickers createWithN_hash:nhash] successHandler:^(RPCRequest *request, TL_messages_featuredStickers *response) {
            
            
            [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction) {
                
                if(![response isKindOfClass:[TL_messages_featuredStickersNotModified class]]) {
                    
                    [transaction setObject:response.sets forKey:@"featuredSets" inCollection:STICKERS_COLLECTION];
                    [transaction setObject:response.unread forKey:@"featuredUnreadSets" inCollection:STICKERS_COLLECTION];
                    [transaction setObject:@(response.n_hash) forKey:@"featured_hash1" inCollection:STICKERS_COLLECTION];
                    
                    sets = response.sets;
                }
            }];
            
  
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            
        }];
    }
    
   

}

-(void)loadRecent:(BOOL)force {
    
    if(force || !isRemoteStickersLoaded()) {
        
        __block NSArray *stickers;
        __block int nhash;
        [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
            
            nhash = [[transaction objectForKey:@"remoteRecentHash" inCollection:STICKERS_COLLECTION] intValue];
            stickers = [transaction objectForKey:@"remoteRecentStickers" inCollection:STICKERS_COLLECTION];
        }];
        
        [RPCRequest sendRequest:[TLAPI_messages_getRecentStickers createWithFlags:0 n_hash:nhash] successHandler:^(RPCRequest *request, TL_messages_recentStickers *response) {
            
             if([response isKindOfClass:[TL_messages_recentStickers class]]) {
                 [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction) {
                     [transaction setObject:[response.stickers mutableCopy] forKey:@"remoteRecentStickers" inCollection:STICKERS_COLLECTION];
                     [transaction setObject:@(response.n_hash) forKey:@"remoteRecentHash" inCollection:STICKERS_COLLECTION];
                 }];
                [self reloadData];
            }
            
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            
        }];
    }
 
}

-(void)stickersNeedReorder:(NSNotification *)notification {
    NSArray *order = notification.userInfo[KEY_ORDER];
    
    [_sets sortUsingComparator:^NSComparisonResult(TL_stickerSet *obj1, TL_stickerSet *obj2) {
        
        NSNumber *idx1 = @([order indexOfObject:@(obj1.n_id)]);
        NSNumber *idx2 = @([order indexOfObject:@(obj2.n_id)]);
        
        return [idx1 compare:idx2];
    }];
    
    [self reloadData];
}

-(void)stickersNewPackAdded:(NSNotification *)notification {
    TL_messages_stickerSet *set = notification.userInfo[KEY_STICKERSET];
    
    [_sets insertObject:set.set atIndex:0];
    
    _stickers[@(set.set.n_id)] = set.documents;
    
    
    [self save:_sets stickers:_stickers n_hash:[self stickersHash:_sets] saveSets:YES];
    
    [self reloadData];
}



-(NSScrollView *)containerView {
    return [super containerView];
}

-(void)load:(BOOL)force {
    
    [self loadFeatured:force];
    [self loadRecent:force];
    if(_stickers.count == 0 || force) {
        
        _isCustomStickerPack = NO;
        
        weak();
        
        [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            
            NSDictionary *info  = [transaction objectForKey:@"modern_stickers2" inCollection:STICKERS_COLLECTION];
            
            weakSelf.stickers = info[@"serialized"];
            
            if(!weakSelf.stickers)
                weakSelf.stickers = [NSMutableDictionary dictionary];
            
            weakSelf.sets = info[@"sets"];
            
        }];
        
        if(!isRemoteStickersLoaded() || force) {
            
            
            
            [RPCRequest sendRequest:[TLAPI_messages_getAllStickers createWithN_hash:[self stickersHash:_sets]] successHandler:^(RPCRequest *request, TL_messages_allStickers *response) {
                
                if(![response isKindOfClass:[TL_messages_allStickersNotModified class]]) {
                    
                    [self loadSetsIfNeeded:response.sets n_hash:response.n_hash];
                    
                } else {
                    [self loadSetsIfNeeded:_sets n_hash:[self stickersHash:_sets]];
                }
                
                setRemoteStickersLoaded(YES);
                
            } errorHandler:^(RPCRequest *request, RpcError *error) {
                
            }];
            
            
        } else {
            [self reloadData];
        }
    } else {
        [self reloadData];
    }
    
}


-(void)save:(NSArray *)sets stickers:(NSDictionary *)stickers n_hash:(int)n_hash saveSets:(BOOL)saveSets {
    if(saveSets) {
        [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction * __nonnull transaction) {
            
            @try {
                NSMutableDictionary *serializedStickers = [stickers mutableCopy];
                
                NSMutableDictionary *data = [[transaction objectForKey:@"modern_stickers2" inCollection:STICKERS_COLLECTION] mutableCopy];
                
                if(!data)
                {
                    data = [[NSMutableDictionary alloc] init];
                    data[@"sets"] = [[NSMutableArray alloc] init];
                }
                
                data[@"serialized"] = serializedStickers;
                
                if(saveSets) {
                    
                    data[@"sets"] = sets;
                }
                
                
                [transaction setObject:data forKey:@"modern_stickers2" inCollection:STICKERS_COLLECTION];
            } @catch (NSException *exception) {
                
            }

        }];
    }
    
}

-(void)loadSetsIfNeeded:(NSArray *)sets n_hash:(int)n_hash {
    
    
    NSMutableArray *removed = [[NSMutableArray alloc] init];
    NSMutableArray *changed = [[NSMutableArray alloc] init];
    
    [_sets enumerateObjectsUsingBlock:^(TL_stickerSet *obj, NSUInteger idx, BOOL *stop) {
        NSArray *current = [sets filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.n_id == %ld",obj.n_id]];
        
        if(current.count == 0)
        {
            [removed addObject:obj];
        }
    }];
    
    [sets enumerateObjectsUsingBlock:^(TL_stickerSet *obj, NSUInteger idx, BOOL *stop) {
        
        NSArray *current = [_sets filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.n_id == %ld",obj.n_id]];
        
        if(current.count == 0 || [(TL_stickerSet *)current[0] n_hash] != obj.n_hash || [self.stickers[@(obj.n_id)] count] == 0 ) {
            
            [changed addObject:obj];
        }
        
    }];
    
    _sets = [sets mutableCopy];
    
    
    if(changed.count > 0) {
        [self loadChangedSets:changed sets:sets hash:n_hash];
    }

    
    [self save:sets stickers:_stickers n_hash:n_hash saveSets:YES];
    
    
    [self reloadData];
    
    
}


-(void)loadChangedSets:(NSMutableArray *)changed sets:(NSArray *)sets hash:(int)n_hash {
    
     NSMutableArray *signals = [NSMutableArray array];
    
    [changed enumerateObjectsUsingBlock:^(TL_stickerSet *set, NSUInteger idx, BOOL * _Nonnull stop) {
        [signals addObject:[[MTNetwork instance] requestSignal:[TLAPI_messages_getStickerSet createWithStickerset:[TL_inputStickerSetID createWithN_id:set.n_id access_hash:set.access_hash]] queue:[ASQueue globalQueue]]];
    }];
    
    
    [[SSignal combineSignals:signals] startWithNext:^(NSArray *next) {
        
        [next enumerateObjectsUsingBlock:^(TL_messages_stickerSet *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            _stickers[@(obj.set.n_id)] = obj.documents;
        }];
        
        [self save:_sets stickers:_stickers n_hash:n_hash saveSets:YES];
        
        [ASQueue dispatchOnMainQueue:^{
            [self reloadData];
        }];
    }];
    
}



-(NSDictionary *)allStickers {
    return _stickers;
}



-(NSArray *)sets {
    return _sets;
}

-(void)updateSets:(NSArray *)sets {
    _sets = [sets mutableCopy];
}


-(void)reloadData {
        
    if(self.window == nil)
        return;
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    weak();
    

    
    [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        
        
        NSArray *recent = @[];
        
        if(!weakSelf.isCustomStickerPack) {
            recent = [transaction objectForKey:@"remoteRecentStickers" inCollection:STICKERS_COLLECTION];
            recent = [recent subarrayWithRange:NSMakeRange(0, MIN(stickers_recent_limit(),recent.count))];
        }
       
        NSDictionary *useRecent = [transaction objectForKey:@"recentStickers" inCollection:STICKERS_COLLECTION];
        
        
        weakSelf.hasRecentStickers = recent.count > 0;
        
        
        NSMutableArray *row = [[NSMutableArray alloc] init];
        
        if(recent.count > 0) {
             [items addObject:[[TGModernStickRowItem alloc] initWithObject:NSLocalizedString(@"Stickers.Recent", nil)]];
        }
        
        [recent enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            [row addObject:obj];
            
            if(row.count == 5) {
                [items addObject:[[TGAllStickersTableItem alloc] initWithObject:[row copy] packId:-1]];
                [row removeAllObjects];
            }
            
        }];
        
        
        if(row.count > 0) {
            [items addObject:[[TGAllStickersTableItem alloc] initWithObject:[row copy] packId:-1]];
            [row removeAllObjects];
        }
        
        if(!_isCustomStickerPack && _sets.count == 0) {
            NSDictionary *info  = [transaction objectForKey:@"modern_stickers2" inCollection:STICKERS_COLLECTION];
            
            _stickers = info[@"serialized"];
            
            if(!_stickers)
                _stickers = [NSMutableDictionary dictionary];
            
            _sets = info[@"sets"];
        }
        
        
        [weakSelf.sets enumerateObjectsUsingBlock:^(TL_stickerSet *set, NSUInteger idx, BOOL * _Nonnull stop) {
            if(!_isCustomStickerPack)
                [items addObject:[[TGModernStickRowItem alloc] initWithObject:set.title]];
            
            NSDictionary *rpack = useRecent[@(set.n_id)];
            if(rpack) {
                [weakSelf.stickers[@(set.n_id)] sortUsingComparator:^NSComparisonResult(TL_document *obj1, TL_document *obj2) {
                    
                    int u1 = [rpack[@(obj1.n_id)] intValue];
                    int u2 = [rpack[@(obj2.n_id)] intValue];
                    
                    NSComparisonResult result = [@(u1) compare:@(u2)];
                    
                    return result == NSOrderedAscending ? NSOrderedDescending : result == NSOrderedDescending ? NSOrderedAscending : NSOrderedSame;
                    
                }];
            }
            
            
            [weakSelf.stickers[@(set.n_id)] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                [row addObject:obj];
                
                if(row.count == 5) {
                    [items addObject:[[TGAllStickersTableItem alloc] initWithObject:[row copy] packId:set.n_id]];
                    [row removeAllObjects];
                }
            }];
            
            if(row.count > 0) {
                [items addObject:[[TGAllStickersTableItem alloc] initWithObject:[row copy] packId:set.n_id]];
                [row removeAllObjects];
            }
            
            
        }];
        
        
        
    }];
    

    [self removeAllItems:NO];
    

    
    [self insert:items startIndex:0 tableRedraw:NO];
    


    
    [self setStickClass:[TGModernStickRowItem class]];

    [super reloadData];
    //
    if(_didNeedReload) {
        _didNeedReload();
    }
    
    
}

-(BOOL)removeAllItems:(BOOL)tableRedraw {
    
    
    if(tableRedraw) {
        [TGCache removeAllCachedImages:@[STICKERSCACHE]];
        [super removeAllItems:NO];
        [super reloadData];
    } else {
        [super removeAllItems:tableRedraw];
    }
    
    return YES;
}

-(void)setStickers:(NSMutableDictionary *)stickers {
    _stickers = stickers;
}

- (CGFloat)rowHeight:(NSUInteger)row item:(TMRowItem *) item
{
    return item.height;
}

- (BOOL)isGroupRow:(NSUInteger)row item:(TMRowItem *) item {
    return NO;
}

- (TMRowView *)viewForRow:(NSUInteger)row item:(TMRowItem *) item {
    TGAllStickerTableItemView *view = (TGAllStickerTableItemView *) [self cacheViewForClass:item.viewClass identifier:NSStringFromClass(item.viewClass) withSize:NSMakeSize(NSWidth(self.containerView.frame), item.height)];;
    return view;
}

- (void)selectionDidChange:(NSInteger)row item:(TMRowItem *) item {
    
}

- (BOOL)selectionWillChange:(NSInteger)row item:(TMRowItem *) item {
    
    return YES;
}

- (BOOL)isSelectable:(NSInteger)row item:(TMRowItem *) item {
    return YES;
}

-(void)showWithStickerPack:(TL_messages_stickerSet *)stickerPack {
    
    [_stickers removeAllObjects];
    _sets = [NSMutableArray array];

    [_sets addObject:stickerPack.set];
    _stickers[@(stickerPack.set.n_id)] = [stickerPack documents];
    
    _isCustomStickerPack = YES;
    
    [self reloadData];
    
}

-(int)stickersHash:(NSArray *)stickersets {
    
    __block int acc = 0;
    
    [stickersets enumerateObjectsUsingBlock:^(TL_stickerSet *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        acc = (acc * 20261) + obj.n_hash;
    }];
    
    return (int)(acc % 0x7FFFFFFF);
    
}


-(void)scrollToStickerPack:(long)packId completionHandler:(dispatch_block_t)completionHandler {
    
    __block TGAllStickersTableItem *item;
    
    [self.list enumerateObjectsUsingBlock:^(TGAllStickersTableItem *obj, NSUInteger idx, BOOL *stop) {
        if(obj.class == TGAllStickersTableItem.class) {
            if(obj.packId == packId) {
                item = obj;
                *stop = YES;
            }
        }
        
        
    }];
    
    
    NSRect rect = [self rectOfRow:[self indexOfItem:item]];
    
    [self.scrollView.clipView scrollRectToVisible:NSMakeRect(NSMinX(rect), NSMinY(rect) + (NSMinY(self.containerView.frame) - NSHeight(self.currentStickView.frame)), NSWidth(rect), NSHeight(self.scrollView.frame))  animated:YES completion:^(BOOL scrolled) {
        completionHandler();
    }];
    
}



-(void)mouseDragged:(NSEvent *)theEvent {
    if(_previewModal != nil) {
        
        @try {
            NSUInteger index = [self rowAtPoint:[self convertPoint:[theEvent locationInWindow] fromView:nil]];
            
            TGAllStickerTableItemView *view = [self viewAtColumn:0 row:index makeIfNecessary:NO];
            
            TGAllStickersTableItem *item = [self itemAtPosition:index];
            
            NSPoint point = [view convertPoint:[theEvent locationInWindow] fromView:nil];
            
            [view.subviews enumerateObjectsUsingBlock:^(__kindof NSView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if(NSMinX(obj.frame) < point.x && NSMaxX(obj.frame) > point.x) {
                    
                    [_previewModal setSticker:item.stickers[idx]];
                }
                
            }];
        } @catch (NSException *exception) {
            
        }
       
        
    } else {
        [super mouseDragged:theEvent];
    }
}

-(void)hideStickerPreview {
    
    if(_previewModal) {
        
        NSEvent *event = [NSApp currentEvent];
        
        if(![event.window isKindOfClass:[RBLPopoverWindow class]]) {
            _notSendUpSticker = YES;
        }
    }
    
    [_previewModal close:YES];
    _previewModal = nil;
    
}

-(void)dealloc {
    [Notification removeObserver:self];
}

-(void)clear {
    [super clear];
    
}




@end
