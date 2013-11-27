//
//  FLTiledMap.m
//  Flatland
//
//  Created by vmware on 11/25/13.
//  Copyright (c) 2013 ITBA. All rights reserved.
//

#import "FLTiledMap.h"

@interface FLTiledMap()

@property (nonatomic, assign) cpSpace* space;
@property (nonatomic, strong) CCTMXLayer* metaLayer;
@property (nonatomic, strong) NSMutableArray* spawnPoints;

@end

@implementation FLTiledMap

+(id) tiledMapWithTMXFile:(NSString *)tmxFile andSpace:(cpSpace*)space {
    return [[self alloc] initWithTMXFile:tmxFile andSpace:space];
}

-(id) initWithTMXFile:(NSString *)tmxFile andSpace:(cpSpace*)space {
    self = [super initWithTMXFile:tmxFile];
    self.space = space;
    self.metaLayer = [self layerNamed:@"Meta"];
    _metaLayer.visible = NO;
    [self initWalls];
    return self;
}


-(CGPoint) playerSpawnPoint {
    CCTMXObjectGroup *objectGroup = [self objectGroupNamed:@"Objects"];
    NSAssert(objectGroup != nil, @"tile map has no objects object layer");
    NSDictionary *spawnPoint = [objectGroup objectNamed:@"SpawnPoint"];
    
    
    return ccp([spawnPoint[@"x"] integerValue],[spawnPoint[@"y"] integerValue]);
}

-(BOOL) hasSpawnPoints {
    return (_spawnPoints && [_spawnPoints count] > 0);
}

-(CGPoint) randomSpawnPoint {
    CGPoint point = ccp(0,0);
    if ([self hasSpawnPoints])
        [_spawnPoints[arc4random()%[_spawnPoints count]] getValue: &point];
    return [self mapToWorldCoords:point];
}

-(Boolean) tileInBounds: (CGPoint) tileCoord {
    return (tileCoord.x >= 0 && tileCoord.y >= 0 && tileCoord.x < self.mapSize.width && tileCoord.y < self.mapSize.height);
}

-(Boolean) tileBlocked: (CGPoint)tileCoord {
    if (![self tileInBounds:tileCoord])
        return true;
    int tileGid = [_metaLayer tileGIDAt: tileCoord];
    if (tileGid) {
        NSDictionary *properties = [self propertiesForGID:tileGid];
        if (properties) {
            NSString *collision = properties[@"Collidable"];
            return (collision && [collision isEqualToString:@"True"]);
        }
    }
    return false;
}

-(Boolean) pointBlocked: (cpVect) worldCoords {
    return [self tileBlocked:[self worldToMapCoords:worldCoords]];
}

-(CGPoint) worldToMapCoords:(cpVect)worldCoords {
    return ccp((int)(worldCoords.x/self.tileSize.width),
               (int)(self.mapSize.height - (worldCoords.y/self.tileSize.height)));
}

-(cpVect) mapToWorldCoords:(CGPoint)mapCoords {
    return cpv(mapCoords.x*self.tileSize.width+self.tileSize.width/2.0f,
               (self.tileSize.height*(self.mapSize.height-1))-mapCoords.y*self.tileSize.height+self.tileSize.height/2.0f);
}

-(void) createWallAtTile: (CGPoint) tileCoord {
    if ([self tileBlocked:tileCoord]) {
        cpShape * wallShape;
        cpVect verts[] = {
            cpv(-self.tileSize.width/2.0f,-self.tileSize.height/2.0f),
            cpv(-self.tileSize.width/2.0f, self.tileSize.height/2.0f),
            cpv( self.tileSize.width/2.0f, self.tileSize.height/2.0f),
            cpv( self.tileSize.width/2.0f,-self.tileSize.height/2.0f),
        };
        cpVect offset = [self mapToWorldCoords: tileCoord];
        wallShape = cpPolyShapeNew(_space->staticBody, 4, verts, offset);
        cpShapeSetElasticity(wallShape, 1.0f);
        cpShapeSetFriction(wallShape, 1.0f);
        cpSpaceAddStaticShape(_space, wallShape);
    }
}

-(void) gatherSpawnPoint: (CGPoint) tileCoord {
    if (![self tileInBounds:tileCoord]) return;
    int tileGid = [_metaLayer tileGIDAt: tileCoord];
    if (tileGid) {
        NSDictionary *properties = [self propertiesForGID:tileGid];
        if (properties) {
            NSString *spawnPoint = properties[@"SpawnPoint"];
            if (spawnPoint && [spawnPoint isEqualToString:@"True"]) {
                [_spawnPoints addObject:[NSValue valueWithBytes:&tileCoord objCType:@encode(CGPoint)]];
            }
        }
    }
}

-(void) initWalls {
    int x,y;
    CGSize mapSize = [self mapSize];
    CGSize pixelMapSize = [self mapSize];
    pixelMapSize.width *= self.tileSize.width;
    pixelMapSize.height *= self.tileSize.height;
    cpShape* mapBorder;
    
    self.spawnPoints = [NSMutableArray array];
    
    for (x=0; x<mapSize.width; x++)
        for (y=0; y<mapSize.height; y++) {
            [self createWallAtTile:ccp(x,y)];
            [self gatherSpawnPoint:ccp(x,y)];
        }
    
    mapBorder = cpSegmentShapeNew( _space->staticBody, cpv(0,0), cpv(pixelMapSize.width,0), 0.0f);
	cpShapeSetElasticity(mapBorder, 1.0f);
    cpShapeSetFriction(mapBorder, 1.0f);
    cpSpaceAddStaticShape(_space, mapBorder);
    
	// top
	mapBorder = cpSegmentShapeNew( _space->staticBody, cpv(0,pixelMapSize.height), cpv(pixelMapSize.width,pixelMapSize.height), 0.0f);
    cpShapeSetElasticity(mapBorder, 1.0f);
    cpShapeSetFriction(mapBorder, 1.0f);
    cpSpaceAddStaticShape(_space, mapBorder);
    
	// left
	mapBorder = cpSegmentShapeNew( _space->staticBody, cpv(0,0), cpv(0,pixelMapSize.height), 0.0f);
	cpShapeSetElasticity(mapBorder, 1.0f);
    cpShapeSetFriction(mapBorder, 1.0f);
    cpSpaceAddStaticShape(_space, mapBorder);
    
	// right
	mapBorder = cpSegmentShapeNew( _space->staticBody, cpv(pixelMapSize.width,0), cpv(pixelMapSize.width,pixelMapSize.height), 0.0f);
	cpShapeSetElasticity(mapBorder, 1.0f);
    cpShapeSetFriction(mapBorder, 1.0f);
    cpSpaceAddStaticShape(_space, mapBorder);
    
}

-(void)dealloc {
    self.metaLayer = nil;
    self.spawnPoints = nil;
    [super dealloc];
}

@end
