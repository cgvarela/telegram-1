//
//  MessageTableCellVideoView.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/13/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGModernMessageCellContainerView.h"
#import "MessageTableItemVideo.h"
#import "TGImageView.h"

@interface MessageTableCellVideoView : TGModernMessageCellContainerView
@property (nonatomic, strong) TGImageView *imageView;
@end
