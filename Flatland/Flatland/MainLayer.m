#import "MainLayer.h"
#import "AppDelegate.h"
#import "SimpleAudioEngine.h"
#import "CCPhysicsSprite.h"

#import "FLTiledMap.h"

@implementation HudLayer
{
    CCLabelTTF *_label;
}

- (id)init
{
    self = [super init];
    if (self) {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        _label = [CCLabelTTF labelWithString:@"0" fontName:@"Verdana-Bold" fontSize:18.0];
        _label.color = ccc3(0,0,0);
        int margin = 10;
        _label.position = ccp(winSize.width - (_label.contentSize.width/2) - margin, _label.contentSize.height/2 + margin);
        [self addChild:_label];
    }
    return self;
}

-(void)numCollectedChanged:(int)numCollected
{
    _label.string = [NSString stringWithFormat:@"%d",numCollected];
}
@end

@interface MainLayer()

@property (strong) FLTiledMap *tileMap;
@property (strong) CCPhysicsSprite *player;
@property (strong) CCTMXLayer *meta;
@property (strong) HudLayer *hud;
@property (assign) int numCollected;

@end

@implementation MainLayer

// Helper class method that creates a Scene with the MainLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
	// 'layer' is an autorelease object.
	MainLayer *layer = [MainLayer node];
    
	// add layer as a child to scene
	[scene addChild: layer];
    
    HudLayer *hud = [HudLayer node];
    [scene addChild:hud];
    layer.hud = hud;
    
	// return the scene
	return scene;
}

-(void) initPhysics {
    _space = cpSpaceNew();
    cpSpaceSetDamping(_space, 0.05f);
	[self addChild:[CCPhysicsDebugNode debugNodeForCPSpace:_space] z:100];
}

-(void) setupRandomObstacles {
    
}

-(void) setupPlayerAtPosition:(CGPoint)position
{
	// physics body
	/*int num = 4;
	cpVect verts[] = {
		cpv(-24,-54),
		cpv(-24, 54),
		cpv( 24, 54),
		cpv( 24,-54),
	};*/
	
    cpBody* body = cpBodyNew(1.0f, INFINITY);
	cpBodySetPos( body, position );
	cpSpaceAddBody(_space, body);
	
	/*cpShape* shape = cpPolyShapeNew(body, num, verts, CGPointZero);
	cpShapeSetElasticity( shape, 0.5f );
	cpShapeSetFriction( shape, 0.5f );
	cpSpaceAddShape(_space, shape);*/
    
    cpShape* shape = cpCircleShapeNew(body, 16.0f, CGPointZero);
    cpShapeSetElasticity( shape, 0.5f );
	cpShapeSetFriction( shape, 0.5f );
    cpSpaceAddShape(_space, shape);
	
    CCPhysicsSprite* sprite = [CCPhysicsSprite spriteWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"Player.png"]];

	[sprite setCPBody:body];
	[sprite setPosition: position];
    
    _player = sprite;
    [self addChild:_player];
    [self setViewPointCenter:_player.position];
    
    
}

-(id) init
{
    
	if( (self=[super init]) ) {
        
        // At top of init for MainLayer
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"pickup.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"hit.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"move.caf"];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"TileMap.caf"];
        
        
        
        self.touchEnabled = YES;
        [self initPhysics];
        
        self.tileMap = [FLTiledMap tiledMapWithTMXFile:@"2d.tmx" andSpace: _space];
        
        [self addChild:_tileMap z:-1];
        [self setupPlayerAtPosition:[_tileMap playerSpawnPoint]];
        
        [self scheduleUpdate];
    }
    return self;
}

- (void)setViewPointCenter:(CGPoint) position {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    int x = MAX(position.x, winSize.width/2);
    int y = MAX(position.y, winSize.height/2);
    x = MIN(x, (_tileMap.mapSize.width * _tileMap.tileSize.width) - winSize.width / 2);
    y = MIN(y, (_tileMap.mapSize.height * _tileMap.tileSize.height) - winSize.height/2);
    CGPoint actualPosition = ccp(x, y);
    
    CGPoint centerOfView = ccp(winSize.width/2, winSize.height/2);
    CGPoint viewPoint = ccpSub(centerOfView, actualPosition);
     
    self.position = viewPoint;
}

#pragma mark - handle touches
-(void)registerWithTouchDispatcher
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self
                                                              priority:0
                                                       swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [touch locationInView:touch.view];
    touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
    touchLocation = [self convertToNodeSpace:touchLocation];
    
    CGPoint playerPos = _player.position;
    CGPoint diff = ccpSub(touchLocation, playerPos);
    cpBodyApplyForce([_player CPBody], cpvneg(cpBodyGetForce([_player CPBody])), cpv(0.0f, 0.0f));
    cpBodyApplyForce([_player CPBody], cpv(diff.x*5,diff.y*5), cpv(16.0f, 0.0f));
    cpBodySetAngle([_player CPBody], atan2f(diff.x, -diff.y) - M_PI_2);
	return YES;
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    [self ccTouchBegan:touch withEvent:event];
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{

    cpBodyApplyForce([_player CPBody], cpvneg(cpBodyGetForce([_player CPBody])), cpv(0.0f, 0.0f));

    /*
    if ( abs(diff.x) > abs(diff.y) ) {
        if (diff.x > 0) {
            playerPos.x += _tileMap.tileSize.width;
        } else {
            playerPos.x -= _tileMap.tileSize.width;
        }
    } else {
        if (diff.y > 0) {
            playerPos.y += _tileMap.tileSize.height;
        } else {
            playerPos.y -= _tileMap.tileSize.height;
        }
    }
    
    CCLOG(@"playerPos %@",CGPointCreateDictionaryRepresentation(playerPos));
    
    // safety check on the bounds of the map
    if (playerPos.x <= (_tileMap.mapSize.width * _tileMap.tileSize.width) &&
        playerPos.y <= (_tileMap.mapSize.height * _tileMap.tileSize.height) &&
        playerPos.y >= 0 &&
        playerPos.x >= 0 )
    {
        [self setPlayerPosition:playerPos];
    }
    */

}

- (CGPoint)tileCoordForPosition:(CGPoint)position {
    int x = position.x / _tileMap.tileSize.width;
    int y = ((_tileMap.mapSize.height * _tileMap.tileSize.height) - position.y) / _tileMap.tileSize.height;
    return ccp(x, y);
}

-(void) update:(ccTime) delta
{
	// Should use a fixed size step based on the animation interval.
	int steps = 2;
	CGFloat dt = [[CCDirector sharedDirector] animationInterval]/(CGFloat)steps;
	
	for(int i=0; i<steps; i++){
		cpSpaceStep(_space, dt);
	}
    [self setViewPointCenter:_player.position];
}


@end