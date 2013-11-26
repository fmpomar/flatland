//
//  FLPhysicsBody.m
//  Flatland
//
//  Created by vmware on 11/25/13.
//  Copyright (c) 2013 ITBA. All rights reserved.
//

#import "FLPhysicsBody.h"

@implementation FLPhysicsBody

-(CGPoint) position {
    cpVect vpos = cpBodyGetPos(_body);
    return ccp(vpos.x, vpos.y);
}

-(void) setPosition:(CGPoint)position {
    cpBodySetPos(_body, cpv(position.x, position.y));
}

-(float) rotation {
    return cpBodyGetAngle(_body);
}

-(void) setRotation:(float)rotation {
    cpBodySetAngle(_body, rotation);
}



-(id) initWithSpace:(cpSpace *)space position:(CGPoint)position M:(float)mass I:(float)momentOfInertia {
    self = [super init];
    _space = space;
    _body = cpBodyNew(mass, momentOfInertia);
	cpBodySetPos(_body, position);
	cpSpaceAddBody(_space, _body);
    return self;
}

-(void) applyForce:(cpVect)force at:(cpVect)offset {
    cpBodyApplyForce(_body, force, offset);
}

-(cpVect) resultant {
    return cpBodyGetForce(_body);
}

-(void) resetForces {
    cpBodyApplyForce(_body, cpvneg(cpBodyGetForce(_body)), CGPointZero);
}



@end
