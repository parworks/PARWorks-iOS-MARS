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


static CGFloat const kMDCParallaxViewDefaultHeight = 150.0f;


@interface PVParallaxTableView () <UITableViewDelegate>
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIScrollView *backgroundScrollView;
@property (nonatomic, strong) UITableView *foregroundTableView;
- (void)updateBackgroundFrame;
- (void)updateForegroundFrame;
- (void)updateContentOffset;
@end


@implementation PVParallaxTableView


#pragma mark - Object Lifecycle

- (id)initWithBackgroundView:(UIView *)backgroundView
         foregroundTableView:(UITableView *)foregroundTableView {
    self = [super init];
    if (self) {
        _backgroundHeight = kMDCParallaxViewDefaultHeight;
        _backgroundView = backgroundView;
        
        _backgroundScrollView = [UIScrollView new];
        _backgroundScrollView.backgroundColor = [UIColor clearColor];
        _backgroundScrollView.showsHorizontalScrollIndicator = NO;
        _backgroundScrollView.showsVerticalScrollIndicator = NO;
        [_backgroundScrollView addSubview:_backgroundView];
        [self addSubview:_backgroundScrollView];
        
        _foregroundTableView = foregroundTableView;
        _foregroundTableView.delegate = self;
        [self addSubview:_foregroundTableView];
    }
    return self;
}


#pragma mark - NSObject Overrides

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if ([self.tableViewDelegate respondsToSelector:[anInvocation selector]]) {
        [anInvocation invokeWithTarget:self.tableViewDelegate];
    } else {
        [super forwardInvocation:anInvocation];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return ([super respondsToSelector:aSelector] ||
            [self.tableViewDelegate respondsToSelector:aSelector]);
}

- (void)setDelegate:(id <UITableViewDelegate>)delegate
{
    if (delegate == self)
        return;
    
    self.tableViewDelegate = delegate;
    [_foregroundTableView setDelegate:self];
}

//- (BOOL)respondsToSelector:(SEL)aSelector
//{
//    if ([super respondsToSelector:aSelector])
//        return YES;
//    
//    return [self.tableViewDelegate respondsToSelector:aSelector];
//}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    return self.tableViewDelegate;
}

#pragma mark - UIView Overrides

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self updateBackgroundFrame];
    [self updateForegroundFrame];
    [self updateContentOffset];
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
    if ([self.tableViewDelegate respondsToSelector:_cmd]) {
        [self.tableViewDelegate scrollViewDidScroll:scrollView];
    }
}

#pragma mark - Public Interface

- (UIScrollView *)scrollView {
    return self.foregroundTableView;
}

- (void)setBackgroundHeight:(CGFloat)backgroundHeight {
    _backgroundHeight = backgroundHeight;
    [self setTableHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, _foregroundTableView.frame.size.width, 0.0)]];    
    [self updateBackgroundFrame];
    [self updateForegroundFrame];
    [self updateContentOffset];
}


#pragma mark - Internal Methods

- (void)updateBackgroundFrame {
    self.backgroundScrollView.frame = CGRectMake(0.0f,
                                                 0.0f,
                                                 self.frame.size.width,
                                                 self.frame.size.height);
    self.backgroundScrollView.contentSize = CGSizeMake(self.frame.size.width,
                                                       self.frame.size.height);
    self.backgroundScrollView.contentOffset	= CGPointZero;

    self.backgroundView.frame =
        CGRectMake(0.0f,
                   floorf((self.backgroundHeight - self.backgroundView.frame.size.height)/2),
                   self.frame.size.width,
                   self.backgroundView.frame.size.height);
}

- (void)updateForegroundFrame {
    self.foregroundTableView.frame = self.bounds;
    self.foregroundTableView.contentSize =
        CGSizeMake(self.foregroundTableView.frame.size.width,
                   self.foregroundTableView.frame.size.height + self.backgroundHeight);
}

- (void)updateContentOffset {
    CGFloat offsetY   = self.foregroundTableView.contentOffset.y + self.backgroundHeight;
    CGFloat threshold = self.backgroundView.frame.size.height - self.backgroundHeight;

    if (offsetY > -threshold && offsetY < 0.0f) {
        self.backgroundScrollView.contentOffset = CGPointMake(0.0f, floorf(offsetY/2));
    } else if (offsetY < 0.0f) {
        self.backgroundScrollView.contentOffset = CGPointMake(0.0f, offsetY + floorf(threshold/2));
    } else {
        self.backgroundScrollView.contentOffset = CGPointMake(0.0f, offsetY);
    }
}

- (void)setTableHeaderView:(UIView*)view{
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.foregroundTableView.frame.size.width, self.backgroundHeight + view.frame.size.height)];
    [tableHeaderView setBackgroundColor:[UIColor clearColor]];
    [view setFrame:CGRectMake(0.0, self.backgroundHeight, view.frame.size.width, view.frame.size.height)];
    [tableHeaderView addSubview:view];

    self.foregroundTableView.tableHeaderView = tableHeaderView;
}

@end
