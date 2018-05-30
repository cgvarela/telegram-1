//
//  TGWebpageContainer.m
//  Telegram
//
//  Created by keepcoder on 01.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGWebpageContainer.h"
#import "TGCTextView.h"
#import "TGPhotoViewer.h"
#import "TGEmbedModalView.h"
#import "TGWebpageGifContainer.h"
#import "TGWebpageDocumentContainer.h"
@interface TGWebpageContainer ()
@property (nonatomic,strong,readonly) TMView *containerView;
@end

@implementation TGWebpageContainer

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    
    [BLUE_SEPARATOR_COLOR setFill];
    
    NSRectFill(NSMakeRect(0, 0, 2, NSHeight(self.frame)));
}

-(void)mouseDown:(NSEvent *)theEvent {
    if(![self mouseInContainer:theEvent] || [self isKindOfClass:[TGWebpageDocumentContainer class]]) {
        [super mouseDown:theEvent];
    }
}

-(BOOL)mouseInContainer:(NSEvent *)theEvent {
    return [self mouse:[self convertPoint:theEvent.locationInWindow fromView:nil] inRect:_containerView.frame];
}

-(void)_didChangeBackgroundColorWithAnimation:(POPBasicAnimation *)anim toColor:(NSColor *)color {
    
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        _containerView = [[TMView alloc] initWithFrame:self.bounds];
        [_containerView setIsFlipped:YES];
        
        _containerView.wantsLayer = YES;
        
        [super addSubview:_containerView];
        
        
        dispatch_block_t block = ^ {
            [self showPhoto];
        };
        
        
        _descriptionField = [[TGCTextView alloc] initWithFrame:NSZeroRect];
        
        
        [self addSubview:_descriptionField];
        
        [_descriptionField setEditable:YES];
                
        
        self.author = [TMTextField defaultTextField];
        
        
        [super addSubview:self.author];
        
        
        _imageView = [[TGImageView alloc] initWithFrame:NSZeroRect];
        
        _imageView.cornerRadius = 4;
        [_imageView setContentMode:BTRViewContentModeScaleAspectFill];
        
        [_imageView setTapBlock:block];
        
        [self addSubview:_imageView];
        
        _siteName = [TMTextField defaultTextField];
        [[_siteName cell] setTruncatesLastVisibleLine:YES];
        [[_author cell] setTruncatesLastVisibleLine:YES];
        [self.siteName setFrameOrigin:NSMakePoint(8, -4)];
        [self.author setFrameOrigin:NSMakePoint(8, 12)];
        
        [super addSubview:_siteName];
    }
    
    return self;
}



-(void)addSubview:(NSView *)aView {
    [_containerView addSubview:aView];
}

-(void)setWebpage:(TGWebpageObject *)webpage {
    _webpage = webpage;
    
    
    [_containerView setFrame:NSMakeRect([MessageTableItem defaultOffset], self.webpage.blockHeight - self.webpage.size.height , webpage.size.width,self.webpage.size.height )];
    
    [self.author setHidden:!webpage.author];
    
    if(webpage.author ) {
        [self.author setAttributedStringValue:webpage.author];
        [self.author setFrameSize:NSMakeSize(NSWidth(self.frame) - NSMinX(self.author.frame), 20)];
    }

    [self.siteName setFrameSize:NSMakeSize(NSWidth(self.frame) - NSMinX(self.author.frame), 20)];
    [self.siteName setAttributedStringValue:webpage.siteName];

    
    if(!_imageView.isHidden) {
        [_imageView setObject:webpage.imageObject];
        
        [webpage.imageObject.supportDownloadListener setProgressHandler:^(DownloadItem *item) {
            
            [ASQueue dispatchOnMainQueue:^{
                
                [self.loaderView setProgress:item.progress animated:YES];
                
            }];
            
        }];
        
        [webpage.imageObject.supportDownloadListener setCompleteHandler:^(DownloadItem *item) {
            
            [ASQueue dispatchOnMainQueue:^{
                
                [self updateState:0];
                
            }];
            
        }];

    }
    
    
}

-(BOOL)isFlipped {
    return YES;
}

-(void)updateState:(TMLoaderViewState)state {
    
    if(!self.item.isset) {
        [_loaderView removeFromSuperview];
        
        _loaderView = [[TMLoaderView alloc] initWithFrame:NSMakeRect(0, 0, 40, 40)];
        
        [_loaderView setStyle:TMCircularProgressDarkStyle];
        
        
        [_imageView addSubview:_loaderView];
        [self.loaderView setCenterByView:_imageView];
        
        [self.loaderView setState:state];
        
        [self.loaderView setProgress:self.webpage.imageObject.downloadItem.progress animated:NO];
        
        if(self.loaderView.currentProgress > 0) {
            [self.loaderView setProgress:self.loaderView.currentProgress animated:YES];
        }
 

    } else  {
        [_loaderView removeFromSuperview];
    }

}

-(NSSize)containerSize {
    return _containerView.frame.size;
}

-(int)maxTextWidth {
    
    int width = self.containerSize.width;
    
    
    return width;
}

-(int)textX {
    
    if([self.webpage.webpage.type isEqualToString:@"profile"]) {
        return 65; // 60 + 5
    }
    
    return 0;
}


-(void)showPhoto {
    
    if(![self.webpage.webpage.type isEqualToString:@"profile"]) {
        
        PreviewObject *previewObject =[[PreviewObject alloc] initWithMsdId:self.webpage.webpage.photo.n_id media:[self.webpage.webpage.photo.sizes lastObject] peer_id:0];
        
        previewObject.reservedObject1 = self.item.message;
        previewObject.reservedObject = self.imageView.image;
        
        if([self.webpage.webpage.type isEqualToString:@"video"] && [self.webpage.webpage.embed_type isEqualToString:@"video/mp4"]) {
            
            previewObject.reservedObject = @{@"url":[NSURL URLWithString:self.webpage.webpage.embed_url],@"size":[NSValue valueWithSize:NSMakeSize(self.webpage.webpage.embed_width, self.webpage.webpage.embed_height)]};
            
            
        } else if([self.webpage.webpage.embed_type isEqualToString:@"iframe"]) {

            
            TGEmbedModalView *embed = [[TGEmbedModalView alloc] init];
            
            [embed setWebpage:self.webpage.webpage];
            
            [embed show:self.window animated:YES];
            return;
        } else if([self.webpage.webpage.type isEqualToString:@"video"]) {
            open_link(self.webpage.webpage.url);
            return;
        }
        
        if(![self.webpage.webpage.type isEqualToString:@"gif"]) {
            [[TGPhotoViewer viewer] show:previewObject];
        }
        
        
        
    } else {
        if([self.webpage.webpage.type isEqualToString:@"profile"]) {
            open_link(self.webpage.webpage.display_url);
        }
    }
}




@end
