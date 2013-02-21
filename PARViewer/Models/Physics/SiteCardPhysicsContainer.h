//
//  SignPhysicsContainer.h
//  ChipmunkTemplate
//
//  Created by Ben Gotow on 2/4/13.
//
//

#import <Foundation/Foundation.h>
#import "ObjectiveChipmunk.h"
#import "chipmunk.h"

@interface SiteCardPhysicsContainer : NSObject
{
    ChipmunkPivotJoint *_joint;
    
    ChipmunkBody * _cardBody;
    ChipmunkBody * _shingleBody;
    
    float _recentVelocity;
    float _recentY;
    float _recentRot;
}

@property (nonatomic, retain) ChipmunkSpace * space;

@property (nonatomic, assign) id rootNode;

- (void)setup;
- (void)step:(float)dt;

- (void)setCardX:(float)cardX;
- (void)resetSign;
- (CGPoint)signOffset;
- (float)signRotation;

@end
