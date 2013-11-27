//
//  HudLayer.m
//  Flatland
//
//  Created by vmware on 11/27/13.
//  Copyright (c) 2013 ITBA. All rights reserved.
//

#import "HudLayer.h"
#import "cocos2d.h"

@interface HudLayer()
@property (nonatomic,strong) CCLabelTTF* messageLabel;
@end

@implementation HudLayer

-(id)init {

    if( (self=[super init]) ) {
        CGSize winSize = [CCDirector sharedDirector].winSize;
        self.messageLabel = [CCLabelTTF labelWithString:@"GO" fontName:@"Arial" fontSize:72];
        _messageLabel.color = ccc3(0,96,0);
        _messageLabel.position = ccp(winSize.width/2,winSize.height/2);
        [_messageLabel runAction:[CCFadeOut actionWithDuration:1.0f]];
        [self addChild:_messageLabel];
    }

    return self;

}

-(void) displayMessage:(NSString *)message {
    [self displayMessage:message withColor:ccBLACK];
}

-(void) displayMessage: (NSString*) message withColor:(ccColor3B)color {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    id actionFadeIn = [CCFadeIn actionWithDuration:0.2];
    id actionFadeOut = [CCFadeOut actionWithDuration:0.8];
    _messageLabel.string = message;
    _messageLabel.color = color;
    _messageLabel.position = ccp(winSize.width/2,winSize.height/2);
    [_messageLabel runAction:[CCSequence actions: actionFadeIn, actionFadeOut, nil]];
}

@end
