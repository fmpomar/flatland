//
//  FLPathFinding.h
//  Flatland
//
//  Created by vmware on 11/25/13.
//  Copyright (c) 2013 ITBA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLTiledMap.h"

@interface FLPathFindingNode : NSObject
-(id) initWithPosition: (CGPoint) position;
-(void) addNeighbour:(FLPathFindingNode *)neighbour withCost: (float) cost;
-(NSMutableArray*) getEdges;
-(float) getAccumCost;
-(void) setAccumCost: (float) cost;
-(CGPoint) getPosition;
-(void) setParent: (FLPathFindingNode*) parent;
-(FLPathFindingNode*) getParent;
-(void) reset;
-(BOOL) isVisited;
-(void) setVisited;
@end

@interface FLPathFindingEdge : NSObject


-(id) initWithTarget: (FLPathFindingNode*) target andCost: (float) cost;
-(float) getCost;
-(FLPathFindingNode*) getTarget;

@end

@interface FLPath : NSObject
-(id) initWithDestination: (FLPathFindingNode*) destNode;
-(CGPoint) next;
@end

@interface FLPathFinding : NSObject
-(id) initWithMap: (FLTiledMap*) map;

@end
