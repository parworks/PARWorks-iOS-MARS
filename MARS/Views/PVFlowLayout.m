//
//  PVFlowLayout.m
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

#import "PVFlowLayout.h"

@implementation PVFlowLayout
- (void)awakeFromNib
{
    [super awakeFromNib];
//    NSLog(@"Hi %@ %f", self.collectionView, self.collectionView.frame.size.height);
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
