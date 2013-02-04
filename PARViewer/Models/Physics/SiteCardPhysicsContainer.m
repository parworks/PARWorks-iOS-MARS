//
//  SignPhysicsContainer.m
//  ChipmunkTemplate
//
//  Created by Ben Gotow on 2/4/13.
//
//

#import "SiteCardPhysicsContainer.h"

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
    _shingleBody.pos = cpv(_cardBody.pos.x, 120);
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
    [_space setDamping: 0.08]; // velocity *= damping = new velocity
    CGRect rect = CGRectMake(0, 0, 100000, 100000);
    [_space addBounds:rect thickness:5 elasticity:1 friction:1 layers:CP_ALL_LAYERS group:CP_NO_GROUP collisionType:nil];
}

- (void)setCardX:(float)cardX
{
    cpVect pos = _cardBody.pos;
    pos.x = 200 + cardX;
    _cardBody.vel = CGPointMake(0, 0);
    _cardBody.pos = pos;
}

- (CGPoint)signOffset
{
    cpVect reference = _cardBody.pos;
    return CGPointMake(_shingleBody.pos.x - reference.x, _shingleBody.pos.y - reference.y);
}

- (float)signRotation
{
    return _shingleBody.angle;
}

@end
