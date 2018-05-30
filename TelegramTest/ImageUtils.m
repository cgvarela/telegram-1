//
//  ImageUtils.m
//  TelegramTest
//
//  Created by keepcoder on 26.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "ImageUtils.h"
#import <Accelerate/Accelerate.h>
#import <QuickLook/QuickLook.h>
#import "NSImage+RHResizableImageAdditions.h"

#define CACHE_IMAGE(Name) NSImage* image_##Name () { \
return [NSImage imageNamed:@""#Name]; \
}


/*
 #define CACHE_IMAGE(Name) NSImage* image_##Name () { \
 static NSImage *image;\
 static dispatch_once_t onceToken;\
 dispatch_once(&onceToken, ^{\
 image = [NSImage imageNamed:@""#Name]; \
 }); \
 return image; \
 }
 */


CACHE_IMAGE(actions)
CACHE_IMAGE(actionsActive)
CACHE_IMAGE(actionsHover)
CACHE_IMAGE(addContact)
CACHE_IMAGE(AddSharedContact)
CACHE_IMAGE(AddSharedContactHighlighted)
CACHE_IMAGE(AppIcon)
CACHE_IMAGE(AttachFile)
CACHE_IMAGE(AttachLocation)
CACHE_IMAGE(AttachPhotoVideo)
CACHE_IMAGE(AttachTakePhoto)
CACHE_IMAGE(BottomAttach)
CACHE_IMAGE(boxBack)
CACHE_IMAGE(chat)
CACHE_IMAGE(chatHighlighted)
CACHE_IMAGE(ChatMessageError)
CACHE_IMAGE(DialogSelectedSendError)
CACHE_IMAGE(checked)
CACHE_IMAGE(ScrollDownArrow)
CACHE_IMAGE(clear)
CACHE_IMAGE(clearActive)
CACHE_IMAGE(clearHover)
CACHE_IMAGE(ClosePopupDialog)
CACHE_IMAGE(compose)
CACHE_IMAGE(composeActive)
CACHE_IMAGE(composeHover)
CACHE_IMAGE(Download)
CACHE_IMAGE(emojiContainer1)
CACHE_IMAGE(emojiContainer1Highlighted)
CACHE_IMAGE(emojiContainer2)
CACHE_IMAGE(emojiContainer2Highlighted)
CACHE_IMAGE(emojiContainer3)
CACHE_IMAGE(emojiContainer3Highlighted)
CACHE_IMAGE(emojiContainer4)
CACHE_IMAGE(emojiContainer4Highlighted)
CACHE_IMAGE(emojiContainer5)
CACHE_IMAGE(emojiContainer5Highlighted)
CACHE_IMAGE(emojiContainer6)
CACHE_IMAGE(emojiContainer6Highlighted)
CACHE_IMAGE(emojiContainer7)
CACHE_IMAGE(emojiContainer7Highlighted)
CACHE_IMAGE(GIFPlay)
CACHE_IMAGE(group)
CACHE_IMAGE(HeaderDropdownArrow)
CACHE_IMAGE(iconCancelDownload)
CACHE_IMAGE(kick)
CACHE_IMAGE(logo)
CACHE_IMAGE(logoAbout)
CACHE_IMAGE(MessageMapPin)
CACHE_IMAGE(muted)
CACHE_IMAGE(mutedSld)
CACHE_IMAGE(noDialogs)
CACHE_IMAGE(noResults)
CACHE_IMAGE(searchIcon)
CACHE_IMAGE(secret)
CACHE_IMAGE(secretBlack)
CACHE_IMAGE(secretGray)
CACHE_IMAGE(secretHiglighted)
CACHE_IMAGE(select)
CACHE_IMAGE(selectPopup)
CACHE_IMAGE(smile)
CACHE_IMAGE(typingGIF)
CACHE_IMAGE(unchecked)
CACHE_IMAGE(uncheckedHover)
CACHE_IMAGE(UnpinPhoto)
CACHE_IMAGE(VoiceMic)
CACHE_IMAGE(VoiceMicHighlighted)
CACHE_IMAGE(VoiceMicHighlighted2)
CACHE_IMAGE(TelegramNotifications)
CACHE_IMAGE(newConversationBroadcast)
CACHE_IMAGE(PlayButtonBig)
CACHE_IMAGE(ArrowWhite)
CACHE_IMAGE(ArrowGrey)
CACHE_IMAGE(Verify)
CACHE_IMAGE(VerifyWhite)
CACHE_IMAGE(DownloadIconGrey)
CACHE_IMAGE(DownloadIconWhite)
CACHE_IMAGE(DownloadPauseIconGrey)
CACHE_IMAGE(DownloadPauseIconWhite)
CACHE_IMAGE(LoadCancelGrayIcon)
CACHE_IMAGE(DocumentThumbIcon)
CACHE_IMAGE(LoadCancelWhiteIcon)
CACHE_IMAGE(PlayIconWhite)

CACHE_IMAGE(MessageStateRead)
CACHE_IMAGE(MessageStateSent)

CACHE_IMAGE(ClockMin)
CACHE_IMAGE(ClockHour)
CACHE_IMAGE(ClockFrame)


CACHE_IMAGE(MessageActionForward)
CACHE_IMAGE(MessageActionForwardActive)
CACHE_IMAGE(MessageActionDelete)
CACHE_IMAGE(MessageActionDeleteActive)

CACHE_IMAGE(MessageStateReadWhite)
CACHE_IMAGE(MessageStateSentWhite)
CACHE_IMAGE(SendingClockWhite)
CACHE_IMAGE(SendingClockGray)


CACHE_IMAGE(ContactsAddContactActive)
CACHE_IMAGE(ContactsAddContact)

CACHE_IMAGE(UsernameCheck)

CACHE_IMAGE(VoicePlay)
CACHE_IMAGE(VoicePause)

CACHE_IMAGE(SecretPhotoFire)


CACHE_IMAGE(PhotoViewerLeft)
CACHE_IMAGE(PhotoViewerRight)
CACHE_IMAGE(PhotoViewerMore)
CACHE_IMAGE(PhotoViewerClose)

CACHE_IMAGE(ChangenumberAlertIcon);

CACHE_IMAGE(SharedMediaDocumentStatusDownload);

CACHE_IMAGE(NoFiles);
CACHE_IMAGE(SadAttach);

CACHE_IMAGE(ComposeCheck);
CACHE_IMAGE(ComposeCheckActive);


CACHE_IMAGE(RemoveSticker);
CACHE_IMAGE(RemoveStickerActive);

CACHE_IMAGE(PasslockEnter);
CACHE_IMAGE(PasslockEnterHighlighted);

CACHE_IMAGE(CancelReply);

CACHE_IMAGE(ModernMessageYoutubeButton);


CACHE_IMAGE(ProgressWindowCheck);

CACHE_IMAGE(WebpageInstagramIcon);
CACHE_IMAGE(WebpageTwitterIcon);

CACHE_IMAGE(WebpageInstagramVideoPlay);


CACHE_IMAGE(AudioPlayerBack);
CACHE_IMAGE(AudioPlayerPlay);
CACHE_IMAGE(AudioPlayerNext);
CACHE_IMAGE(AudioPlayerPause);
CACHE_IMAGE(AudioPlayerClose);
CACHE_IMAGE(AudioPlayerStop);
CACHE_IMAGE(AudioPlayerList);
CACHE_IMAGE(AudioPlayerListActive);
CACHE_IMAGE(MusicStandartCover);


CACHE_IMAGE(InlineAudioPlayerBack);
CACHE_IMAGE(InlineAudioPlayerPlay);
CACHE_IMAGE(InlineAudioPlayerNext);
CACHE_IMAGE(InlineAudioPlayerPause);

CACHE_IMAGE(InlineAudioPlayerBackHover);
CACHE_IMAGE(InlineAudioPlayerPlayHover);
CACHE_IMAGE(InlineAudioPlayerNextHover);
CACHE_IMAGE(InlineAudioPlayerPauseHover);


CACHE_IMAGE(botCommand);
CACHE_IMAGE(botKeyboard);
CACHE_IMAGE(botKeyboardActive);
CACHE_IMAGE(SearchMessages);

CACHE_IMAGE(AudioPlayerPin);
CACHE_IMAGE(AudioPlayerPinActive);


CACHE_IMAGE(SearchUpDisabled);
CACHE_IMAGE(SearchDownDisabled);
CACHE_IMAGE(SearchUp);
CACHE_IMAGE(SearchDown);


CACHE_IMAGE(ZoomIn);
CACHE_IMAGE(ZoomOut);
CACHE_IMAGE(Camera);

CACHE_IMAGE(ChannelMessageAsAdmin);
CACHE_IMAGE(ChannelMessageAsAdminHighlighted);
CACHE_IMAGE(ChannelViews);

CACHE_IMAGE(PinConversation);
CACHE_IMAGE(PinnedConversation);


CACHE_IMAGE(ModernConversationSecretAccessoryTimer);

CACHE_IMAGE(ChannelShare);

CACHE_IMAGE(ModernMenuDeleteIcon);

CACHE_IMAGE(EditPhotoCamera);
CACHE_IMAGE(NoSharedLinks);
CACHE_IMAGE(StickerSettings);

CACHE_IMAGE(emojiContainer8);
CACHE_IMAGE(emojiContainer8Highlighted);

CACHE_IMAGE(CalendarIcon);

CACHE_IMAGE(TempAudioPreviewPlay);
CACHE_IMAGE(TempAudioPreviewPause);

CACHE_IMAGE(ConversationInputFieldBroadcastIconActive);
CACHE_IMAGE(ConversationInputFieldBroadcastIconInactive);

CACHE_IMAGE(ModernMessageCheckmark1);
CACHE_IMAGE(ModernMessageCheckmark2);

CACHE_IMAGE(bot_inline_keyboard_url);

CACHE_IMAGE(bot_inline_button_url);

CACHE_IMAGE(ModernMessageLocationPin);


CACHE_IMAGE(share_inline_bot);

CACHE_IMAGE(draftIcon);
CACHE_IMAGE(AudioPlayerVisibility);
CACHE_IMAGE(AudioPlayerVisibilityActive);
CACHE_IMAGE(ic_send);

CACHE_IMAGE(Player_Repeat);
CACHE_IMAGE(Player_RepeatActive);
CACHE_IMAGE(StickerLink);
CACHE_IMAGE(emojiGifContainer);
CACHE_IMAGE(MusicStandartCover_Active);


CACHE_IMAGE(pip_on);
CACHE_IMAGE(pip_off);
CACHE_IMAGE(Folder);
CACHE_IMAGE(trending);
CACHE_IMAGE(chat_pinned);
@implementation ImageUtils

NSImage *previewImageForDocument(NSString *path) {
    int sizeSquere = IS_RETINA ? 200 : 100;
    
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:(NSString *)kQLThumbnailOptionIconModeKey];
    
    CGImageRef quickLookIcon = QLThumbnailImageCreate(kCFAllocatorDefault, (__bridge CFURLRef)[NSURL fileURLWithPath:path], CGSizeMake(sizeSquere*2 , sizeSquere*2 ), (__bridge CFDictionaryRef)options);
        
    
    NSImage *thumbIcon = nil;
    
    if (quickLookIcon != NULL) {
        thumbIcon = [[NSImage alloc] initWithCGImage:quickLookIcon size:NSMakeSize(0, 0)];
        CFRelease(quickLookIcon);
    }
    
    
    CFStringRef fileExtension = (__bridge CFStringRef) [path pathExtension];
    CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
    
    if(UTTypeConformsTo(fileUTI, kUTTypeGIF)) {
        CFRelease(fileUTI);
        return thumbIcon;
    }
    

    if(!thumbIcon) {
        CFRelease(fileUTI);
      //  CFRelease(fileExtension);
        return nil;
    }
    
    CFRelease(fileUTI);
    
    NSSize needSize = NSMakeSize(100, 100);
    NSRect rect;
    if(thumbIcon.size.width > thumbIcon.size.height) {
        float k = thumbIcon.size.height / needSize.height;
        float width = roundf(thumbIcon.size.width / k);
        rect = NSMakeRect(-roundf((width - needSize.width) / 2), 0, width, needSize.height);
    } else {
        float k = thumbIcon.size.width / needSize.width;
        float height = roundf(thumbIcon.size.height / k);
        rect = NSMakeRect(0, -roundf((height - needSize.height) / 2), needSize.width, height);
    }

    NSImage *image = [[NSImage alloc] initWithSize:needSize];
    [image lockFocus];
    [thumbIcon drawInRect:rect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    [image unlockFocus];
    
    return image;
}

+ (NSImage*)roundCorners:(NSImage *)image size:(NSSize)size
{
    
    if(!image || image.size.width == 0 || image.size.height == 0)
        return image;
    NSImage *existingImage = image;
    NSSize existingSize = [existingImage size];
    NSSize newSize = NSMakeSize(existingSize.width, existingSize.height);
    
    
    NSImage *composedImage = [[NSImage alloc] initWithSize:newSize];
    
    [composedImage lockFocus];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    
    NSRect imageFrame = NSRectFromCGRect(CGRectMake(1, 1, image.size.width-1, image.size.height-1));
    
    NSBezierPath *clipPath = [NSBezierPath bezierPathWithRoundedRect:imageFrame xRadius:size.width yRadius:size.height];
    [clipPath setWindingRule:NSEvenOddWindingRule];
    [clipPath addClip];
    
    [image drawAtPoint:NSZeroPoint fromRect:NSMakeRect(0, 0, newSize.width, newSize.height) operation:NSCompositeSourceOver fraction:1];
    
    [composedImage unlockFocus];
    
    return composedImage;
}

+ (NSImage *)blurImage:(NSImage *)image blurRadius:(int)radius frameSize:(CGSize)size {
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)[image TIFFRepresentation], NULL);
    
    if(image.size.width == 0 || image.size.height == 0)
        return image;
    
    NSImage *newImage = nil;
    if(source != NULL) {
        CGImageRef imageRef =  CGImageSourceCreateImageAtIndex(source, 0, NULL);
        CFRelease(source);
        
        CGContextRef context = CGBitmapContextCreate(NULL/*data - pass NULL to let CG allocate the memory*/,
                                                     size.width,
                                                     size.height,
                                                     8 /*bitsPerComponent*/,
                                                     0 /*bytesPerRow - CG will calculate it for you if it's allocating the data.  This might get padded out a bit for better alignment*/,
                                                     [[NSColorSpace genericRGBColorSpace] CGColorSpace],
                                                     kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst);
        
        CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), imageRef);
        CGImageRef cgImage = CGBitmapContextCreateImage(context);
        CGContextRelease(context);
        
        
        CGImageRef cgBlurImage = CGImageCreateBlurredImage(cgImage, radius);
        //    CGImageRelease(imageRef);
        CGImageRelease(cgImage);
        
        newImage = [[NSImage alloc] initWithCGImage:cgBlurImage size:size];
        CGImageRelease(imageRef);
        CGImageRelease(cgBlurImage);
    }
    return newImage;
}

CGImageRef CGImageCreateBlurredImage(CGImageRef inImage, NSUInteger blurRadius)
{
    blurRadius = (blurRadius % 2) ? blurRadius : blurRadius + 1; // blurRadius must be odd
    size_t width = CGImageGetWidth(inImage);
    size_t height = CGImageGetHeight(inImage);
    size_t bytesPerRow = CGImageGetBytesPerRow(inImage);
    
    if(width == 0 || height == 0)
        return NULL;
    
    //    MTLog(@"width %zu", width);
    
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(inImage);
    CFDataRef dataRef = CGDataProviderCopyData(CGImageGetDataProvider(inImage));
    void *destinationData = malloc(bytesPerRow * height);
    
    vImage_Buffer sourceBuffer = {(void *)CFDataGetBytePtr(dataRef), height, width, bytesPerRow};
    vImage_Buffer destinationBuffer = {destinationData, height, width, bytesPerRow};
    // Tent convolve is within 3% of a gaussian blur.
    vImageTentConvolve_ARGB8888(&sourceBuffer, &destinationBuffer, NULL, 0, 0,(uint32_t) blurRadius, (uint32_t)blurRadius, NULL, kvImageEdgeExtend);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef imageContext = CGBitmapContextCreate(destinationData, width, height, 8, bytesPerRow, colorSpace, bitmapInfo);
    CGImageRef outImage = CGBitmapContextCreateImage(imageContext);
    
    CFRelease(dataRef);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(imageContext);
    free(destinationData);
    return outImage;
}


NSImage *TGIdenticonImage(NSData *data, CGSize size)
{
    
    uint8_t bits[128];
    memset(bits, 0, 128);
    
    [data getBytes:bits length:MIN(128, data.length)];
    
    static CGColorRef colors[6];
    
    //int ptr = 0;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      static const int textColors[] =
                      {
                          0xffffff,
                          0xd5e6f3,
                          0x2d5775,
                          0x2f99c9
                      };
                      
                      for (int i = 0; i < 4; i++)
                      {
                          colors[i] = CGColorRetain(NSColorFromRGB(textColors[i]).CGColor);
                      }
                  });
    
    
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0,CGColorSpaceCreateDeviceRGB(),kCGImageAlphaPremultipliedLast);
    
    int bitPointer = 0;
    
    float rectSize = floorf(size.width / 8.0f);
    
    for (int iy = 7; iy >= 0; iy--)
    {
        for (int ix = 0; ix < 8; ix++)
        {
            int32_t byteValue = get_bits(bits, bitPointer, 2);
            bitPointer += 2;
            int colorIndex = ABS(byteValue) % 4;
            
            
            CGContextSetFillColorWithColor(context, colors[colorIndex]);
            CGContextFillRect(context, CGRectMake(ix * rectSize, iy * rectSize, rectSize, rectSize));
        }
    }
    
    
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    
    
    
    NSImage *image = [[NSImage alloc] initWithCGImage:cgImage size:size];
    
    CGContextRelease(context);
    CGImageRelease(cgImage);
    
    return image;
}

static int32_t get_bits(uint8_t const *bytes, unsigned int bitOffset, unsigned int numBits)
{
    uint8_t const *data = bytes;
    numBits = (unsigned int)pow(2, numBits) - 1; //this will only work up to 32 bits, of course
    data += bitOffset / 8;
    bitOffset %= 8;
    return (*((int*)data) >> bitOffset) & numBits;
}


NSImage *cropCenterWithSize(NSImage *image, NSSize cropSize) {
    if(!image || cropSize.width == 0 || cropSize.height == 0)
        return image;
    
    NSImage *result = [[NSImage alloc] initWithSize:cropSize];
    
    NSRect cropedRect;
    
    if(image.size.width > image.size.height) {
        cropedRect = NSMakeRect(ceil((image.size.width - image.size.height) / 2), 0, image.size.height, image.size.height);
    } else {
        cropedRect = NSMakeRect(0, ceil((image.size.height - image.size.width) / 2), image.size.width, image.size.width);
    }
    if(!NSIsEmptyRect(cropedRect) && result.size.width > 0 && result.size.height > 0) {
        [result lockFocus];
        [image drawInRect:NSMakeRect(0, 0, result.size.width, result.size.height)
                 fromRect:cropedRect
                operation:NSCompositeCopy
                 fraction:1.0];
        [result unlockFocus];
    }
    
    
    return result;
}

NSData* compressImage(NSData *data, float coef) {
    NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithData:data];
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:coef] forKey:NSImageCompressionFactor];
    NSData *compressedData = [imageRep representationUsingType:NSJPEGFileType properties:options];
    return compressedData;
}


NSImage *imageFromFile(NSString *filePath) {
    NSImage *img = [[NSImage alloc] initWithContentsOfFile:filePath];
    return img;
}


NSImage *decompressedImage(NSImage *image) {
    
    if(image.size.width == 0 || image.size.height == 0)
        return image;
    
    CGContextRef context = CGBitmapContextCreate(NULL/*data - pass NULL to let CG allocate the memory*/,
                                                 image.size.width,
                                                 image.size.height,
                                                 8 /*bitsPerComponent*/,
                                                 0 /*bytesPerRow - CG will calculate it for you if it's allocating the data.  This might get padded out a bit for better alignment*/,
                                                 [[NSColorSpace genericRGBColorSpace] CGColorSpace],
                                                 kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst);
    
    NSGraphicsContext *nscontext =  [NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:NO];
    
    
    
    [NSGraphicsContext setCurrentContext:nscontext];
    
    
    [image drawAtPoint:NSMakePoint(0, 0) fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0f];
    
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    
    
    CGContextRelease(context);
    
    
    
    image = [[NSImage alloc] initWithCGImage:cgImage size:image.size];
    CGImageRelease(cgImage);

    return image;
    
}


NSImage *prettysize(NSImage *img) {
    if(img.representations.count > 0) {
        
        NSSize size = img.size;
        for (NSImageRep * imageRep in img.representations) {
            if ([imageRep pixelsWide] > size.width)
                size.width = [imageRep pixelsWide];
            if ([imageRep pixelsHigh] > size.height)
                size.height = [imageRep pixelsHigh];
        }
        img.size = size;
    }
    
    return img;
}

NSImage* strongResize(NSImage *image, int maxSize) {
    float scale = 1.0;
    NSImage *img = [image copy];
    
    if(img.size.width < maxSize && img.size.height < maxSize)
        return img;
    
    if(img.size.width > maxSize) {
        scale = maxSize/(float)img.size.width;
        img = [ImageUtils imageResize:img newSize:NSMakeSize(img.size.width * scale, img.size.height * scale)];
    }
    
    if(img.size.height > maxSize) {
        scale = maxSize/(float)img.size.height;
        img = [ImageUtils imageResize:img newSize:NSMakeSize(img.size.width * scale, img.size.height*scale)];
    }
    
    
    return img;
}

NSSize strongsize(NSSize from, float max)  {
    float scale;
    if (from.width > max) {
        scale = max/from.width;
        from.width = ceil(from.width * scale);
        from.height = ceil(from.height * scale);
    }
    if(from.height > max) {
        scale = max/from.height;
        from.width = ceil(from.width * scale);
        from.height = ceil(from.height * scale);
    }
    return from;
}

NSSize convertSize(NSSize from, NSSize maxSize)  {
    float scale;
    if (from.width > maxSize.width) {
        scale = maxSize.width/from.width;
        from.width = ceil(from.width * scale);
        from.height = ceil(from.height * scale);
    }
    if(from.height > maxSize.height) {
        scale =  maxSize.height/from.height;
        from.width = ceil(from.width * scale);
        from.height = ceil(from.height * scale);
    }
    return from;
}

NSImage * (^c_processor)(NSImage *, NSSize size) =  ^NSImage* (NSImage *image,NSSize size){
    return cropCenterWithSize(image, size);
};


NSImage * (^b_processor)(NSImage *, NSSize size) =  ^NSImage* (NSImage *image,NSSize size){
    return [ImageUtils blurImage:image blurRadius:20 frameSize:size];;
};


+(ImageProcessor)c_processor {
    return c_processor;
}

+(ImageProcessor)b_processor {
    return b_processor;
}

NSSize resizeToMaxCorner(NSSize from, float size) {
    NSSize newSize;
    
    if(from.width < 90)
        from.width = 90;
    
    if(from.height < 90)
        from.height = 90;
    
    if(from.width > from.height) {
        float k = from.width / size;
        newSize.width = size;
        newSize.height = ceil(from.height / k);
    } else {
        float k = from.height / size;
        newSize.height = size;
        newSize.width = ceil(from.width / k);
    }
    
    
    return newSize;
}

NSSize strongsizeWithMinMax(NSSize from, float min, float max) {
    float scale;
    
    NSSize converted = NSMakeSize(from.width, from.height);
    
    if (converted.width > max) {
        scale = max/converted.width;
        if(!scale) {
            MTLog(@"");
        }
        converted.width = ceil(converted.width * scale);
        converted.height = ceil(converted.height * scale);
    }
 
    if(converted.height > max) {
        scale = max/converted.height;
        if(!scale) {
            MTLog(@"");
        }
        converted.width = ceil(converted.width * scale);
        converted.height = ceil(converted.height * scale);
    }
    
    if(converted.width < min) {
        scale = min / converted.width;
        if(!scale) {
            MTLog(@"");
        }
        converted.width = ceil(converted.width * scale);
        converted.height = ceil(converted.height * scale);
    }
    
    if(converted.height < min) {
        scale = min / converted.height;
        if(!scale) {
            MTLog(@"");
        }
        converted.width = ceil(converted.width * scale);
        converted.height = ceil(converted.height * scale);
    }
   
//    if(converted.width > max)
//        converted.width = max;
//    
//    if(converted.height > max)
//        converted.height = max;
    
    if(isnan(converted.width) || isnan(converted.height)) {
        
    }
    return converted;
}


NSSize strongsizeWithSizes(NSSize from, NSSize min, NSSize max) {
    float scale;
    
    NSSize converted = NSMakeSize(from.width, from.height);
    
    if (converted.width > max.width) {
        scale = max.width/converted.width;
        if(!scale) {
            MTLog(@"");
        }
        converted.width = ceil(converted.width * scale);
        converted.height = ceil(converted.height * scale);
    }
    
    if(converted.height > max.height) {
        scale = max.height/converted.height;
        if(!scale) {
            MTLog(@"");
        }
        converted.width = ceil(converted.width * scale);
        converted.height = ceil(converted.height * scale);
    }
    
    if(converted.width < min.width) {
        scale = min.width / converted.width;
        if(!scale) {
            MTLog(@"");
        }
        converted.width = ceil(converted.width * scale);
        converted.height = ceil(converted.height * scale);
    }
    
    if(converted.height < min.height) {
        scale = min.height / converted.height;
        if(!scale) {
            MTLog(@"");
        }
        converted.width = ceil(converted.width * scale);
        converted.height = ceil(converted.height * scale);
    }
    
    if(converted.width > max.width)
        converted.width = max.width;
    
    if(converted.height > max.height)
        converted.height = max.height;
    
    if(isnan(converted.width) || isnan(converted.height)) {
        
    }
    return converted;
}



+ (NSImage *)imageResize:(NSImage*)anImage newSize:(NSSize)newSize {
    NSImage *sourceImage = anImage;
    [sourceImage setScalesWhenResized:YES];
    
    if(anImage.size.width == 0 || anImage.size.height == 0)
        return anImage;
    
    if (![sourceImage isValid]) {
        MTLog(@"Invalid Image");
    } else {

        NSImage *smallImage = [[NSImage alloc] initWithSize: newSize];
        [smallImage lockFocus];
        [sourceImage setSize: newSize];
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
        [sourceImage drawAtPoint:NSMakePoint(0, 0) fromRect:NSZeroRect operation:NSCompositeCopy fraction:1];
        [smallImage unlockFocus];
        return smallImage;
    }
    return nil;
}


NSImageView *imageViewWithImage(NSImage *image) {
    NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0,0,image.size.width,image.size.height)];
    imageView.image = image;
    
    return imageView;
}

NSData *jpegNormalizedData(NSImage *image) {
    
    if(image.size.width > 0 && image.size.height > 0) {
        NSBitmapImageRep* myBitmapImageRep;
        
        //this will get a bitmap from the image at 1 point == 1 pixel, which is probably what you want
        NSSize imageSize = [image size];
        [image lockFocus];
        myBitmapImageRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0, 0, imageSize.width , imageSize.height)];
        [image unlockFocus];
        
        
        CGFloat imageCompression = 0.5; //between 0 and 1; 1 is maximum quality, 0 is maximum compression
        
        // set up the options for creating a JPEG
        NSDictionary* jpegOptions = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithDouble:imageCompression], NSImageCompressionFactor,
                                     [NSNumber numberWithBool:YES], NSImageProgressive,
                                     nil];
        
        return[myBitmapImageRep representationUsingType:NSJPEGFileType properties:jpegOptions];
    }
    
    return nil;
   
}

NSData *pngNormalizedData(NSImage *image) {
    NSBitmapImageRep* myBitmapImageRep;
    
    //this will get a bitmap from the image at 1 point == 1 pixel, which is probably what you want
    NSSize imageSize = [image size];
    [image lockFocus];
    myBitmapImageRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0, 0, imageSize.width , imageSize.height)];
    [image unlockFocus];
    
    
    CGFloat imageCompression = 0.5; //between 0 and 1; 1 is maximum quality, 0 is maximum compression
    
    // set up the options for creating a JPEG
    NSDictionary* jpegOptions = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithDouble:imageCompression], NSImageCompressionFactor,
                                 [NSNumber numberWithBool:YES], NSImageProgressive,
                                 nil];
    
    return[myBitmapImageRep representationUsingType:NSPNGFileType properties:jpegOptions];
}


float scaleFactor() {
    
    __block CGFloat scaleFactor = 1.0f;
    
    static ASQueue *q;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        q = [[ASQueue alloc] initWithName:"backingScaleQueue"];
    });
    
    [q dispatchOnQueue:^{
        scaleFactor = [[NSScreen mainScreen] backingScaleFactor];
    } synchronous:YES];
    
    return scaleFactor;
}

NSImage *renderedImage(NSImage * oldImage, NSSize size) {
    
    NSImage *image = nil;
    
    if(!oldImage || oldImage.size.width == 0 || oldImage.size.height == 0)
        return oldImage;
    
    @autoreleasepool {
        
        static CALayer *layer;
        if(!layer) {
            layer = [CALayer layer];
        }
        
        [[NSGraphicsContext currentContext] saveGraphicsState];
        
        
        CGFloat displayScale = scaleFactor();
        
        size.width *= displayScale;
        size.height *= displayScale;
        
        [oldImage lockFocus];
        
        CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)[oldImage TIFFRepresentation], NULL);
        
        if(source != NULL) {
            CGImageRef maskRef =  CGImageSourceCreateImageAtIndex(source, 0, NULL);
            CFRelease(source);
            
            CGContextRef context = CGBitmapContextCreate(NULL/*data - pass NULL to let CG allocate the memory*/,
                                                         size.width,
                                                         size.height,
                                                         8 /*bitsPerComponent*/,
                                                         0 /*bytesPerRow - CG will calculate it for you if it's allocating the data.  This might get padded out a bit for better alignment*/,
                                                         [[NSColorSpace genericRGBColorSpace] CGColorSpace],
                                                         kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst);
            
            
            CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), maskRef);
            
            CGImageRef cgImage = CGBitmapContextCreateImage(context);
            
            
            
            CGContextRelease(context);
            
            
            
            image = [[NSImage alloc] initWithCGImage:cgImage size:size];
            CGImageRelease(cgImage);
            CGImageRelease(maskRef);
        }
        
        [oldImage unlockFocus];
        
        
        [[NSGraphicsContext currentContext] restoreGraphicsState];
    }
    
    
    
    
    return image;
}


NSImage *cropImage(NSImage *image,NSSize backSize, NSPoint difference) {
    
    if(image.size.width == 0 || image.size.height == 0)
        return image;
    
    NSImage *source = image;
    NSImage *target = [[NSImage alloc]initWithSize:backSize];
    
    [target lockFocus];
    [source drawInRect:NSMakeRect(0,0,backSize.width,backSize.height)
              fromRect:NSMakeRect(difference.x,difference.y,backSize.width,backSize.height)
             operation:NSCompositeCopy
              fraction:1.0];
    [target unlockFocus];
    
    return target;
}

NSImage *imageWithRoundCorners(NSImage *oldImage, int cornerRadius, NSSize size) {
    
    if(!oldImage || oldImage.size.width == 0 || oldImage.size.height == 0)
    return oldImage;
    
    CALayer *layer = [CALayer layer];
    NSImage *image = nil;
    @autoreleasepool {
        CGFloat displayScale = scaleFactor();
        
        size.width *= displayScale;
        size.height *= displayScale;
        
        CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)[oldImage TIFFRepresentation], NULL);
        
        if(source != NULL) {
            CGImageRef maskRef =  CGImageSourceCreateImageAtIndex(source, 0, NULL);
            CFRelease(source);
            
            [layer setContents:(__bridge id)(maskRef)];
            [layer setFrame:NSMakeRect(0, 0, size.width, size.height)];
            [layer setBounds:NSMakeRect(0, 0, size.width, size.height)];
            [layer setMasksToBounds:YES];
            [layer setCornerRadius:cornerRadius];
            
            CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, [[NSColorSpace genericRGBColorSpace] CGColorSpace], kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst);
            [layer renderInContext:context];
            
            CGImageRef cgImage = CGBitmapContextCreateImage(context);
            CGContextRelease(context);
            
            image = [[NSImage alloc] initWithCGImage:cgImage size:NSMakeSize(size.width * 0.5, size.height * 0.5)];
            CGImageRelease(cgImage);
            CGImageRelease(maskRef);
        }
    }
    
    return image;
}


NSImage *gray_resizable_placeholder() {
    static RHResizableImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSRect rect = NSMakeRect(0, 0, 50, 50);
        NSImage *img = [[NSImage alloc] initWithSize:rect.size];
        [img lockFocus];
        [GRAY_BORDER_COLOR set];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path appendBezierPathWithRoundedRect:NSMakeRect(0, 0, rect.size.width, rect.size.height) xRadius:4 yRadius:4];
        [path fill];
        [img unlockFocus];
        
        image = [[RHResizableImage alloc] initWithImage:img capInsets:RHEdgeInsetsMake(5, 5, 5, 5)];
        
    });
    return image;
}

NSImage *gray_circle_resizable_placeholder() {
    static RHResizableImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSRect rect = NSMakeRect(0, 0, 50, 50);
        NSImage *img = [[NSImage alloc] initWithSize:rect.size];
        [img lockFocus];
        [GRAY_BORDER_COLOR set];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path appendBezierPathWithRoundedRect:NSMakeRect(0, 0, rect.size.width, rect.size.height) xRadius:25 yRadius:25];
        [path fill];
        [img unlockFocus];
        
        image = [[RHResizableImage alloc] initWithImage:img capInsets:RHEdgeInsetsMake(5, 5, 5, 5)];
        
    });
    return image;
}



NSImage *blue_circle_background_image() {
    static NSImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSRect rect = NSMakeRect(0, 0, 40, 40);
        image = [[NSImage alloc] initWithSize:rect.size];
        [image lockFocus];
        [BLUE_COLOR set];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path appendBezierPathWithRoundedRect:NSMakeRect(0, 0, rect.size.width, rect.size.height) xRadius:rect.size.width/2 yRadius:rect.size.height/2];
        [path fill];
        [image unlockFocus];
    });
    return image;
}

NSImage *gray_circle_background_image() {
    static NSImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSRect rect = NSMakeRect(0, 0, 40, 40);
        image = [[NSImage alloc] initWithSize:rect.size];
        [image lockFocus];
        [BLUE_COLOR set];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path appendBezierPathWithRoundedRect:NSMakeRect(0, 0, rect.size.width, rect.size.height) xRadius:rect.size.width/2 yRadius:rect.size.height/2];
        [path fill];
        [image unlockFocus];
    });
    return image;
}
NSImage *play_image() {
    static NSImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSRect rect = NSMakeRect(0, 0, image_VoicePlay().size.width + 5, image_PlayIconWhite().size.height);
        image = [[NSImage alloc] initWithSize:rect.size];
        [image lockFocus];
        
        [image_VoicePlay() drawInRect:NSMakeRect(5, 0, image_VoicePlay().size.width, image_VoicePlay().size.height) fromRect:NSZeroRect operation:NSCompositeHighlight fraction:1];
        
        [image unlockFocus];
    });
    return image;
}

NSImage *voice_play_image() {
    static NSImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSRect rect = NSMakeRect(0, 0, image_VoicePlay().size.width + 3, image_VoicePlay().size.height);
        image = [[NSImage alloc] initWithSize:rect.size];
        [image lockFocus];
        
        [image_VoicePlay() drawInRect:NSMakeRect(3, 0, image_VoicePlay().size.width, image_VoicePlay().size.height) fromRect:NSZeroRect operation:NSCompositeHighlight fraction:1];
        
        [image unlockFocus];
    });
    return image;
}

NSImage *attach_downloaded_background() {
    static NSImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSRect rect = NSMakeRect(0, 0, 40, 40);
        image = [[NSImage alloc] initWithSize:rect.size];
        [image lockFocus];
        [BLUE_COLOR set];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path appendBezierPathWithRoundedRect:NSMakeRect(0, 0, rect.size.width, rect.size.height) xRadius:rect.size.width/2 yRadius:rect.size.height/2];
        [path fill];
        
        [image_DocumentThumbIcon() drawInRect:NSMakeRect(roundf((40 - image_DocumentThumbIcon().size.width)/2), roundf((40 - image_DocumentThumbIcon().size.height)/2), image_DocumentThumbIcon().size.width, image_DocumentThumbIcon().size.height) fromRect:NSZeroRect operation:NSCompositeHighlight fraction:1];
        [image unlockFocus];
    });
    return image;
}

NSImage *white_background_color() {
    static NSImage *image;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        image = [[NSImage alloc] initWithSize:NSMakeSize(100, 100)];
        [image lockFocus];
        NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(0, 0, 100, 100) xRadius:3 yRadius:3];
        [[NSColor whiteColor] set];
        [path fill];
        [image unlockFocus];
        
        image = [[RHResizableImage alloc] initWithImage:image capInsets:RHEdgeInsetsMake(5, 5, 5, 5)];
        
    });
    return image;
}


NSImage *video_play_image() {
    static NSImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSRect rect = NSMakeRect(0, 0, 40, 40);
        image = [[NSImage alloc] initWithSize:rect.size];
        [image lockFocus];
        [NSColorFromRGBWithAlpha(0x000000, 0.5) set];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path appendBezierPathWithRoundedRect:NSMakeRect(0, 0, rect.size.width, rect.size.height) xRadius:rect.size.width/2 yRadius:rect.size.height/2];
        [path fill];
        
        [image_PlayIconWhite() drawInRect:NSMakeRect(roundf((40 - image_PlayIconWhite().size.width)/2) + 2, roundf((40 - image_PlayIconWhite().size.height)/2) , image_PlayIconWhite().size.width, image_PlayIconWhite().size.height) fromRect:NSZeroRect operation:NSCompositeHighlight fraction:1];
        [image unlockFocus];
    });
    return image;//image_VideoPlay();
}

+ (NSImage *)roundedImage:(NSImage *)oldImage size:(NSSize)size {
    
    if(!oldImage || oldImage.size.width == 0 || oldImage.size.height == 0)
        return oldImage;
    
    CALayer *layer = [CALayer layer];
    NSImage *image = nil;
    @autoreleasepool {
        CGFloat displayScale = scaleFactor();
        
        size.width *= displayScale;
        size.height *= displayScale;
        
        CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)[oldImage TIFFRepresentation], NULL);
        
        if(source != NULL) {
            CGImageRef maskRef =  CGImageSourceCreateImageAtIndex(source, 0, NULL);
            CFRelease(source);
            
            [layer setContents:(__bridge id)(maskRef)];
            [layer setFrame:NSMakeRect(0, 0, size.width, size.height)];
            [layer setBounds:NSMakeRect(0, 0, size.width, size.height)];
            [layer setMasksToBounds:YES];
            [layer setCornerRadius:size.width / 2];
            
            CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, [[NSColorSpace genericRGBColorSpace] CGColorSpace], kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst);
            [layer renderInContext:context];
            
            CGImageRef cgImage = CGBitmapContextCreateImage(context);
            CGContextRelease(context);
            
            image = [[NSImage alloc] initWithCGImage:cgImage size:NSMakeSize(size.width * 0.5, size.height * 0.5)];
            CGImageRelease(cgImage);
            CGImageRelease(maskRef);
        }
    }
    
    return image;
}




+ (NSImage *) roundedImageNew:(NSImage *)oldImage size:(NSSize)size {
    
    if(oldImage.size.width > 0 && oldImage.size.height > 0) {
        NSImage *result = [[NSImage alloc] initWithSize:size];
        [result lockFocus];
        
        NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(0, 0, size.width, size.height)
                                                             xRadius:size.width / 2
                                                             yRadius:size.height / 2];
        [path addClip];
        
        [oldImage drawInRect:NSMakeRect(0, 0, size.width, size.height)
                    fromRect:NSZeroRect
                   operation:NSCompositeSourceOver
                    fraction:1.0];
        
        [result unlockFocus];
        return result;
    }
    
    return oldImage;
   
}

static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight)
{
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0)
    {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth (rect) / ovalWidth;
    fh = CGRectGetHeight (rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}




@end
