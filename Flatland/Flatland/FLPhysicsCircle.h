//
//  FlPhysicsCircle.h
//  Flatland
//
//  Created by vmware on 11/25/13.
//  Copyright (c) 2013 ITBA. All rights reserved.
//

#import "FLPhysicsBody.h"

@interface FLPhysicsCircle : FLPhysicsBody
-(id) initWithSpace: (cpSpace*) space Position: (cpVect) position R: (float) radius M: (float) mass I: (float) momentOfInertia color: (ccColor4F) color andDrawDirection: (BOOL) drawDirection;
-(float) circleRadius;
@end
