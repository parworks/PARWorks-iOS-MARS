//
//  PVImageTransferAnimationView.m
//  GPUImage
//
//  Created by Ben Gotow on 2/3/13.
//  Copyright (c) 2013 Brad Larson. All rights reserved.
//

#import "PVImageTransferAnimationView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ASIHTTPRequest.h"
#import "UIImageView+AnimationAdditions.h"
#import "CATextLayer+Loading.h"
#import "PARWorks.h"
#import "EPUtil.h"
#import "AdOverlayView.h"

#define WIDTH 20
#define HEIGHT 20


@implementation PVImageTransferAnimationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _shrinkingMask = [[CALayer alloc] init];
        _shrinking = [[UIImageView alloc] init];
        _scanline = [[UIImageView alloc] initWithImageSeries:@"scanline_%d.png"];
        _scanline.alpha = 0.0;
        
        [_shrinkingMask setOpaque: YES];
        [_shrinkingMask setBackgroundColor: [[UIColor redColor] CGColor]];
        [_shrinking.layer setMask: _shrinkingMask];
        [_shrinkingMask setFrame: self.bounds];
        [_shrinking setFrame: self.bounds];
        [self addSubview: _shrinking];
        [self addSubview: _scanline];

        // We use a text layer so we can get awesome implicit animations...
        _loadingLayer.foregroundColor = [UIColor whiteColor].CGColor;
        _loadingLayer = [CATextLayer layer];
        _loadingLayer.opacity = 0.0;
        _loadingLayer.string = @"Augmenting";
        _loadingLayer.fontSize = 16.0;
        _loadingLayer.rasterizationScale = [UIScreen mainScreen].scale;
        _loadingLayer.contentsScale = [UIScreen mainScreen].scale;
        _loadingLayer.needsDisplayOnBoundsChange = NO;
        [self.layer addSublayer:_loadingLayer];
    }
    return self;
}

- (void)startWithImage:(UIImage*)image andFinalView:(UIView *)finalView andHUDView:(UIView *)hudView
{
    _image = image;
    _finalView = finalView;
    _hudView = hudView;
    
    [self runOutAnimation];
    [self performSelectorOnMainThread:@selector(sliceImageAndCreateLayers:) withObject: image waitUntilDone:NO];

}

- (void)finalViewReady
{
    _finalViewReady = YES;
    
    if (!_outAnimationRunning) {
        _loadingLayer.opacity = 0;
        [self translateLayersInWithCompletionBlock:^{
            [UIView animateWithDuration:0.5 animations:^{
                [_finalView setAlpha: 1];
                _hudView.alpha = 1.0;
                [_hudView.superview bringSubviewToFront: _hudView];
            }];
        }];
    }
}

- (BOOL)isRunning
{
    return _outAnimationRunning;
}

// Internal Methods

- (void)runOutAnimation
{
    _outAnimationRunning = YES;
    
    [CATransaction begin];
    [CATransaction setDisableActions: YES];
    [_shrinking setImage: _image];
    [_shrinkingMask setFrame: self.bounds];
    [_shrinking setFrame: self.bounds];
    [_hudView setAlpha: 0];
    [_finalView setAlpha: 0];
    [_scanline setAlpha: 0];
    [_loadingLayer setOpacity: 0];
    [_scanline setAnimationRepeatCount: 1000];
    _scanline.frame = CGRectMake(0, -_scanline.frame.size.height, _scanline.frame.size.width, _scanline.frame.size.height);
    [CATransaction commit];
    
    CALayer *firstLayer = [_layers objectAtIndex:0];
    
    // Step 1: "Charge" the scanline by making it alpha = 1
    [UIView transitionWithView:_scanline duration:0.3 options: UIViewAnimationOptionCurveEaseOut animations:^{
        _scanline.frame = CGRectMake(0, CGRectGetMinY(firstLayer.frame)-_scanline.frame.size.height/2, _scanline.frame.size.width, _scanline.frame.size.height);
        [_scanline setAlpha: 1];

    // Step 2: Translate the tiny cubes offscreen
    } completion: ^(BOOL finished) {
        [self translateLayersOutWithCompletionBlock:^{
            _outAnimationRunning = NO;
            if (_finalViewReady) {
                [self finalViewReady];
            } else {
                _loadingLayer.frame = CGRectMake(self.frame.size.width/2 - 40, self.frame.size.height/2, self.frame.size.width/2, _loadingLayer.fontSize+4);
                [_loadingLayer startLoadingAnimation];
            }
        }];
    }];
}

- (void)sliceImageAndCreateLayers:(UIImage *)image
{
    [_layers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [_layers removeAllObjects];
    
    if (!_layers)
        _layers = [NSMutableArray array];
    
    int xSteps = image.size.width / WIDTH;
    int ySteps = image.size.height / HEIGHT;
    int count = xSteps * ySteps;
    
    // Step 1, create the layers
    for (int i = 0; i < count; i++) {
        CALayer *layer = [CALayer layer];
        [_layers addObject:layer];
        [self.layer insertSublayer:layer below:_shrinking.layer];
    }
    
    // Step 2: Render the layer contents one by one
    [EPUtil smallImagesWithWidth:WIDTH height:HEIGHT fromImage:_image withImageReadyCallback: ^(int i, UIImage* img) {
        [(CALayer*)[_layers objectAtIndex: i] performSelectorOnMainThread:@selector(setContents:) withObject:(id)[img CGImage] waitUntilDone:NO];
    }];
    
    // Step 3: Lay out the layers in a grid
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    for (int i = 0; i < count; i++) {
        int y = floor(i / xSteps);
        int x = i % xSteps;
        
        float xOrigin = x * WIDTH;
        float yOrigin = y * HEIGHT;
        
        CALayer *l = [_layers objectAtIndex: i];
        l.frame = CGRectMake(xOrigin, yOrigin, WIDTH, HEIGHT);
    }
    [CATransaction commit];
}

#pragma mark - Layout


- (void)translateLayersOutWithCompletionBlock:(void (^)(void))completionBlock
{
    [self translateLayersWithStartDelay:0.2 rowDelay: 0.15 withCompletionBlock: completionBlock];
}

- (void)translateLayersInWithCompletionBlock:(void (^)(void))completionBlock
{
    [self translateLayersWithStartDelay:0 rowDelay: 0.04 withCompletionBlock: completionBlock];
}

- (void)translateLayersWithStartDelay:(float)delay rowDelay:(float)rowDelay withCompletionBlock: (void (^)(void))completionBlock
{
    srand(time(0));
    CGSize size = CGSizeMake(WIDTH, HEIGHT);
    int rows = _image.size.height/size.height;
    int cols = _image.size.width/size.width;
    
    [_scanline startAnimating];
    
    CALayer *lastLayer = [_layers objectAtIndex:rows*(cols-1)];
    [UIView animateWithDuration:(rowDelay * rows)+delay animations:^{
        _scanline.frame = CGRectMake(0, CGRectGetMinY(lastLayer.frame)-_scanline.frame.size.height/2, _scanline.frame.size.width, _scanline.frame.size.height);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:rowDelay * 6 animations:^{
            _scanline.alpha = 0.0;
        } completion:^(BOOL finished) {
        }];
    }];
    [CATransaction begin];
    [CATransaction setAnimationDuration: ((rowDelay * rows) + delay) * 1.4];
    [_shrinkingMask setFrame: CGRectMake(0, self.bounds.size.height, self.bounds.size.width, 200)];
    [CATransaction commit];
    
    // Iterate over each row animating all the bits offscreen in the -Y direction.
    for (int i=0; i<rows; i++)
        [self performSelector:@selector(translateRowOffscreen:) withObject:[NSNumber numberWithInt: i] afterDelay:delay + rowDelay * i];
    
    NSTimeInterval totalRuntime = (rowDelay * (rows + 3)) + delay;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, totalRuntime * NSEC_PER_SEC), dispatch_get_current_queue(), completionBlock);
}

- (void)translateRowOffscreen:(NSNumber *)rowNumber
{
    int row = rowNumber.intValue;
    int cols = _image.size.width/WIDTH;
    
    CGFloat duration = ((rand()*0.1)/INT_MAX) + 0.6;
    
    static CAMediaTimingFunction *timing;
    timing = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [CATransaction begin];
    [CATransaction setAnimationDuration:duration];
    [CATransaction setAnimationTimingFunction:timing];
    
    for (int c = 0; c < cols; c ++) {
        CALayer *layer = [_layers objectAtIndex: (cols * row) + c];
        CGFloat yOffset = -(CGRectGetMinY(layer.frame) + 20 + (rand()%220));
        CGFloat xOffset = CGRectGetMidX(layer.frame);
        CGFloat randOffsetX = (rand()%40)-(20);
        xOffset+=randOffsetX;
        
        CATransform3D transform = CATransform3DIdentity;
        
        if (CATransform3DIsIdentity(layer.transform)) {
            transform = CATransform3DTranslate(transform, 0, yOffset, 0);
            transform = CATransform3DScale(transform, 0.5, 0.5, 1);
            CGFloat rotate = ((rand()*1.0)/INT_MAX) - 0.5;
            transform = CATransform3DRotate(transform, M_PI*rotate, 0, 0, 1);
        }
        
        layer.transform = transform;
    }
    
    
    [CATransaction commit];
}

@end
