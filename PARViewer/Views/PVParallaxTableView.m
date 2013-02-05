//  MDCParallaxView.m
//
//  Copyright (c) 2012 modocache
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//


#import "PVParallaxTableView.h"

@interface PVParallaxTableView () <UITableViewDelegate>
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIScrollView *backgroundScrollView;
@property (nonatomic, strong) UITableView *foregroundTableView;
@end


@implementation PVParallaxTableView


#pragma mark - Object Lifecycle

- (id)initWithBackgroundView:(UIView *)backgroundView
         foregroundTableView:(UITableView *)foregroundTableView
                windowHeight:(CGFloat)windowHeight{
    self = [super init];
    if (self) {
        
        _windowHeight = windowHeight;
//        _imageHeight  = 300.0;
        
        _backgroundView = backgroundView;
        _imageHeight = _backgroundView.frame.size.height;
        
        _backgroundScrollView = [UIScrollView new];
        _backgroundScrollView.backgroundColor = [UIColor clearColor];
        _backgroundScrollView.showsHorizontalScrollIndicator = NO;
        _backgroundScrollView.showsVerticalScrollIndicator = NO;
        [_backgroundScrollView addSubview:_backgroundView];
        [self addSubview:_backgroundScrollView];
        
        _foregroundTableView = foregroundTableView;
        [self addSubview:_foregroundTableView];
        
        [self updateBounds];

    }
    return self;
}

- (void)layoutImage {
    CGFloat imageWidth   = _backgroundScrollView.frame.size.width;
    CGFloat imageYOffset = floorf((_windowHeight  - _imageHeight) / 2.0);
    
    CGFloat imageXOffset = 0.0;
    
    _backgroundView.frame = CGRectMake(imageXOffset, imageYOffset, imageWidth, _imageHeight);    
    _backgroundScrollView.contentSize = CGSizeMake(imageWidth, self.bounds.size.height);
    _backgroundScrollView.contentOffset = CGPointMake(0.0, 0.0);
}

- (void)updateBounds{
    CGRect bounds = self.bounds;
    
    _backgroundScrollView.frame = CGRectMake(0.0, 0.0, bounds.size.width, bounds.size.height);
    _foregroundTableView.backgroundView = nil;
    _foregroundTableView.frame = bounds;
    
    [self layoutImage];
    [self updateContentOffset];
}

#pragma mark - NSObject Overrides

- (void)setLocalDelegate:(id <UITableViewDelegate>)delegate
{
    if (delegate == self)
        return;
    
    self.trueDelegate = delegate;
    [_foregroundTableView setDelegate:self];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([super respondsToSelector:aSelector])
        return YES;
    
    return [_trueDelegate respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    return _trueDelegate;
}

#pragma mark - UIView Overrides

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self updateBounds];    
}

- (void)setAutoresizingMask:(UIViewAutoresizing)autoresizingMask {
    [super setAutoresizingMask:autoresizingMask];
    self.backgroundView.autoresizingMask = autoresizingMask;
    self.backgroundScrollView.autoresizingMask = autoresizingMask;
    self.foregroundTableView.autoresizingMask = autoresizingMask;
}

#pragma mark - UIScrollViewDelegate Protocol Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateContentOffset];
    if ([self.trueDelegate respondsToSelector:_cmd]) {
        [self.trueDelegate scrollViewDidScroll:scrollView];
    }
}

#pragma mark - Public Interface

- (UIScrollView *)scrollView {
    return self.foregroundTableView;
}

- (void)setBackgroundHeight:(CGFloat)backgroundHeight {
    [self updateBounds];
}


#pragma mark - Internal Methods

- (void)updateContentOffset {
    CGFloat yOffset   = _foregroundTableView.contentOffset.y;
    CGFloat threshold = _imageHeight - _windowHeight;
    
    if (yOffset > -threshold && yOffset < 0) {
        _backgroundScrollView.contentOffset = CGPointMake(0.0, floorf(yOffset / 2.0));
    } else if (yOffset < 0) {
        _backgroundScrollView.contentOffset = CGPointMake(0.0, yOffset + floorf(threshold / 2.0));
    } else {
        _backgroundScrollView.contentOffset = CGPointMake(0.0, yOffset);
    }
}

- (void)setTableHeaderView:(UIView*)view{
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.foregroundTableView.frame.size.width, _windowHeight + view.frame.size.height)];
    [tableHeaderView setBackgroundColor:[UIColor clearColor]];
    [view setFrame:CGRectMake(0.0, _windowHeight, view.frame.size.width, view.frame.size.height)];
    [tableHeaderView addSubview:view];

    self.foregroundTableView.tableHeaderView = tableHeaderView;
}

@end
