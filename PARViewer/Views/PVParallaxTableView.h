//
//  PVParallaxTableView.h
//  PARViewer
//
//  Created by Grayson Sharpe on 2/2/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//


@protocol PVParallaxTableViewDelegate;

@interface PVParallaxTableView : UIView

@property (nonatomic, weak) id<PVParallaxTableViewDelegate> delegate;
/// The scrollView used to display the parallax effect.
@property (nonatomic, readonly) UIScrollView *scrollView;
///// The delegate of scrollView. You must use this property when setting the scrollView delegate--attempting to set the scrollView delegate directly using `scrollView.delegate` will cause the parallax effect to stop updating.
@property (nonatomic, weak) id<UITableViewDelegate> trueDelegate;
/// The height of the background view when at rest.
@property (nonatomic, assign) CGFloat windowHeight;
@property (nonatomic, assign) CGFloat imageHeight;
@property (nonatomic, assign) BOOL isExpanded;
@property (nonatomic, assign) BOOL headerExpansionEnabled;

/// *Designated initializer.* Creates a MDCParallaxView with the given views.
/// @param backgroundView The view to be displayed in the background. This view scrolls slower than the foreground, creating the illusion that it is "further away".
/// @param foregroundTableView The view to be displayed in the foreground. This view scrolls normally, and should be the one users primarily interact with.
/// @return An initialized view object or nil if the object couldn't be created.

- (id)initWithBackgroundView:(UIView *)backgroundView
         foregroundTableView:(UITableView *)foregroundTableView
                windowHeight:(CGFloat)windowHeight;
- (void)setTableHeaderView:(UIView*)view headerExpansionEnabled:(BOOL)enabled;
- (void)updateContentOffset;
- (void)setLocalDelegate:(id <UITableViewDelegate>)delegate;
- (void)windowButtonPressed;

@end

@protocol PVParallaxTableViewDelegate <NSObject>

@optional
- (void)windowButtonPressed:(BOOL)isExpanded;
@end
