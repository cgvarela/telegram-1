//
//  TGAudioPlayerListView.h
//  Telegram
//
//  Created by keepcoder on 03.06.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMView.h"
#import "MessageTableItemAudioDocument.h"
@interface TGAudioPlayerListView : TMView



@property (nonatomic,strong,readonly) NSArray *list;

@property (nonatomic,assign) long selectedId;

@property (nonatomic,strong) void (^changedAudio)(MessageTableItemAudioDocument *item);

@property (nonatomic,weak) TGAudioGlobalController *controller;

@property (nonatomic,assign) Class filterClass;


-(NSImage *)getAlbumImageFromItem:(MessageTableItemAudioDocument *)item;

-(void)selectNext;
-(void)selectPrev;

-(void)reloadData;

-(void)onShow;

-(void)close;

@end
