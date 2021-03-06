//
//  CTGIFImageView.h
//  SampleMap
//
//  Created by MaYing on 13-5-3.
//
//

#import <UIKit/UIKit.h>

@interface CTGIFImageFrame : NSObject

@property (nonatomic) double duration;
@property (nonatomic, retain) UIImage* image;
@end
@interface CTGIFImageView : UIImageView
{
    NSInteger _currentImageIndex;
}
@property (nonatomic, retain) NSArray* imageFrameArray;
@property (nonatomic, retain) NSTimer* timer;

-(id)initWithFrame:(CGRect) frame andGifFileName:(NSString*) gifFileName;
-(id)initWithGifFileName:(NSString*) gifFileName;

-(void)clear;//必须在内存释放前调用，否则无法释放

@end