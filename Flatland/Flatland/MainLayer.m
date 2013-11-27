#import "MainLayer.h"
#import "AppDelegate.h"
#import "SimpleAudioEngine.h"
#import "CCPhysicsSprite.h"

#import "FLTiledMap.h"

#import "FLPhysicsCircle.h"

#import "FLEnemy.h"
#import "FLPlayer.h"

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
@property (strong) FLPlayer *player;
@property (strong) CCTMXLayer *meta;
@property (strong) HudLayer *hud;
@property (assign) int numCollected;
@property (strong) FLPathFinding* pathFinding;

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
	//[self addChild:[CCPhysicsDebugNode debugNodeForCPSpace:_space] z:100];
}

-(void) setupRandomObstacles {
    
}

-(FLPlayer*) getPlayer {
    return _player;
}

-(void) endGame {
    NSLog(@"Game actually ended.");
}

-(void) enemyExpired:(FLEnemy *)enemy {
    [self removeChild:enemy];
}

-(void) projectileExpired:(FLProjectile *)projectile {
    [self removeChild:projectile];
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
        [FLPhysicsBody setupSpaceForCollisions:_space];
        
        self.tileMap = [FLTiledMap tiledMapWithTMXFile:@"2d.tmx" andSpace: _space];
        
        [self addChild:_tileMap z:-1];
        self.player = [FLPlayer playerWithGame:self space:_space andPosition:[_tileMap playerSpawnPoint]];

        [self addChild:_player];
        
        self.pathFinding = [FLPathFinding pathFindingWithMap:_tileMap];
        
        [self addChild:[FLEnemy enemyWithGame:self pathFinding:_pathFinding space:_space andPosition:ccp(_player.position.x+32*10,_player.position.y)]];
        
        
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
    
    [_player forceTowards:touchLocation];
    [self addChild:[_player fireProjectile]];
    
	return YES;
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [touch locationInView:touch.view];
    touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
    touchLocation = [self convertToNodeSpace:touchLocation];
    
    [_player forceTowards:touchLocation];
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    [_player resetForces];

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