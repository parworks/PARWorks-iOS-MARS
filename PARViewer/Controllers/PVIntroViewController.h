//
//  PVIntroViewController.h
//  PARViewer
//
//  Created by Demetri Miller on 2/15/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSTCollectionView.h"

@interface PVIntroViewController : UIViewController <PSUICollectionViewDataSource, PSUICollectionViewDelegate>

@property(nonatomic, weak) IBOutlet PSUICollectionView *collectionView;

@end
