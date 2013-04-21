//
//  ActionLayer.h
//  CatNap
//
//  Created by Demetri Miller on 1/13/13.
//
//
#import "cocos2d.h"
#import "ObjectiveChipmunk.h"
#import "chipmunk.h"

@interface ActionLayer : CCLayer
{
    ChipmunkSpace *_space;
    CCPhysicsDebugNode *_debugNode;
    ChipmunkMultiGrab *_multiGrab;
}
+ (id)scene;

@end
