//
//  FLPathFinding.m
//  Flatland
//
//  Created by vmware on 11/25/13.
//  Copyright (c) 2013 ITBA. All rights reserved.
//

#import "FLPathFinding.h"

@implementation FLPathFindingNode

+(id) nodeWithPosition:(CGPoint)position {
    return [[[self alloc] initWithPosition:position] autorelease];
}

-(id) initWithPosition:(CGPoint)position {
    _position = position;
    _edges = [[NSMutableArray array] retain];
    
    return self;
}

-(void) addNeighbour:(FLPathFindingNode *)neighbour withCost: (float) cost {
    if (neighbour)
        [_edges addObject:[FLPathFindingEdge edgeWithTarget:neighbour andCost:cost]];
}

-(void) reset {
    _visited = NO;
    _parent = nil;
    _accumCost = INFINITY;
}

-(void) setVisited {
    _visited = YES;
}

-(void)dealloc {
    self.parent = nil;
    [_edges release];
    _edges = nil;
    [super dealloc];
}

@end

@implementation FLPathFindingEdge

+(id) edgeWithTarget:(FLPathFindingNode *)target andCost:(float)cost {
    return [[[self alloc] initWithTarget: target andCost: cost] autorelease];
}

-(id) initWithTarget: (FLPathFindingNode*) target andCost: (float) cost {
    _cost = cost;
    _target = [target retain];
    return self;
}

-(void)dealloc {
    [_target release];
    _target = nil;
    [super dealloc];
}

@end

@interface FLPath()

@property (nonatomic, strong) NSMutableArray* nodes;
@property (nonatomic, strong) NSEnumerator* enumer;
@property (nonatomic, strong) FLTiledMap* map;
@property (nonatomic, strong) FLPathFindingNode* savedNode;

@end

@implementation FLPath

+(id) pathWithDestination:(FLPathFindingNode *)destNode andMap:(FLTiledMap *)map {
    return [[[self alloc] initWithDestination: destNode andMap: map] autorelease];
}

-(id) initWithDestination:(FLPathFindingNode *)destNode andMap: (FLTiledMap*) map {
    FLPathFindingNode* current = destNode;
    self.nodes = [NSMutableArray array];
    while (current) {
        [_nodes addObject: current];
        current = current.parent;
    }
    self.enumer = [_nodes reverseObjectEnumerator];
    self.map = map;
    self.savedNode = nil;
    return self;
}

-(CGPoint) next {
    FLPathFindingNode* nextNode;
    if ([self hasNext]) {
        nextNode = _savedNode;
        self.savedNode = nil;
        return [_map mapToWorldCoords:nextNode.position];
    } else {
        return CGPointZero;
    }
}

-(BOOL) hasNext {
    if (_savedNode) return YES;
    self.savedNode = [_enumer nextObject];
    return (_savedNode != nil);
}

-(void) dealloc {
    self.nodes = nil;
    self.enumer = nil;
    self.map = nil;
    self.savedNode = nil;
    [super dealloc];
}

@end

static FLPathFindingNode* getLowestNode(NSMutableOrderedSet* set) {
    FLPathFindingNode* lowest = nil;
    float lowestAccumCost = INFINITY;
    for (FLPathFindingNode* node in set) {
        if (!lowest || lowestAccumCost > node.accumCost) {
            lowest = node;
            lowestAccumCost = node.accumCost;
        }
    }
    return lowest;
}

@interface FLPathFinding()

@property (nonatomic, strong) FLTiledMap* map;
@property (nonatomic, assign) FLPathFindingNode** nodes;
@property (nonatomic, assign) int nodesSize;
@property (nonatomic, assign) CGSize dims;

@end

@implementation FLPathFinding

-(FLPathFindingNode*) getNode: (CGPoint) position  {
    if ([_map tileInBounds: position])
        return _nodes[(int)(position.x+position.y*_dims.width)];
    else
        return nil;
}

-(void) setNode: (FLPathFindingNode*) node at: (CGPoint) position {
    if ([_map tileInBounds: position])
        _nodes[(int)(position.x+position.y*_dims.width)] = [node retain];
}

-(void) reset {
    for (int i = 0; i < _nodesSize; i++) {
        if (_nodes[i])
            [_nodes[i] reset];
    }
}

-(float) tileDistanceFrom: (CGPoint) from To: (CGPoint) to {
    return hypotf(to.x-from.x, to.y-from.y);
}

-(FLPath*) pathFrom: (cpVect) origin To: (cpVect) destination {
    NSMutableOrderedSet* openSet = [NSMutableOrderedSet orderedSet];
    FLPathFindingNode* originNode = [self getNode: [_map worldToMapCoords:origin]];
    FLPathFindingNode* destNode = [self getNode: [_map worldToMapCoords:destination]];
    
    if (!originNode || !destNode) return nil; //No path

    [self reset];
    
    originNode.accumCost = [self tileDistanceFrom:originNode.position To:destNode.position];
    [openSet addObject: originNode];
    
    while ([openSet count] > 0) {
        FLPathFindingNode* lowest = getLowestNode(openSet);
        
        [lowest setVisited];
        [openSet removeObject:lowest];
                
        if (lowest == destNode) break;
        
        for (FLPathFindingEdge*edge in lowest.edges) {
            FLPathFindingNode* neighbour = edge.target;
            if (!neighbour.visited) {
                float cost = edge.cost;
                float newAccumCost = cost+lowest.accumCost+[self tileDistanceFrom:neighbour.position To:destNode.position];
                
                if (![openSet containsObject:neighbour]) {
                    [neighbour setParent: lowest];
                    [neighbour setAccumCost: newAccumCost];
                    [openSet addObject:neighbour];
                } else if (newAccumCost < neighbour.accumCost) {
                    [neighbour setParent: lowest];
                    [neighbour setAccumCost: newAccumCost];
                }
            }
        }
    }
    
    if (destNode.parent)
        return [[FLPath alloc] initWithDestination: destNode andMap:_map];
    else
        return nil; // Path not found.
    
    
}

+(id) pathFindingWithMap:(FLTiledMap *)map {
    return [[[self alloc] initWithMap: map] autorelease];
}

-(id) initWithMap:(FLTiledMap *)map {
    int x, y;
    self.nodesSize = map.mapSize.height*map.mapSize.width;
    self.nodes = malloc(sizeof(FLPathFindingNode*)*_nodesSize);
    self.map = map;
    self.dims = map.mapSize;
    
    // Create nodes
    for (y = 0; y < _dims.height; y++) {
        for (x = 0; x < _dims.width; x++) {
            if ([_map tileBlocked:ccp(x,y)]) {
                [self setNode:nil at:ccp(x,y)];
            } else {
                [self setNode:[FLPathFindingNode nodeWithPosition:ccp(x,y)] at:ccp(x,y)];
            }
        }
    }

    // Establish node connections
    for (y = 0; y < _dims.height; y++) {
        for (x = 0; x < _dims.width; x++) {
            FLPathFindingNode* node = [self getNode:ccp(x,y)];
            if (node) {
                // Orthogonally adjacent nodes
                [node addNeighbour:[self getNode:ccp(x-1,y)] withCost:1.0f];
                [node addNeighbour:[self getNode:ccp(x,y-1)] withCost:1.0f];
                [node addNeighbour:[self getNode:ccp(x+1,y)] withCost:1.0f];
                [node addNeighbour:[self getNode:ccp(x,y+1)] withCost:1.0f];
                
                // Diagonally adjacent nodes
                if ([self getNode:ccp(x-1,y)] && [self getNode:ccp(x,y-1)])
                    [node addNeighbour:[self getNode:ccp(x-1,y-1)] withCost:M_SQRT2];
                
                if ([self getNode:ccp(x-1,y)] && [self getNode:ccp(x,y+1)])
                    [node addNeighbour:[self getNode:ccp(x-1,y+1)] withCost:M_SQRT2];
                
                if ([self getNode:ccp(x+1,y)] && [self getNode:ccp(x,y+1)])
                    [node addNeighbour:[self getNode:ccp(x+1,y+1)] withCost:M_SQRT2];
                
                if ([self getNode:ccp(x+1,y)] && [self getNode:ccp(x,y-1)])
                    [node addNeighbour:[self getNode:ccp(x+1,y-1)] withCost:M_SQRT2];
            }
        }
    }
    return self;
}

-(void) dealloc {
    for (int i = 0; i < _nodesSize; i++) {
        if (_nodes[i])
            [_nodes[i] release];
    }
    free(_nodes);
    self.map = nil;
    NSLog(@"pathfinding released");
    [super dealloc];
}

@end
