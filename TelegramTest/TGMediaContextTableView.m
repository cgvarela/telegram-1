#import "TGMediaContextTableView.h"
#import "TMTableView.h"
#import "TMSearchTextField.h"
#import "SpacemanBlocks.h"
#import "TGImageView.h"
#import "TGExternalImageObject.h"
#import "TGVTVideoView.h"
#import "TMLoaderView.h"
#import "DownloadQueue.h"
#import "DownloadDocumentItem.h"
#import "DownloadExternalItem.h"
#import "TGContextImportantRowItem.h"
#import "TGModernStickRowItem.h"
@interface TGGifSearchRowView : TMRowView
@property (nonatomic, strong) NSTrackingArea *trackingArea;
@end

@interface TGGifSearchRowItem : TMRowItem
@property (nonatomic,strong) NSArray *gifs;
@property (nonatomic,assign) long randKey;
@property (nonatomic,strong) NSArray *proportions;
@property (nonatomic,strong) NSArray *imageObjects;
@property (nonatomic,assign) BOOL needCheckKeyWindow;
@property (nonatomic,assign) int height;
@end

@interface TGPicItemView : TMView
@property (nonatomic,strong) TGImageView *imageView;
@property (nonatomic,assign) NSSize size;
@end


@implementation TGPicItemView

static NSImage *tgContextPicCap() {
    static NSImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSRect rect = NSMakeRect(0, 0, 1, 1);
        image = [[NSImage alloc] initWithSize:rect.size];
        [image lockFocus];
        [NSColorFromRGB(0xf1f1f1) set];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path appendBezierPathWithRoundedRect:NSMakeRect(0, 0, rect.size.width, rect.size.height) xRadius:4 yRadius:4];
        [path fill];
        
        [image unlockFocus];
    });
    return image;
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _imageView = [[TGImageView alloc] initWithFrame:NSZeroRect];

        self.wantsLayer = YES;
        self.layer.borderColor = [NSColor whiteColor].CGColor;
        self.layer.borderWidth = 1;
        [self addSubview:_imageView];
    }
    
    return self;
}


-(void)setSize:(NSSize)size {
    _size = size;
    [_imageView setFrameSize:size];
    
    [_imageView setCenterByView:_imageView.superview];
    
    //[_imageView setFrame:NSMakeRect(MIN(- roundf((size.width - NSWidth(self.frame))/2),0), MIN(- roundf((size.height - NSHeight(self.frame))/2),0), size.width, size.height)];
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
     [_imageView setFrame:NSMakeRect(MIN(- roundf((_size.width - NSWidth(self.frame))/2),0), MIN(- roundf((_size.height - NSHeight(self.frame))/2),0), _size.width, _size.height)];
}

@end

@interface TGGifPlayerItemView : TMView {
    SMDelayedBlockHandle _handle;
    BOOL _prevState;
}
@property (nonatomic,strong) TGVTVideoView *player;
@property (nonatomic,strong) TMLoaderView *loaderView;

@property (nonatomic,strong) DownloadEventListener *downloadEventListener;

@property (nonatomic,strong) TLBotInlineResult *botResult;
@property (nonatomic,assign) NSSize size;
@property (nonatomic,strong) TGImageObject *imageObject;

@property (nonatomic,strong) TL_localMessage *fakeMessage;


@property (nonatomic,weak) TGMediaContextTableView *table;
@property (nonatomic,weak) TGGifSearchRowItem *item;


@end


@implementation TGGifPlayerItemView

-(id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {

        
        _fakeMessage = [[TL_localMessage alloc] init];
        
        _fakeMessage.media = [TL_messageMediaDocument createWithDocument:nil caption:@""];
        
        self.wantsLayer = YES;
        self.layer.borderColor = [NSColor whiteColor].CGColor;
        self.layer.borderWidth = 1.0;
        _loaderView = [[TMLoaderView alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)];
        [_loaderView setStyle:TMCircularProgressDarkStyle];
        
        
        _player = [[TGVTVideoView alloc] initWithFrame:NSZeroRect];
        
        
        [self addSubview:_player];
        
        
        [self addSubview:_loaderView];
        
        
        
        _downloadEventListener = [[DownloadEventListener alloc] init];
        
        weak();
        
        [_downloadEventListener setCompleteHandler:^(DownloadItem *item) {
            
            __strong TGGifPlayerItemView *strongSelf = weakSelf;
            
            [ASQueue dispatchOnMainQueue:^{
                if(strongSelf != nil) {
                    [strongSelf startDownload];
                }
            }];
            
            
        }];
        
        [_downloadEventListener setProgressHandler:^(DownloadItem *item) {
            __strong TGGifPlayerItemView *strongSelf = weakSelf;
            
            [ASQueue dispatchOnMainQueue:^{
                if(strongSelf != nil) {
                    [strongSelf.loaderView setProgress:item.progress animated:YES];
                }
            }];
        }];
        
        [_downloadEventListener setErrorHandler:^(DownloadItem *item) {
            __strong TGGifPlayerItemView *strongSelf = weakSelf;
            
            [ASQueue dispatchOnMainQueue:^{
                if(strongSelf != nil) {
                    
                }
            }];
        }];
        
       
        
    }
    
    return self;
}


-(void)deleteLocalGifAction:(BTRButton *)button {
    if(self.table.deleteLocalGif) {
        self.table.deleteLocalGif(self.botResult);
    }
}

-(void)setSize:(NSSize)size {
    _size = size;
    [_player setFrame:NSMakeRect(MIN(- roundf((size.width - NSWidth(self.frame))/2),0), MIN(- roundf((size.height - NSHeight(self.frame))/2),0), MAX(size.width,NSWidth(self.frame)), MAX(size.height,NSHeight(self.frame)))];

}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [_player setFrame:NSMakeRect(MIN(- roundf((_size.width - NSWidth(self.frame))/2),0), MIN(- roundf((_size.height - NSHeight(self.frame))/2),0), MAX(_size.width,NSWidth(self.frame)), MAX(_size.height,NSHeight(self.frame)))];
    
}

static NSMenu *deleteMenu;

-(void)rightMouseDown:(NSEvent *)theEvent {
    
    if(_table.deleteLocalGif) {
        
        weak();
        
        deleteMenu = [[NSMenu alloc] initWithTitle:@"remove"];
        [deleteMenu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Messages.Selected.Delete", nil) withBlock:^(id sender) {
            
            weakSelf.table.deleteLocalGif(weakSelf.botResult);
            
        }]];
        
        [NSMenu popUpContextMenu:deleteMenu withEvent:theEvent forView:self];
    }
}

-(void)mouseUp:(NSEvent *)theEvent {
    if(deleteMenu) {
        [deleteMenu cancelTrackingWithoutAnimation];
        if(deleteMenu.itemArray.count > 0)
            [deleteMenu removeItemAtIndex:0];
        deleteMenu = nil;
    } else {
        [super mouseUp:theEvent];
    }
}

-(void)setBotResult:(TLBotInlineResult *)botResult {
    
    _prevState = NO;
    [_player setPath:nil];
    
    _botResult = botResult;
    
    _fakeMessage.media.document = _botResult.document;
}


-(void)setImageObject:(TGImageObject *)imageObject {
    if([imageObject isKindOfClass:[ImageObject class]]) {
        _imageObject = imageObject;
    } else
        _imageObject = nil;
}

-(void)dealloc {
    [self.downloadItem removeEvent:_downloadEventListener];
    [deleteMenu cancelTrackingWithoutAnimation];
    if(deleteMenu.itemArray.count > 0)
        [deleteMenu removeItemAtIndex:0];
}

-(void)updateContainer {
    
    _prevState = NO;
    [_loaderView removeFromSuperview];
    [self addSubview:_loaderView];
    [_loaderView setHidden:self.isset];
    
    if(_loaderView.isHidden) {
        [_loaderView setCurrentProgress:0];
    } else {
        [_loaderView setProgress:self.downloadItem.progress animated:YES];
        [_loaderView setCenterByView:self];
    }
    
    [_player setImageObject:_imageObject];
    
    
    [self _didScrolledTableView:nil];
}

-(NSString *)path {
    if(self.botResult.document != nil) {
        return self.botResult.document.path_with_cache;
    } else {
        return path_for_external_link(self.botResult.content_url);
    }
}

-(BOOL)isset {
    if(self.botResult.document != nil) {
        return self.botResult.document.isset;
    } else {
        return fileSize(self.path) > 0;
    }
}

-(NSUInteger)hash {
    return self.botResult.document != nil ? self.botResult.document.n_id : [self.botResult.content_url hash];
}


-(DownloadItem *)downloadItem {
    
    DownloadItem *item = [DownloadQueue find:self.hash];
    
    return item;
}


-(void)startDownload {
    
    if(!self.isset) {
                
        DownloadItem *item;
        
        if(!self.downloadItem) {
            if(self.botResult.document != nil) {
                item = [[DownloadDocumentItem alloc] initWithObject:_fakeMessage];
            } else {
                item = [[DownloadExternalItem alloc] initWithObject:self.botResult.content_url];
            }
            
            
            [item start];
            
            [self.downloadItem addEvent:self.downloadEventListener];
        }
        
        
    }
    
    [self updateContainer];
}

-(void)cancelDownload {
    [[self downloadItem] cancel];
}


-(void)_didScrolledTableView:(NSNotification *)notification {
    
    BOOL (^check_block)() = ^BOOL() {
        
        BOOL completelyVisible = self.visibleRect.size.width > 0 && self.visibleRect.size.height > 0;
                
        return  completelyVisible && ((self.window != nil && (!self.item.needCheckKeyWindow || self.window.isKeyWindow )) || notification == nil) && self.isset  && ![self inLiveResize];
        
    };
    
    cancel_delayed_block(_handle);
        
    dispatch_block_t block = ^{
        BOOL nextState = check_block();
        
        if(_prevState != nextState) {
            [_player setPath:nextState ? self.path : nil];
        }
        
        
        _prevState = nextState;
    };
    
    if(!check_block())
        block();
    else
        _handle = perform_block_after_delay(0.03, block);
    
    [self.loaderView setHidden:self.isset];
    
}

-(void)removeFromSuperview {
    [super removeFromSuperview];
    [_player setPath:nil];
}

-(void)viewDidMoveToWindow {
    if(self.window == nil) {
        
        [self removeScrollEvent];
        [_player setPath:nil];
        _prevState = NO;
        [self.downloadItem removeEvent:_downloadEventListener];
        
    } else {
        
        [self addScrollEvent];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didScrolledTableView:) name:NSWindowDidBecomeKeyNotification object:self.window];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didScrolledTableView:) name:NSWindowDidResignKeyNotification object:self.window];
        
        [self _didScrolledTableView:nil];
    }
}

-(void)addScrollEvent {
    id clipView = [[self.item.table enclosingScrollView] contentView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_didScrolledTableView:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:clipView];
    
}

-(void)removeScrollEvent {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end




@implementation TGGifSearchRowItem

-(id)initWithObject:(id)object sizes:(NSArray *)sizes {
    if(self = [super initWithObject:object]) {
        _gifs = object;
        _randKey = rand_long();
        _proportions = sizes;
        
        NSMutableArray *imageObjects = [NSMutableArray array];
        
        [_gifs enumerateObjectsUsingBlock:^(TLBotInlineResult *botResult, NSUInteger idx, BOOL * _Nonnull stop) {
            
            TGImageObject *imageObject;
            
            if(botResult.photo.sizes.count > 0) {
                
                TLPhotoSize *size = botResult.photo.sizes[MIN(2,botResult.photo.sizes.count-1)];
                
                imageObject = [[TGImageObject alloc] initWithLocation:size.location placeHolder:nil sourceId:0 size:size.size];
            } else if([botResult.document.thumb isKindOfClass:[TL_photoSize class]] || [botResult.document.thumb isKindOfClass:[TL_photoCachedSize class]]) {
                
                TLPhotoSize *size = botResult.document.thumb;
                
                imageObject = [[TGImageObject alloc] initWithLocation:size.location placeHolder:botResult.document.thumb.bytes.length > 0 ?[[NSImage alloc] initWithData:botResult.document.thumb.bytes] : nil sourceId:0 size:size.size];
            } else if(botResult.thumb_url.length > 0) {
                imageObject = [[TGExternalImageObject alloc] initWithURL:botResult.thumb_url];
            } else if([botResult.type isEqualToString:@"photo"] && botResult.content_url.length > 0) {
                imageObject = [[TGExternalImageObject alloc] initWithURL:botResult.content_url];
            } else if(botResult.send_message.geo != nil) {
                
                NSSize size = [sizes[idx] sizeValue];
                
                NSString *gSize = [NSString stringWithFormat:@"%dx%d",IS_RETINA ? (int)(size.width*2.0f) : (int)size.width, IS_RETINA ? (int)(size.height*2.0f) : (int)size.height];
                
                imageObject = [[TGExternalImageObject alloc] initWithURL:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?center=%f,%f&zoom=15&size=%@&sensor=true", botResult.send_message.geo.lat,  botResult.send_message.geo.n_long, gSize]];
                imageObject.imageProcessor = [ImageUtils c_processor];
            }
            
            imageObject.imageSize = [sizes[idx] sizeValue];
            
            if(imageObject == nil)
                imageObject = (TGImageObject *) [[NSNull alloc] init];
            else if(botResult.document.stickerAttr) {
                
                TL_documentAttributeImageSize *imageSize = (TL_documentAttributeImageSize *)[botResult.document attributeWithClass:[TL_documentAttributeImageSize class]];
                
                NSSize size = imageSize ? NSMakeSize(imageSize.w, imageSize.h) : [sizes[idx] sizeValue];
                
                imageObject.reserved1 = @(YES);
                imageObject.imageSize = strongsize(size, 90);
            }
            
            [imageObjects addObject:imageObject];
            
            
        }];
        
        _imageObjects = [imageObjects copy];
        
    }
    
    return self;
}

-(Class)viewClass {
    return [TGGifSearchRowView class];
}

-(int)height {
    return 100;
}


-(NSUInteger)hash {
    return _randKey;
}

@end





@implementation TGGifSearchRowView

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
    }
    
    return self;
}


-(void)redrawRow {
    [super redrawRow];
    
   
    TGGifSearchRowItem *item = (TGGifSearchRowItem *)[self rowItem];
    
    [self removeAllSubviews];
    
    
    
    __block int x = 0;
    __block float max_x = 0;
    [item.proportions enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSSize size = [obj sizeValue];
        max_x+= size.width;
    }];
    
    int containerWidthDif = 0;
    
    if(max_x > NSWidth(self.frame)) {
        containerWidthDif = ceil((max_x - NSWidth(self.frame)) / (float)item.gifs.count);
    }
    
    
    [item.gifs enumerateObjectsUsingBlock:^(TLBotInlineResult *botResult, NSUInteger idx, BOOL * _Nonnull stop) {
        
        
        NSSize size = [item.proportions[idx] sizeValue];
        
        TMView *container; //self.subviews.count > idx ? self.subviews[idx] : nil;
        
        NSRect rect = NSMakeRect(x, 0, (idx == (item.gifs.count - 1) && !(item.table.count-1 == item.rowId) ? NSWidth(self.frame) - x : size.width - containerWidthDif), NSHeight(self.frame));
        
        if([botResult.content_type isEqualToString:@"video/mp4"] || (botResult.document && [botResult.document.mime_type isEqualToString:@"video/mp4"] && [botResult.document attributeWithClass:[TL_documentAttributeAnimated class]] != nil)) {
            
            TGGifPlayerItemView *videoContainer;
            
            if(container && [container isKindOfClass:[TGGifPlayerItemView class]]) {
                videoContainer = (TGGifPlayerItemView *) container;
                [videoContainer setFrame:rect];
            } else {
                [container removeFromSuperview];
                videoContainer = [[TGGifPlayerItemView alloc] initWithFrame:rect];
                [self addSubview:videoContainer];
            }
            
            videoContainer.size = size;
            
            videoContainer.botResult = botResult;
            videoContainer.table = item.table;
            videoContainer.item = item;
            [videoContainer setImageObject:item.imageObjects[idx]];
            [videoContainer startDownload];
            
           
            container = videoContainer;
            
        } else if(![item.imageObjects[idx] isKindOfClass:[NSNull class]]) {
            
            TGPicItemView *picContainer;
            
            if(container && [container isKindOfClass:[TGPicItemView class]]) {
                picContainer = (TGPicItemView *) container;
                [container setFrame:rect];
            } else {
                [container removeFromSuperview];
                picContainer = [[TGPicItemView alloc] initWithFrame:rect];
                [self addSubview:picContainer];
            }
            
            
            TGImageObject *object = item.imageObjects[idx];
            
            if([object.reserved1 boolValue]) {
                [picContainer setSize:object.imageSize];
            } else {
                [picContainer setSize:size];
            }
            
            
            [picContainer.imageView setObject:item.imageObjects[idx]];
            container = picContainer;
           
        } else {
            [container removeFromSuperview];
            container = nil;
        }
        
        container.autoresizingMask = NSViewWidthSizable | NSViewMinXMargin | NSViewMaxXMargin;
        if(container != nil) {
            
            x+= NSWidth(container.frame);
        }
        
    }];
    
}

-(void)mouseUp:(NSEvent *)theEvent {
    [super mouseUp:theEvent];
    
    NSView *view = [self hitTest:[self convertPoint:[theEvent locationInWindow] fromView:nil]];
    

    if(view && ![view isKindOfClass:[TGGifSearchRowView class]]) {
        while (view != nil && ![view isKindOfClass:[TGGifPlayerItemView class]] && ![view isKindOfClass:[TGPicItemView class]]) {
            view = view.superview;
        }
    }
    
    
    NSUInteger index = [self.subviews indexOfObject:view];

    
    TGGifSearchRowItem *item = (TGGifSearchRowItem *)[self rowItem];
    
    if(index < item.gifs.count) {
        [item.table.tm_delegate selectionDidChange:index item:item];
    }
    
}

-(void)mouseDown:(NSEvent *)theEvent {
    
}

-(void)setFrameSize:(NSSize)newSize {
     [super setFrameSize:NSMakeSize(NSWidth(self.rowItem.table.frame), newSize.height)];
}

@end


@interface TGMediaContextTableView () <TMTableViewDelegate>
@property (nonatomic,strong) NSMutableArray *items;
@end

@implementation TGMediaContextTableView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        self.tm_delegate = self;
        _items = [NSMutableArray array];
        _needCheckKeyWindow = YES;
    }
    
    return self;
}



- (CGFloat)rowHeight:(NSUInteger)row item:(TGGifSearchRowItem *) item {
    return item.height;
}
- (BOOL)isGroupRow:(NSUInteger)row item:(TMRowItem *) item {
    return NO;
}
- (TMRowView *)viewForRow:(NSUInteger)row item:(TMRowItem *) item {
    return [self cacheViewForClass:[item viewClass] identifier:NSStringFromClass([item viewClass]) withSize:NSMakeSize(NSWidth(self.frame), item.height)];
}
- (void)selectionDidChange:(NSInteger)row item:(TGGifSearchRowItem *) item {
    
    if(![item isKindOfClass:[TGContextImportantRowItem class]]) {
        TLBotInlineResult *botResult = item.gifs[row];
        
        if(_choiceHandler) {
            _choiceHandler(botResult);
        }
    } else {
        if(_choiceHandler) {
            _choiceHandler((TGGifSearchRowItem *)item);
        }
    }
    
    
    
}
- (BOOL)selectionWillChange:(NSInteger)row item:(TMRowItem *) item {
    return YES;
}
- (BOOL)isSelectable:(NSInteger)row item:(TMRowItem *) item {
    return YES;
}


-(NSArray *)makeRow:(NSMutableArray *)gifs isLastRowItem:(BOOL)isLastRowItem itemHeight:(int *)itemHeight {
    
    
    __block int currentWidth = 0;
    __block int maxHeight = 100;
    NSMutableArray *sizes = [[NSMutableArray alloc] init];
    
    dispatch_block_t block = ^{
        [gifs enumerateObjectsUsingBlock:^(TLBotInlineResult *botResult, NSUInteger idx, BOOL * _Nonnull stop) {
            
            TL_documentAttributeVideo *video = (TL_documentAttributeVideo *) [botResult.document attributeWithClass:[TL_documentAttributeVideo class]];
            
            NSSize thumbSize =NSMakeSize( botResult.document.thumb.w,  botResult.document.thumb.h);
            
            int w = MAX(video.w,botResult.w);
            int h = MAX(video.h,botResult.h);
            
            if(!video && thumbSize.width > 0 && thumbSize.height > 0) {
                                
                w = MIN(thumbSize.width,maxHeight);
                h = MIN(thumbSize.height,maxHeight);
            }
            
            if(botResult.photo.sizes.count > 0 && video == nil) {
                TLPhotoSize *s = botResult.photo.sizes[MIN(botResult.photo.sizes.count-1,2)];
                w = s.w;
                h = s.h;
            }
            
            
            
            NSSize size = convertSize(NSMakeSize(w,h), NSMakeSize(INT32_MAX, maxHeight));
            
            if(size.width < maxHeight || size.height < maxHeight) {
                int max = MAX(maxHeight - size.width,maxHeight - size.height);
                
                size.width+=max;
                size.height+=max;
                
            
            }
            
            if(!isLastRowItem && idx == (gifs.count - 1)) {
                if(currentWidth+size.width < NSWidth(self.frame)) {
                    int dif = NSWidth(self.frame) - (currentWidth+size.width);
                    
                    size.width+=dif;
                    size.height+=dif;
                }
                
            }
            
            currentWidth+=size.width;
            
            [sizes addObject:[NSValue valueWithSize:size]];
            
        }];
    };
    
    
    
    
    while (1) {
        currentWidth = 0;
        [sizes removeAllObjects];
        
        block();
        
        if((currentWidth - NSWidth(self.frame)) > maxHeight && gifs.count > 1) {
            [gifs removeLastObject];
            continue;
        }
        
        
        if((currentWidth < NSWidth(self.frame) && !isLastRowItem) && gifs.count > 0) {
            
            maxHeight+=(6*gifs.count);
            
        } else
            break;
        
    }
    
    *itemHeight = maxHeight;
    
    return sizes;
    
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:NSMakeSize(NSWidth(self.superview.frame), newSize.height)];
    
    [self enumerateAvailableRowViewsUsingBlock:^(__kindof NSTableRowView * _Nonnull rowView, NSInteger row) {
        [rowView.subviews[0] setFrameSize:NSMakeSize(newSize.width, NSHeight(rowView.subviews[0].frame))];
    }];
}

-(void)viewDidEndLiveResize {
    [super viewDidEndLiveResize];
    
    NSArray *items = [_items copy];
    
    [self clear];
    [self drawResponse:items];
}


-(void)setNeedLoadNext:(void (^)(BOOL))needLoadNext {
    _needLoadNext = needLoadNext;
    
    weak();
    
    [self.scrollView setScrollWheelBlock:^{
        if(weakSelf.needLoadNext) {
            weakSelf.needLoadNext([weakSelf.scrollView isNeedUpdateBottom]);
        }
    }];
}

-(void)clear {
    
    BOOL needCheckKey = _needCheckKeyWindow;
    
    _needCheckKeyWindow = YES;
    
    
    
    [self removeAllItems:YES];
    _items = [NSMutableArray array];
    
    _needCheckKeyWindow = needCheckKey;
    

}


-(void)drawResponse:(NSArray *)items {
    
    NSMutableArray *filter = [NSMutableArray array];
    
    __block TGContextImportantRowItem *switchItem;
    
    [items enumerateObjectsUsingBlock:^(TLBotInlineResult *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if(![obj isKindOfClass:[TGContextImportantRowItem class]] && ![obj isKindOfClass:[TGModernStickRowItem class]]) {
            [filter addObject:obj];
        } else if([obj isKindOfClass:[TGContextImportantRowItem class]]) {
            switchItem = (TGContextImportantRowItem *) obj;
        }
        
    }];
    if(switchItem) {
        [self insert:@[switchItem] startIndex:0 tableRedraw:YES];
    }
    
    
    items = filter;

    
    
    
    [_items addObjectsFromArray:items];
    
    
    TGGifSearchRowItem *prevItem = [[self.list filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.class == %@",[TGGifSearchRowItem class]]] lastObject];
    
     int f = roundf(NSWidth(self.frame)/100.0f);
    
     NSMutableArray *draw = [items mutableCopy];
    
    
    __block BOOL redrawPrev = NO;
    
    
    if(prevItem && prevItem.gifs.count < f) {
        [draw insertObjects:prevItem.gifs atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, prevItem.gifs.count)]];
        
        redrawPrev = YES;
    }
    
    dispatch_block_t next = ^{
        
        int rowCount = (int)draw.count;
        
        NSMutableArray *r = [[draw subarrayWithRange:NSMakeRange(0, rowCount)] mutableCopy];
        
        int itemHeight = 100;
        
        NSArray *s = [self makeRow:r isLastRowItem:r.count < rowCount || (f > rowCount && r.count <= rowCount) itemHeight:&itemHeight];
        
        [draw removeObjectsInArray:r];
        
        TGGifSearchRowItem *item = [[TGGifSearchRowItem alloc] initWithObject:[r copy] sizes:[s copy]];
        item.height = itemHeight;
        item.needCheckKeyWindow = _needCheckKeyWindow;
        if(redrawPrev) {
            NSUInteger index = [self.list indexOfObject:prevItem];
            
            [self.list replaceObjectAtIndex:index withObject:item];
            [self reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
            
            redrawPrev = NO;
        } else {
            [self addItem:item tableRedraw:YES];
        }
    };
    
    while (draw.count > 0) {
        next();
    }
    
    
}


-(int)hintHeight {
    
    __block int height = 0;
    
    [self.list enumerateObjectsUsingBlock:^(TMRowItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        height+=obj.height;
    }];
    
    return MIN(200,height);
}


-(void)draw {
    
}



-(void)dealloc {
    [self clear];
}


@end