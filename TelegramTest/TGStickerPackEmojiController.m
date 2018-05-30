//
//  TGStickerPackEmojiController.m
//  Telegram
//
//  Created by keepcoder on 08.06.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGStickerPackEmojiController.h"
#import "TGAllStickersTableView.h"
#import "TGImageView.h"
#import "TGMessagesStickerImageObject.h"
#import "TGTransformScrollView.h"
#import "SpacemanBlocks.h"
#import "TGHorizontalTableView.h"
#import "TGModernESGViewController.h"
#import "TGGifKeyboardView.h"
#import "TGHotPacksContainerView.h"
@interface TGPackItem : NSObject
@property (nonatomic,strong) TGImageObject *imageObject;
@property (nonatomic,assign) long packId;
@property (nonatomic,assign) BOOL selected;
@property (nonatomic,strong) NSImage *image;
@end

@implementation TGPackItem

-(id)initWithObject:(TLDocument *)obj {
    if( self = [super init]) {
        TL_documentAttributeSticker *attr = obj.stickerAttr;
        _packId = attr.stickerset.n_id;
        _imageObject = [[TGMessagesStickerImageObject alloc] initWithLocation:obj.thumb.location placeHolder:nil];
        _imageObject.imageSize = strongsize(NSMakeSize(obj.thumb.w, obj.thumb.h), 28);
    }
    
    return self;
}

@end


@protocol TGStickerPackButtonDelegate <NSObject>
-(void)removeScrollEvent;
-(void)addScrollEvent;
-(void)didSelected:(id)button scrollToPack:(BOOL)scrollToPack selectItem:(BOOL)selectItem disableAnimation:(BOOL)disableAnimation;

@end

@interface TGStickerPackView : PXListViewCell
@property (nonatomic,assign,setter=setSelected:) BOOL isSelected;
@property (nonatomic,strong) TGStickerImageView *imageView;
@property (nonatomic,strong) id <TGStickerPackButtonDelegate> delegate;
@property (nonatomic,strong) TMView *separator;
@property (nonatomic,strong) TGPackItem *packItem;
@end




@implementation TGStickerPackView


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _imageView = [[TGStickerImageView alloc] initWithFrame:NSMakeRect(2, 2, 28, 28)];
        [_imageView setCenterByView:self];
        [self addSubview:_imageView];
        
        _separator = [[TMView alloc] initWithFrame:NSMakeRect(0, 2, NSWidth(frameRect), 2)];
        
        weak();
        
        [_separator setDrawBlock:^{
            if(weakSelf.isSelected) {
                [LINK_COLOR set];
                
                NSRectFill(NSMakeRect(0, 0, NSWidth(weakSelf.frame), 2));
            }
        }];
         [_separator setAlphaValue:0.0f];
        
        [self addSubview:_separator];
    }
    
    return self;
}

-(void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [DIALOG_BORDER_COLOR set];
    NSRectFill(NSMakeRect(0, NSHeight(self.frame) - DIALOG_BORDER_WIDTH, NSWidth(self.frame), DIALOG_BORDER_WIDTH));
}


-(void)setPackItem:(TGPackItem *)packItem {
    
    _packItem = packItem;
    
    if(packItem.imageObject) {
        [self.imageView setFrameSize:packItem.imageObject.imageSize];
        [self.imageView setCenterByView:self];
        self.imageView.object = packItem.imageObject;
    } else if(packItem.image) {
        [self.imageView setFrameSize:packItem.image.size];
        [self.imageView setCenterByView:self];
        [self.imageView setImage:packItem.image];
    }
    
    [self setSelected:packItem.selected];

}


-(void)setSelected:(BOOL)isSelected {
    
    BOOL oldSelected = _isSelected;
    
    _isSelected = isSelected;
    
    if(oldSelected == YES && _isSelected == NO) {
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            [[_separator animator] setAlphaValue:0.0];
        } completionHandler:^{
            [_separator setNeedsDisplay:YES];
        }];
        
    } else if(oldSelected == NO && _isSelected == YES) {
        [_separator setAlphaValue:0.0f];
        [_separator setNeedsDisplay:YES];
        
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            [[_separator animator] setAlphaValue:1.0f];
        } completionHandler:^{
            
        }];
        
    }
   
    
}

-(void)mouseDown:(NSEvent *)theEvent {
    
    [_delegate didSelected:self.packItem scrollToPack:YES selectItem:YES disableAnimation:NO];
}

@end

@interface TGStickerPackEmojiController () <TGStickerPackButtonDelegate,PXListViewDelegate> {
    SMDelayedBlockHandle _handle;
}
//@property (nonatomic,strong) TGTransformScrollView *scrollView;
//@property (nonatomic,strong) TMView *packsContainerView;
@property (nonatomic,strong) TGPackItem *selectedItem;
@property (nonatomic,strong) TGHorizontalTableView *tableView;
@property (nonatomic,strong) NSMutableArray *packs;
@property (nonatomic, strong) TGGifKeyboardView *gifContainer;
@property (nonatomic,strong) TGHotPacksContainerView *hotPacksView;


@end

@implementation TGStickerPackEmojiController

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithFrame:(NSRect)frameRect packHeight:(int)packHeight {
    if(self = [super initWithFrame:frameRect]) {

       
        
        self.autoresizingMask = NSViewHeightSizable;
        
        _packs = [NSMutableArray array];
        
        _tableView = [[TGHorizontalTableView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(frameRect), packHeight)];
        _tableView.delegate = self;
        
        [self addSubview:_tableView];
        
        weak();
        
        _stickers = [[TGAllStickersTableView alloc] initWithFrame:NSMakeRect(0, NSHeight(_tableView.frame), NSWidth(frameRect), NSHeight(frameRect) - NSHeight(_tableView.frame))];
        [_stickers setDidNeedReload:^{
            [weakSelf reload:NO];
        }];
        
       [self addSubview:_stickers.containerView];
        
        _hotPacksView = [[TGHotPacksContainerView alloc] initWithFrame:NSMakeRect(0, NSHeight(_tableView.frame), NSWidth(frameRect), NSHeight(frameRect) - NSHeight(_tableView.frame))];
        [self addSubview:_hotPacksView.containerView];
        [_hotPacksView.containerView setHidden:YES];
        
        
        _gifContainer = [[TGGifKeyboardView alloc] initWithFrame:NSMakeRect(0, NSHeight(_tableView.frame), NSWidth(frameRect), NSHeight(frameRect) - NSHeight(_tableView.frame))];
        [self addSubview:_gifContainer];
        [_gifContainer setHidden:YES];
        
        _gifContainer.autoresizingMask = NSViewHeightSizable;
        [self addScrollEvent];
        
    }
    
    return self;
}

-(void)setEsgViewController:(TGModernESGViewController *)esgViewController {
    _esgViewController = esgViewController;
    _gifContainer.messagesViewController = esgViewController.messagesViewController;
    
}


- (void) addScrollEvent {
    id clipView = [[_stickers enclosingScrollView] contentView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollViewDocumentOffsetChangingNotificationHandler:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:clipView];
}

-(void)removeScrollEvent {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)scrollViewDocumentOffsetChangingNotificationHandler:(NSNotification *)notify {
    
    if(NSIsEmptyRect([_stickers visibleRect]))
        return;

    
    @try {
        
        NSUInteger idx = MIN([_stickers rowsInRect:[_stickers visibleRect]].location,_stickers.count-1);
        
        id fItem;
        
        while (![fItem = [_stickers itemAtPosition:idx] isKindOfClass:NSClassFromString(@"TGAllStickersTableItem")] && fItem) {
            idx++;
        }
        

        
        
        long packId = [[fItem valueForKey:@"packId"] longValue];
        

        
        if(packId != _selectedItem.packId) {
            
           

            
            [_packs enumerateObjectsUsingBlock:^(TGPackItem *obj, NSUInteger idx, BOOL *stop) {
                
                if(obj.packId == packId) {
                    
                    
                    [self didSelected:obj scrollToPack:NO selectItem:YES disableAnimation:NO];
                    
                    *stop = YES;
                }
                
            }];
        }
    }
    @catch (NSException *exception) {
        
    }
    

    
}

-(void)removeAllItems {
    [_stickers removeAllItems:YES];
    
    [_gifContainer clear];
    
    
}

-(void)reload {
    [self reload:YES];
}

-(void)reload:(BOOL)reloadStickers {
    
    
    if(!reloadStickers)
        [_packs removeAllObjects];
    
    
   if(reloadStickers) {
        id reload_block = _stickers.didNeedReload;
        [_stickers setDidNeedReload:nil];
        [_stickers reloadData];
        [_stickers setDidNeedReload:reload_block];
    }
    
    
    __block BOOL hasUnread = NO;
    __block NSArray *hots;
    __block BOOL hasHots = NO;
    
    [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction) {
        hasUnread = [[transaction objectForKey:@"featuredUnreadSets" inCollection:STICKERS_COLLECTION] count] > 0;
        hots = [transaction objectForKey:@"featuredSets" inCollection:STICKERS_COLLECTION];
    }];
    
    [hots enumerateObjectsUsingBlock:^(TL_stickerSetCovered  *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        hasHots = [TGModernESGViewController setWithId:obj.set.n_id] == nil;
        
        if (hasHots) {
            *stop = YES;
        }
        
    }];
    
    if(_packs.count == 0)
    {
        
        TGPackItem *gifpack = [[TGPackItem alloc] init];
        gifpack.packId = -3;
        gifpack.image = [image_emojiGifContainer() imageTintedWithColor:GRAY_ICON_COLOR];
        [_packs addObject:gifpack];
        
        if(hasUnread && hasHots) {
            TGPackItem *hotPack = [[TGPackItem alloc] init];
            hotPack.packId = -4;
            hotPack.image = [image_trending() imageTintedWithColor:GRAY_ICON_COLOR];
            [_packs addObject:hotPack];
        }
        
        
        if(_stickers.hasRecentStickers) {
            TGPackItem *recent = [[TGPackItem alloc] init];
            recent.packId = -1;
            recent.image = [image_emojiContainer1() imageTintedWithColor:GRAY_ICON_COLOR];
            [_packs addObject:recent];
        }
        
        NSDictionary *stickers = [TGModernESGViewController allStickers];
        NSArray *sets = [TGModernESGViewController allSets];
        [sets enumerateObjectsUsingBlock:^(TL_stickerSet *obj, NSUInteger idx, BOOL *stop) {
            
            id sticker = [stickers[@(obj.n_id)] firstObject];
            
            if(sticker) {
                [_packs addObject:[[TGPackItem alloc] initWithObject:sticker]];
            }
            
        }];
        
        if(!hasUnread && hasHots) {
            TGPackItem *hotPack = [[TGPackItem alloc] init];
            hotPack.packId = -4;
            hotPack.image = [image_trending() imageTintedWithColor:GRAY_ICON_COLOR];
            [_packs addObject:hotPack];
        }
        
        TGPackItem *settings = [[TGPackItem alloc] init];
        settings.packId = -2;
        settings.image = [image_StickerSettings() imageTintedWithColor:GRAY_ICON_COLOR];
        [_packs addObject:settings];
    }
    
    
    
    [_tableView reloadData];
    
    
    [self.stickers scrollToBeginningOfDocument:nil];
    if(_packs.count > 3 && reloadStickers) {
        
        if([_packs[2] packId] == -1) {
            [self didSelected:_packs[2] scrollToPack:NO selectItem:YES disableAnimation:YES];
        }
        
        if([_packs[1] packId] == -1) {
            [self didSelected:_packs[1] scrollToPack:NO selectItem:YES disableAnimation:YES];
        }
        
    } else if(reloadStickers) {
        [self didSelected:_packs[1] scrollToPack:NO selectItem:YES disableAnimation:YES];
    }
    

}



-(void)selectItem:(TGPackItem *)item {
    [_selectedItem setSelected:NO];
    _selectedItem = item;
    [_selectedItem setSelected:YES];
    
}

-(void)didSelected:(TGPackItem *)packItem scrollToPack:(BOOL)scrollToPack selectItem:(BOOL)selectItem disableAnimation:(BOOL)disableAnimation {
    
    
    if(packItem.packId == -3 && _selectedItem.packId != -3)
        [_gifContainer prepareSavedGifvs];
    else if(_selectedItem.packId == -3 && packItem.packId != -3)
        [_gifContainer clear];
    
    if(packItem.packId == -4 && _selectedItem.packId != -4)
        [_hotPacksView show];
    else if(_selectedItem.packId == -4 && packItem.packId != -4)
        [_hotPacksView clear];
    
    _esgViewController.sgViewController.hideEmoji = packItem.packId == -4;
    
    [_hotPacksView.containerView setHidden:packItem.packId != -4];
    [_gifContainer setHidden:packItem.packId != -3];
    [_stickers.containerView setHidden:packItem.packId == -3];
    
    if(selectItem) {
        
        TGStickerPackView *ocell = (TGStickerPackView *)[_tableView cellForRowAtIndex:[_packs indexOfObject:_selectedItem]];
        [ocell setSelected:NO];
        [self selectItem:packItem];
        TGStickerPackView *ncell = (TGStickerPackView *)[_tableView cellForRowAtIndex:[_packs indexOfObject:packItem]];
        [ncell setSelected:YES];
    }
    

    
    if(packItem.packId == -2) {
        
        
        
        TGStickersSettingsViewController *settingViewController = [[TGStickersSettingsViewController alloc] initWithFrame:NSZeroRect];
        
        settingViewController.action = [[ComposeAction alloc] initWithBehaviorClass:NSClassFromString(@"ComposeActionStickersBehavior")];
        
        settingViewController.action.editable = YES;
        
        if(!self.esgViewController.isLayoutStyle) {
            [self.esgViewController forceClose];
            [self.esgViewController.messagesViewController.navigationViewController pushViewController:settingViewController animated:YES];
        } else
            [self.esgViewController.navigationViewController pushViewController:settingViewController animated:YES];
        
        

        return;
    }
    
    [self removeScrollEvent];
    
    
    

    
    void (^block)(BOOL animated) = ^(BOOL animated){
        
        NSRect prect = [_tableView rectOfRow:[_packs indexOfObject:packItem]];
        
        NSRect rect = NSMakeRect(MAX(NSMinX(prect) - (NSWidth(_tableView.frame) - NSWidth(prect))/2.0f,0), NSMinY(prect), NSWidth(_tableView.frame), NSHeight(_tableView.frame));
      
        
        [self.tableView.clipView scrollRectToVisible:rect animated:selectItem && animated completion:^(BOOL scrolled) {
           if(scrolled)
           {
               TGStickerPackView *ncell = (TGStickerPackView *)[_tableView cellForRowAtIndex:[_packs indexOfObject:packItem]];
               [ncell setSelected:YES];
           }
        }];
    };
    
    
    if(scrollToPack)
        [_stickers scrollToStickerPack:packItem.packId completionHandler:^{
            block(!disableAnimation);
            [self addScrollEvent];
        }];
    else {
        block(!disableAnimation);
        [self addScrollEvent];
    }
    
    
    
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
}

-(void)setFrame:(NSRect)frame {
    [super setFrame:frame];
}

- (NSUInteger)numberOfRowsInListView:(PXListView*)aListView {
    return _packs.count;
}
- (CGFloat)listView:(PXListView*)aListView heightOfRow:(NSUInteger)row {
    return _esgViewController.isLayoutStyle ? 50 : 44;
}
- (CGFloat)listView:(PXListView*)aListView widthOfRow:(NSUInteger)row {
    return MAX(roundf(NSWidth(self.frame)/(_packs.count )),48);
}
- (PXListViewCell*)listView:(PXListView*)aListView cellForRow:(NSUInteger)row {
    
    TGStickerPackView *cell = (TGStickerPackView *) [aListView dequeueCellWithReusableIdentifier:NSStringFromClass([TGStickerPackView class])];
    
    if(!cell) {
        cell = [[TGStickerPackView alloc] initWithFrame:NSMakeRect(0, 0, [self listView:aListView widthOfRow:row], [self listView:aListView heightOfRow:row])];
    } 
    
    cell.delegate = self;
    
    [cell setPackItem:_packs[row]];
    
    return cell;
}

@end
