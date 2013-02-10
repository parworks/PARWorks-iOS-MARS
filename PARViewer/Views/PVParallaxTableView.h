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
@property (nonatomic, readonly) UIScrollView *scrollView;
@property (nonatomic, weak) id<UITableViewDelegate> trueDelegate;
@property (nonatomic, assign) CGFloat windowHeight;
@property (nonatomic, assign) CGFloat imageHeight;
@property (nonatomic, assign) BOOL isExpanded;
@property (nonatomic, assign) BOOL headerExpansionEnabled;

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
