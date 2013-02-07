//
//  PVRecentAugmentedView.m
//  PARViewer
//
//  Created by Ben Gotow on 1/31/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
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

@end