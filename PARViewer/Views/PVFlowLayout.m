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
    NSLog(@"Hi %@ %f", self.collectionView, self.collectionView.frame.size.height);
}


- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    // what is this code for?
    // In our collection view, we can't control when cells get reused. They're reused as soon as they go offscreen.
    // This is bad, because the stupid shingles can swing outside the frames of the cells, and they'll still be onscreen
    // when the cell is recycled. To fix this, we extend the frame of the collection view past the edges of the screen,
    // but this breaks pagination (because it makes the page size like 450px...)
    
    // This method implements pagination based on a custom page width. It also allows you to swipe fast and fly through
    // more than one cell, which you also can't do with standard pagination.
    
    float pageWidth = ([self itemSize].width + [self minimumLineSpacing]);
    float leftInset = [[self collectionView] contentInset].left;
    float currentPageIndex = (-leftInset + [[self collectionView] contentOffset].x + pageWidth / 2) / pageWidth;

    // some math to figure out how much we should travel from our current page based on the swipe velocity
    currentPageIndex += sqrtf(fabs(velocity.x) / 2) * ((velocity.x > 0) ? 1 : -1);
    
    proposedContentOffset.x = -leftInset + roundf(currentPageIndex) * pageWidth;
    return proposedContentOffset;
}
@end
