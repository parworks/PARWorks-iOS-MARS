//
//  ActionLayer.m
//  CatNap
//
//  Created by Demetri Miller on 1/13/13.
//
//

#import "ActionLayer.h"

@implementation ActionLayer

+ (id)scene
{
    CCScene *scene = [CCScene node];
    ActionLayer *layer = [ActionLayer node];
    [scene addChild:layer];
    return scene;
}


#pragma mark - Lifecycle/Setup
- (id)init
{
    self = [super init];
    if (self) {
        [self createSpace];
        [self createGround];
        [self setupMultiGrab];
        [self scheduleUpdate];
        
        // Add a few shapes to get started
        cpFloat mass = 1.0;
        cpFloat width = 40.0;
        cpFloat height = 40.0;
        ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:mass andMoment:cpMomentForBox(mass, width, height)];
        body.pos = cpv(100, 160);
        [_space add:body];
        
        ChipmunkShape *shape = [[ChipmunkPolyShape alloc] initBoxWithBody:body width:width height:height];
        shape.friction = 0.7;
        shape.elasticity = 0.5;
        [_space add:shape];
        
        mass = 5.0;
        width = 180.0;
        height = 80.0;
        body = [[ChipmunkBody alloc] initWithMass:mass andMoment:cpMomentForBox(mass, width, height)];
        body.pos = cpv(220, 160);
        [_space add:body];
        
        shape = [[ChipmunkPolyShape alloc] initBoxWithBody:body width:width height:height];
        shape.friction = 0.7;
        shape.elasticity = 0.5;
        [_space add:shape];
    }
    return self;
}

- (void)update:(ccTime)dt
{
    [_space step:dt];
}

- (void)createSpace
{
    _space = [[ChipmunkSpace alloc] init];
    [_space setGravity:ccp(0, -750)];
    
    CGSize size = [CCDirector sharedDirector].winSize;
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    [_space addBounds:rect thickness:5 elasticity:1 friction:1 layers:CP_ALL_LAYERS group:CP_NO_GROUP collisionType:nil];

    _debugNode = [CCPhysicsDebugNode debugNodeForChipmunkSpace:_space];
    [self addChild:_debugNode];
}

- (void)createGround
{
    CGSize winSize = [CCDirector sharedDirector].winSize;
    ChipmunkBody *body = [[ChipmunkBody alloc] initStaticBody];
    ChipmunkShape *shape = [ChipmunkSegmentShape segmentWithBody:body from:ccp(0,0) to:ccp(winSize.width,0) radius:10.0];
    shape.elasticity = 0.5f;
    shape.friction = 1.0;
    [_space add:shape];
}

- (void)setupMultiGrab
{
    self.touchEnabled = YES;
    _multiGrab = [[ChipmunkMultiGrab alloc] initForSpace:_space withSmoothing:cpfpow(0.8, 60.0) withGrabForce:20000];
    
    // How close a touch has to be to an object to grab it. (should be about the size of the user's finger on the screen)
    _multiGrab.grabRadius = 20.0;
    
    // Torque to apply to grabs to slow down spinning.
    _multiGrab.grabRotaryFriction = 1e2;
    
    // Enable push mode. When an object isn't grabbed, it inserts a circle that tracks the touch instead.
    // This allows you to push things around.
    _multiGrab.pushMode = TRUE;
    
    // The friction on the push shape.
    _multiGrab.pushFriction = 0.7f;
    
    // The mass of the finger body. Should be about the same as the objects you intend to push, maybe a little less.
    _multiGrab.pushMass = 1.0;
}


#pragma mark - User Interaction
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
{
	for(UITouch *touch in touches) [_multiGrab beginLocation:[self convertTouchToNodeSpace:touch]];
    /*
    CGPoint p = [self convertTouchToNodeSpace:[touches anyObject]];
    ChipmunkGrab *grab = [_multiGrab beginLocation:[self convertTouchToNodeSpace:[touches anyObject]]];

    if (grab.grabbedShape) {
    }
     */
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
{
	for(UITouch *touch in touches) [_multiGrab updateLocation:[self convertTouchToNodeSpace:touch]];
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
{
	for(UITouch *touch in touches) [_multiGrab endLocation:[self convertTouchToNodeSpace:touch]];
}


@end
