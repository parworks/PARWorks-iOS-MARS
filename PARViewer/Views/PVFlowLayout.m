//
//  PVFlowLayout.m
//  PARViewer
//
//  Created by Ben Gotow on 2/8/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVFlowLayout.h"

@implementation PVFlowLayout
- (void)awakeFromNib
{
    [super awakeFromNib];
    NSLog(@"Hi");
}


- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    if (fabs(velocity.x) < 0.2)
        velocity.x = 0;
    
    float pageWidth = ([self itemSize].width + [self minimumLineSpacing]);
    float endPageIndex = ([[self collectionView] contentOffset].x - pageWidth / 2) / pageWidth;
    proposedContentOffset.x = (roundf(endPageIndex) + ((velocity.x > 0) ? 1 : 0)) * pageWidth;
    return proposedContentOffset;
}
@end
