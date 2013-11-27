//
//  FLPhysicsBody.m
//  Flatland
//
//  Created by vmware on 11/25/13.
//  Copyright (c) 2013 ITBA. All rights reserved.
//

#import "FLPhysicsBody.h"

/*
typedef int (*cpCollisionBeginFunc)(cpArbiter *arb, struct cpSpace *space, void *data)
typedef int (*cpCollisionPreSolveFunc)(cpArbiter *arb, cpSpace *space, void *data)
typedef void (*cpCollisionPostSolveFunc)(cpArbiter *arb, cpSpace *space, void *data)
typedef void (*cpCollisionSeparateFunc)(cpArbiter *arb, cpSpace *space, void *data)
*/

//typedef void (*cpBodyShapeIteratorFunc)(cpBody *body, cpShape *shape, void *data)
static void removeBodyShape(cpBody* body, cpShape* shape, void* data) {
    cpSpaceRemoveShape(cpBodyGetSpace(body), shape);
    cpShapeDestroy(shape);
}

//typedef void (*cpPostStepFunc)(cpSpace *space, void *obj, void *data)
static void deferredRemoveBody(cpSpace* space, void* obj, void* data) {
    cpBody* body = (cpBody*) obj;
    cpBodyEachShape(body, removeBodyShape, nil);
    cpSpaceRemoveBody(space, body);
    cpBodyDestroy(body);
}

static int defaultBodyCollisionBeginFunc(cpArbiter* arb, cpSpace* space, void* data) {
    cpBody* bodyA;
    cpBody* bodyB;
    FLPhysicsBody* flBodyA;
    FLPhysicsBody* flBodyB;
    cpArbiterGetBodies(arb, &bodyA, &bodyB);
    flBodyA = (FLPhysicsBody*) cpBodyGetUserData(bodyA);
    flBodyB = (FLPhysicsBody*) cpBodyGetUserData(bodyB);
    if (flBodyA && flBodyB) {
        [flBodyA collisionBegin:flBodyB];
        [flBodyB collisionBegin:flBodyA];
    }
    return true;
}

static void defaultBodyCollisionSeparateFunc(cpArbiter* arb, cpSpace* space, void* data) {
    cpBody* bodyA;
    cpBody* bodyB;
    FLPhysicsBody* flBodyA;
    FLPhysicsBody* flBodyB;
    cpArbiterGetBodies(arb, &bodyA, &bodyB);
    flBodyA = (FLPhysicsBody*) cpBodyGetUserData(bodyA);
    flBodyB = (FLPhysicsBody*) cpBodyGetUserData(bodyB);
    if (flBodyA && flBodyB) {
        [flBodyA collisionSeparate:flBodyB];
        [flBodyB collisionSeparate:flBodyA];
    }
}

@implementation FLPhysicsBody

+(void) setupSpaceForCollisions:(cpSpace *)space {
    cpSpaceSetDefaultCollisionHandler(space, defaultBodyCollisionBeginFunc, nil, nil, defaultBodyCollisionSeparateFunc, nil);
}


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
    cpBodySetUserData(_body, self);
	cpSpaceAddBody(_space, _body);
    return self;
}

-(void) dealloc {
    if (_body) {
        cpBodySetUserData(_body, nil);
        cpSpaceAddPostStepCallback(_space, deferredRemoveBody, _body, nil);
        _body = nil;
    }
    [super dealloc];
}


-(void) applyImpulse: (cpVect) impulse at: (cpVect) offset {
    cpBodyApplyImpulse(_body, impulse, offset);
}

-(void) applyForce:(cpVect)force at:(cpVect)offset {
    cpBodyApplyForce(_body, force, offset);
}

-(cpVect) resultant {
    return cpBodyGetForce(_body);
}

-(cpVect) rotationVector {
    return cpBodyGetRot(_body);
}

-(void) resetForces {
    cpBodyApplyForce(_body, cpvneg(cpBodyGetForce(_body)), CGPointZero);
}

-(void)forceTowards:(CGPoint)position {
    CGPoint diff = ccpSub(position, self.position);
    
    [self resetForces];
    [self applyForce:cpv(diff.x*5, diff.y*5) at:CGPointZero];
    
    self.rotation = atan2f(diff.x, -diff.y) - M_PI_2;
}

-(void) collisionBegin:(FLPhysicsBody *)otherBody {
    // Do nothing.
}

-(void) collisionSeparate:(FLPhysicsBody *)otherBody {
    // Do nothing.
}

@end
