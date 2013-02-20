//
//  SignPhysicsContainer.m
//  ChipmunkTemplate
//
//  Created by Ben Gotow on 2/4/13.
//
//

#import "SiteCardPhysicsContainer.h"

#define SHINGLE_STOP_THRESHOLD 45

@implementation SiteCardPhysicsContainer


- (void)setup
{
    [self createSpace];
    
    // Add a few shapes to get started
    cpFloat mass = 100.0;
    cpFloat width = 140.0;
    cpFloat height = 40.0;
    _cardBody = [[ChipmunkBody alloc] initWithMass:mass andMoment:INFINITY];
    _cardBody.pos = cpv(200, 200);
    [_space add: _cardBody];
    
    ChipmunkShape *shape1 = [[ChipmunkPolyShape alloc] initBoxWithBody:_cardBody width:width height:10];
    shape1.friction = 1.0;
    shape1.elasticity = 0.0;
    [_space add:shape1];
    
    [_space add:[ChipmunkGrooveJoint grooveJointWithBodyA:_space.staticBody bodyB:_cardBody groove_a:cpv(20, 200) groove_b:cpv(10000, 200) anchr2:cpvzero]];
    
    _shingleBody = [[ChipmunkBody alloc] initWithMass:300 andMoment:cpMomentForBox(mass, width, height)];
    [self resetSign];
    [_space add:_shingleBody];
    
    ChipmunkShape *shape2 = [[ChipmunkPolyShape alloc] initBoxWithBody:_shingleBody width:width height:height];
    shape2.friction = 1;
    shape2.elasticity = 0.5;
    [_space add:shape2];
    
//    [_space add:[ChipmunkDampedSpring dampedSpringWithBodyA:_cardBody bodyB: _shingleBody anchr1:cpv(-width/2, -height/3)  anchr2:cpvzero restLength:50.0 stiffness:stiff damping:damp]];
//    [_space add:[ChipmunkDampedSpring dampedSpringWithBodyA:_cardBody bodyB: _shingleBody anchr1:cpv(width/2, -height/3) anchr2:cpvzero restLength:50.0 stiffness:stiff damping:damp]];
    [_space add:[[ChipmunkSlideJoint alloc] initWithBodyA:_cardBody bodyB:_shingleBody anchr1:cpv(-width/3.4, -height/3) anchr2:cpv(-width/3, height/3) min:0 max:60]];
    [_space add:[[ChipmunkSlideJoint alloc] initWithBodyA:_cardBody bodyB:_shingleBody anchr1:cpv(width/3.4, -height/3) anchr2:cpv(width/3, height/3) min:0 max:60]];
}

- (void)step:(float)dt
{
    [_space step: dt];
}

- (void)createSpace
{
    _space = [[ChipmunkSpace alloc] init];
    [_space setGravity: CGPointMake(0, -750)];
    [_space setIdleSpeedThreshold: 0.2];
    [_space setSleepTimeThreshold: 0.2];
    [_space setDamping: 0.08]; // velocity *= damping = new velocity
    CGRect rect = CGRectMake(0, 0, 100000, 100000);
    [_space addBounds:rect thickness:5 elasticity:1 friction:1 layers:CP_ALL_LAYERS group:CP_NO_GROUP collisionType:nil];
}

- (void)setCardX:(float)cardX
{
    _cardBody.vel = CGPointMake(0, 0);

    cpVect pos = _cardBody.pos;
    pos.x = 200 + cardX;
    if (fabs(pos.x - _cardBody.pos.x) > 0.01) {
        _recentVelocity = SHINGLE_STOP_THRESHOLD * 15;
        _cardBody.pos = pos;
    }
}

- (void)resetSign
{
    _shingleBody.pos = cpv(_cardBody.pos.x, 113);
    _shingleBody.vel = cpv(0,0);
    _recentY = 113;
    _recentRot = 0;
}

- (CGPoint)signOffset
{
    cpVect reference = _cardBody.pos;
    
    float shingleVelocity = (powf(_shingleBody.vel.x,2) + powf(_shingleBody.vel.y, 2));
    float shingleDistFromRest = fabs(_shingleBody.pos.x - _cardBody.pos.x);

    BOOL shouldStopShingle = ((_recentVelocity < SHINGLE_STOP_THRESHOLD) && (shingleDistFromRest < 1));
    _recentVelocity = _recentVelocity * 0.9 + shingleVelocity * 0.1;

    if (shouldStopShingle) {
        _shingleBody.vel = cpv(0,0);
        _shingleBody.angVel = 0;
        _shingleBody.pos = cpv(_cardBody.pos.x, _shingleBody.pos.y);
        NSLog(@"Froze shingle");
    }
    
    _recentY = _recentY * 0.8 + _shingleBody.pos.y * 0.2;
    return CGPointMake(_shingleBody.pos.x - reference.x, _recentY - reference.y);

}

- (float)signRotation
{
    _recentRot = _recentRot * 0.8 + _shingleBody.angle * 0.2;
    return _recentRot;
}

@end
