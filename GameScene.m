//
//  GameScene.m
//  FinalProject
//
//  Created by Lauren on 6/12/16.
//  Copyright (c) 2016 Lauren. All rights reserved.
//

#import "GameScene.h"

@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    
    SKNode *background = [self childNodeWithName:@"background"];
    SKPhysicsBody *borderBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:background.frame];
    self.physicsBody = borderBody;
    self.physicsBody.friction = 1.0f;
    
    NSMutableArray<SKTexture *> *textures = [NSMutableArray new];

    for(int i = 1; i <= 6; i++){
        [textures addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"seal_%02d",i]]];
    }
    self.walkAnimation = [SKAction repeatActionForever:[SKAction animateWithTextures:textures timePerFrame:0.1]];
    
    for(int i = 1; i <= 5; i++){
        [textures addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"diving_%02d",i]]];
        [textures addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"seal_01"]]];

    }
    self.jumpAnimation = [SKAction animateWithTextures:textures timePerFrame:0.1];
    
    SKNode *character = [self childNodeWithName:@"Character"];
    SKNode *camera = [self childNodeWithName:@"MainCamera"];
    
    id horizConstraint = [SKConstraint distance:[SKRange rangeWithUpperLimit:100] toNode:character];
    id vertConstraint = [SKConstraint distance:[SKRange rangeWithUpperLimit:50] toNode:character];
    
    id leftConstraint = [SKConstraint positionX:[SKRange rangeWithLowerLimit:camera.position.x]];
    id bottomConstraint = [SKConstraint positionY:[SKRange rangeWithLowerLimit:camera.position.y]];
    id rightConstraint = [SKConstraint positionX:[SKRange rangeWithUpperLimit:(background.frame.size.width - camera.position.x)]];
    id topConstraint = [SKConstraint positionX:[SKRange rangeWithUpperLimit:(background.frame.size.width - camera.position.y)]];
    
    [camera setConstraints:@[horizConstraint, vertConstraint, leftConstraint, bottomConstraint, rightConstraint, topConstraint]];
    
    /* Setup your scene here */
    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    
    myLabel.text = @"Welcome to the land of seals!";
    myLabel.fontSize = 45;
    myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                   CGRectGetMidY(self.frame));
    
    [self addChild:myLabel];
    [myLabel runAction:[SKAction fadeAlphaTo:0.0 duration:5.0]];
}

int leftTouches;
int rightTouches;
const int kMoveSpeed = 200;

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    [super touchesBegan:touches withEvent: event];
    
    static const NSTimeInterval kHugeTime = 9999.0;
    SKNode *character = [self childNodeWithName:@"Character"];
    
    
    
    for (UITouch *touch in touches) {
        if ([touch locationInNode:character.parent].x < character.position.x){
            leftTouches++;
        }
        else{
            rightTouches++;
        }
    }
    
    if ((leftTouches == 1) && (rightTouches == 0)){
        //move left
        character.xScale = -1.0*ABS(character.xScale);
        //SKAction *shuffleNoise = [SKAction playSoundFileNamed:@"shuffle" waitForCompletion:YES];
        //SKAction *repeatNoise = [SKAction repeatActionForever:shuffleNoise];
        SKAction *leftMove = [SKAction moveBy:CGVectorMake(-1.0*kMoveSpeed*kHugeTime,0) duration:kHugeTime];
       // SKAction *leftGroup = [SKAction group:@[repeatNoise, leftMove]];
        
        [character runAction:leftMove withKey:@"MoveAction"];
        [character runAction:self.walkAnimation withKey:@"MoveAnimation"];
    }
    else if ((leftTouches == 0) && (rightTouches == 1)){
        //move right
        character.xScale = 1.0*ABS(character.xScale);
         SKAction *rightMove = [SKAction moveBy:CGVectorMake(1.0*kMoveSpeed*kHugeTime,0) duration:kHugeTime];
        [character runAction:rightMove withKey:@"MoveAction"];
        [character runAction:self.walkAnimation withKey:@"MoveAnimation"];
    }
    else if ((leftTouches + rightTouches) > 1){
        //jump
        SKAction *jumpMove = [SKAction applyImpulse:CGVectorMake(0,1000) duration:0.3];
        [character runAction:jumpMove withKey:@"JumpAction"];
        [character runAction:self.jumpAnimation withKey:@"JumpAnimation"];
    }
}


-(void) reduceTouches:(NSSet *)touches withEvent:(UIEvent *)event{
    SKNode *character = [self childNodeWithName:@"Character"];
    
    for (UITouch *touch in touches){
        if ([touch locationInNode:character.parent].x < character.position.x){
            leftTouches--;
        }
        else{
            rightTouches--;
        }
    }
    while((leftTouches < 0) || (rightTouches < 0)){
        if (leftTouches < 0){
            rightTouches += leftTouches;
            leftTouches = 0;
        }
        if (rightTouches < 0){
            leftTouches += rightTouches;
            rightTouches = 0;
        }
    }
    
    if((leftTouches + rightTouches) <= 0){
        [character removeActionForKey:@"MoveAction"];
        [character removeActionForKey:@"MoveAnimation"];
    }
}


-(void)touchesEnded:(NSSet *) touches withEvent:(UIEvent *) event{
    [super touchesEnded: touches withEvent:event];
    [self reduceTouches:touches withEvent:event];
}

-(void)touchesCancelled:(NSSet<UITouch *> *) touches withEvent:(UIEvent *)event{
    [super touchesCancelled: touches withEvent:event];
    [self reduceTouches:touches withEvent:event];
}

//-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */



@end
