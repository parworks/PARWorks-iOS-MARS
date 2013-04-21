//
//  PVParallaxTableView.m
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
        
        _backgroundView = backgroundView;
        _imageHeight = _backgroundView.frame.size.height;
        
        _backgroundScrollView = [UIScrollView new];
        _backgroundScrollView.backgroundColor = [UIColor clearColor];
        _backgroundScrollView.showsHorizontalScrollIndicator = NO;
        _backgroundScrollView.showsVerticalScrollIndicator = NO;
        _backgroundScrollView.userInteractionEnabled = YES;
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

- (void)windowButtonPressed{
    NSLog(@"windowButtonPressed");
    if(_isExpanded){
        [UIView transitionWithView:self duration:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _backgroundView.frame = CGRectMake(0.0, 0.0, 320.0, _windowHeight);
        } completion:^(BOOL finished){
            [self layoutImage];
            [self bringSubviewToFront:_foregroundTableView];
            _isExpanded = NO;
        }];
    }
    else{
        _backgroundView.frame = CGRectMake(0.0, 0.0, 320.0, _windowHeight);
        [self bringSubviewToFront:_backgroundScrollView];
        [UIView transitionWithView:self duration:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _backgroundView.frame = CGRectMake(_backgroundView.frame.origin.x, 0.0, self.bounds.size.width, self.bounds.size.height);
        } completion:^(BOOL finished){
            _isExpanded = YES;
        }];
    }
    [_delegate windowButtonPressed:_isExpanded];
}

#pragma mark - Delegate forwarding

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

- (void)setTableHeaderView:(UIView*)view headerExpansionEnabled:(BOOL)enabled{
    self.headerExpansionEnabled = enabled;
    
    UIControl *tableHeaderView = [[UIControl alloc] initWithFrame:CGRectMake(0.0, 0.0, self.foregroundTableView.frame.size.width, _windowHeight + view.frame.size.height)];
    [tableHeaderView setBackgroundColor:[UIColor clearColor]];    
    
    UIButton *windowButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, tableHeaderView.frame.size.width, _windowHeight)];
    [windowButton addTarget:self action:@selector(windowButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [windowButton setBackgroundColor:[UIColor clearColor]];
    [windowButton setEnabled:_headerExpansionEnabled];

    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0.0, _windowHeight, tableHeaderView.frame.size.width, 1.0)];
    windowButton.layer.masksToBounds = NO;
    [windowButton.layer setShadowRadius: 3];
    [windowButton.layer setShadowOffset: CGSizeMake(0, -1)];
    [windowButton.layer setShadowOpacity: 0.5];
    windowButton.layer.shadowPath = shadowPath.CGPath;
    
    [tableHeaderView addSubview:windowButton];
    
    [view setFrame:CGRectMake(0.0, windowButton.frame.origin.y + windowButton.frame.size.height, view.frame.size.width, view.frame.size.height)];
    [tableHeaderView addSubview:view];
    
    self.foregroundTableView.tableHeaderView = tableHeaderView;   
}

@end
