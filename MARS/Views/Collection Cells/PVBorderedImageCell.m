//
//  PVRecentAugmentedView.m
//  MARS
//
//  Copyright 2013 PAR Works, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "PVBorderedImageCell.h"
#import "PVImageCacheManager.h"
#import "PVTrendingSitesController.h"
#import "NSContainers+NullHandlers.h"

@implementation PVBorderedImageCell

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];

	if (self) {
		[self setBackgroundColor:[UIColor clearColor]];

		self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height)];
		_imageView.contentMode = UIViewContentModeScaleAspectFill;
		_imageView.clipsToBounds = YES;
		[_imageView.layer setBorderColor:[UIColor colorWithRed:197.0 / 255.0 green:197.0 / 255.0 blue:197.0 / 255.0 alpha:1.0].CGColor];
		[_imageView.layer setBorderWidth:1.0];
		[self addSubview:_imageView];
	}
	return self;
}

- (void)setHighlighted:(BOOL)highlighted
{
    if (highlighted) {
        CAShapeLayer * l = [CAShapeLayer layer];
        [l setBackgroundColor: [[UIColor colorWithWhite:0 alpha:0.4] CGColor]];
        [l setName: @"highlight"];
        [l setFrame: self.bounds];
        [self.layer addSublayer: l];
    } else {

        CALayer * l = nil;
        for (l in [self.layer sublayers])
            if ([[l name] isEqualToString: @"highlight"])
                break;
        [l removeFromSuperlayer];
    }
}

- (void)setUrl:(NSURL *)url
{
	// stop listening for image availability
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    _url = url;

    UIImage * img = [[PVImageCacheManager shared] imageForURL: url];
	if (!img) {
		img = [UIImage imageNamed:@"missing_image_78x78.png"];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageReady:) name:NOTIF_IMAGE_READY object: url];
	}
	[_imageView setImage:img];
}

- (void)imageReady:(NSNotification *)notif
{
	UIImage * img = [[PVImageCacheManager shared] imageForURL: _url];
	[_imageView setImage:img];
}

- (void)prepareForReuse
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [super prepareForReuse];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end