//
//  CTGIFImageView.m
//  TestGIF
//
//  Created by shichangone on 11-7-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CTGIFImageView.h"
#import <ImageIO/ImageIO.h>

@implementation CTGIFImageFrame
@synthesize image = _image;
@synthesize duration = _duration;

- (void)dealloc
{
    self.image = 0;
    [super dealloc];
}
@end


@interface CTGIFImageView ()

- (void)killTimer;

- (void)showNextImage;

@end

@implementation CTGIFImageView
@synthesize imageFrameArray = _imageFrameArray;
@synthesize timer = _timer;

-(id)initWithGifFileName:(NSString*) gifFileName
{
    if(self = [super init])
    {
        NSString* filePath = [[NSBundle mainBundle] pathForResource:gifFileName ofType:nil];
        NSData* imageData = [NSData dataWithContentsOfFile:filePath];
        [self setData:imageData];
    }
    return self;
}
-(id)initWithFrame:(CGRect) frame andGifFileName:(NSString*) gifFileName
{
    if(self = [super initWithFrame:frame])
    {
        NSString* filePath = [[NSBundle mainBundle] pathForResource:gifFileName ofType:nil];
        NSData* imageData = [NSData dataWithContentsOfFile:filePath];
        [self setData:imageData];

    }
    return self;
}
-(void)clear
{
    self.imageFrameArray = 0;
}
-(void)setImageFrameArray:(NSArray *)imageFrameArray
{
    if(_imageFrameArray != imageFrameArray)
    {
        [self killTimer];
        //
        
        if(_imageFrameArray)
        {
            [_imageFrameArray release];
            _imageFrameArray = 0;
        }
        if(imageFrameArray)
        {
            _imageFrameArray = [imageFrameArray retain];
        }
    }
    //
    if(_imageFrameArray)
    {
        if([_imageFrameArray count] > 1)
        {
            _currentImageIndex = -1;
            [self showNextImage];
        }
        else if([_imageFrameArray count] > 0)
        {
            CTGIFImageFrame* gifImage = [_imageFrameArray objectAtIndex:0];
            super.image = gifImage.image;
        }
        else
        {
            super.image = 0;
        }
    }
    
}
- (void)dealloc
{
    self.imageFrameArray = 0;
    [super dealloc];
}

- (void)killTimer
{
    if (_timer && _timer.isValid)
    {
        [_timer invalidate];
    }
    self.timer = nil;
}
- (void)setData:(NSData *)imageData
{
    [self killTimer];
    if(imageData)
    {
        CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)imageData, NULL);
        size_t count = CGImageSourceGetCount(source);
        NSMutableArray* tmpArray = [NSMutableArray array];
        
        for (size_t i = 0; i < count; i++)
        {
            CTGIFImageFrame* gifImage = [[[CTGIFImageFrame alloc] init] autorelease];
            CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
            gifImage.image = [UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
            NSDictionary* frameProperties = [(NSDictionary*)CGImageSourceCopyPropertiesAtIndex(source, i, NULL) autorelease];
            gifImage.duration = [[[frameProperties objectForKey:(NSString*)kCGImagePropertyGIFDictionary] objectForKey:(NSString*)kCGImagePropertyGIFDelayTime] doubleValue];
            gifImage.duration = MAX(gifImage.duration, 0.01);
            [tmpArray addObject:gifImage];
            CGImageRelease(image);
        }
        CFRelease(source);
        
        self.imageFrameArray = tmpArray;
    }
}

- (void)setImage:(UIImage *)image
{
    [super setImage:image];
    [self killTimer];
    self.imageFrameArray = nil;
}

- (void)showNextImage
{
    _currentImageIndex = (++_currentImageIndex) % _imageFrameArray.count;
    CTGIFImageFrame* gifImage = [_imageFrameArray objectAtIndex:_currentImageIndex];
    [super setImage:[gifImage image]];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:gifImage.duration target:self selector:@selector(showNextImage) userInfo:nil repeats:NO];
}

@end
