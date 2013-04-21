//
//  PVParallaxTableView.h
//  PARViewer
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
