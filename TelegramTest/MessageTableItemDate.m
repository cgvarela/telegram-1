//
//  MessageTableItemDate.m
//  Telegram
//
//  Created by keepcoder on 28/01/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "MessageTableItemDate.h"
#import "MessageTableCellDateView.h"
@implementation MessageTableItemDate

-(id)initWithObject:(id)object {
    if(self = [super init]) {
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd MMMM"];
        
        [attr appendString:[formatter stringFromDate:object] withColor:GRAY_TEXT_COLOR];
        [attr setFont:[SettingsArchiver font13] forRange:attr.range];
        
        _text = [attr copy];
    }
    
    return self;
}


-(BOOL)makeSizeByWidth:(int)width {
    _textSize = [_text coreTextSizeForTextFieldForWidth:width];
    
    
    self.contentSize = self.blockSize = NSMakeSize(width, _textSize.height + self.defaultContentOffset * 2);
    
    
    [super makeSizeByWidth:width];
    
}

-(Class)viewClass {
    return [MessageTableCellDateView class];
}

@end
