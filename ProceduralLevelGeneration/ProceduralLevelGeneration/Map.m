//
//  Map.m
//  ProceduralLevelGeneration
//
//  Created by Scott Gardner on 3/7/14.
//  Copyright (c) 2014 Kim Pedersen. All rights reserved.
//

#import "Map.h"
#import "MapTiles.h"
#import "MyScene.h"

@interface Map ()
@property (strong, nonatomic) MapTiles *tiles;
@property (strong, nonatomic) SKTextureAtlas *tileAtlas;
@property (assign, nonatomic) CGFloat tileSize;
@end

@implementation Map

+ (instancetype)mapWithGridSize:(CGSize)gridSize
{
    return [[self alloc] initWithGridSize:gridSize];
}

- (instancetype)initWithGridSize:(CGSize)gridSize
{
    if (self = [super init]) {
        _gridSize = gridSize;
        _spawnPoint = CGPointZero;
        _exitPoint = CGPointZero;
        _tileAtlas = [SKTextureAtlas atlasNamed:@"tiles"];
        NSArray *textureNames = [_tileAtlas textureNames];
        SKTexture *tileTexture = [_tileAtlas textureNamed:(NSString *)[textureNames firstObject]];
        _tileSize = tileTexture.size.width;
    }
    
    return self;
}

- (void)generate
{
    self.tiles = [[MapTiles alloc] initWithGridSize:self.gridSize];
    [self generateTileGrid];
    [self generateWalls];
    [self generateTiles];
    [self generateCollisionWalls];
}

- (void)generateTileGrid
{
    CGPoint startPoint = CGPointMake(self.gridSize.width / 2.0f, self.gridSize.height / 2.0f);
    [self.tiles setTileType:MapTileTypeFloor at:startPoint];
    NSUInteger currentFloorCount = 1;
    CGPoint currentPostion = startPoint;
    
    while (currentFloorCount < self.maxFloorCount) {
        NSInteger direction = [self randomNumberBetweenMin:1 andMax:4];
        CGPoint newPosition;
        
        switch (direction) {
            case 1: // Up
                newPosition = CGPointMake(currentPostion.x, currentPostion.y - 1);
                break;
                
            case 2: // Down
                newPosition = CGPointMake(currentPostion.x, currentPostion.y + 1);
                break;
                
            case 3: // Left
                newPosition = CGPointMake(currentPostion.x - 1, currentPostion.y);
                break;
                
            case 4: // Right
                newPosition = CGPointMake(currentPostion.x + 1, currentPostion.y    );
                break;
        }
        
        if ([self.tiles isValidTileCoordinateAt:newPosition] && ![self.tiles isEdgeTileAt:newPosition] && [self.tiles tileTypeAt:newPosition] == MapTileTypeNone) {
            currentPostion = newPosition;
            [self.tiles setTileType:MapTileTypeFloor at:currentPostion];
            currentFloorCount++;
        }
    }
    
    _exitPoint = [self convertMapCoordinateToWorldCoordinate:currentPostion];
    NSLog(@"%@", [self.tiles description]);
    _spawnPoint = [self convertMapCoordinateToWorldCoordinate:startPoint];
}

- (void)generateTiles
{
    for (NSInteger y = 0; y < self.tiles.gridSize.height; y++) {
        for (NSInteger x = 0; x < self.tiles.gridSize.width; x++) {
            CGPoint tileCoordinate = CGPointMake(x, y);
            MapTileType tileType = [self.tiles tileTypeAt:tileCoordinate];
            
            if (tileType != MapTileTypeNone) {
                SKTexture *tileTexture = [self.tileAtlas textureNamed:[NSString stringWithFormat:@"%i", tileType]];
                SKSpriteNode *tile = [SKSpriteNode spriteNodeWithTexture:tileTexture];
                tile.position = [self convertMapCoordinateToWorldCoordinate:CGPointMake(tileCoordinate.x, tileCoordinate.y)];
                [self addChild:tile];
            }
        }
    }
}

- (void)generateWalls
{
    for (NSInteger y = 0; y < self.tiles.gridSize.height; y++) {
        for (NSInteger x = 0; x < self.tiles.gridSize.width; x++) {
            CGPoint tileCoordinate = CGPointMake(x, y);
            
            if ([self.tiles tileTypeAt:tileCoordinate] == MapTileTypeFloor) {
                for (NSInteger neighborY = -1; neighborY < 2; neighborY++) {
                    for (NSInteger neighborX = -1; neighborX < 2; neighborX++) {
                        if (!(neighborX == 0 && neighborY == 0)) {
                            CGPoint coordinate = CGPointMake(x + neighborX, y + neighborY);
                            
                            if ([self.tiles tileTypeAt:coordinate] == MapTileTypeNone) {
                                [self.tiles setTileType:MapTileTypeWall at:coordinate];
                            }
                        }
                    }
                }
            }
        }
    }
}

- (void)addCollisionWallAtPosition:(CGPoint)position withSize:(CGSize)size
{
    SKNode *wall = [SKNode node];
    wall.position = CGPointMake(position.x + size.width * 0.5f - 0.5f * self.tileSize,
                                position.y - size.height * 0.5f + 0.5f * self.tileSize);
    SKPhysicsBody *physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:size];
    physicsBody.dynamic = NO;
    physicsBody.categoryBitMask = CollisionTypeWall;
    physicsBody.contactTestBitMask = 0;
    physicsBody.collisionBitMask = CollisionTypePlayer;
    wall.physicsBody = physicsBody;
    [self addChild:wall];
}

- (void)generateCollisionWalls
{
    for (NSInteger y = 0; y < self.gridSize.height; y++) {
        CGFloat startPointForWall = 0;
        CGFloat wallLength = 0;
        
        for (NSInteger x = 0; x < self.gridSize.width; x++) {
            CGPoint tileCoordinate = CGPointMake(x, y);
            
            if ([self.tiles tileTypeAt:tileCoordinate] == MapTileTypeWall) {
                if (startPointForWall == 0 && wallLength == 0) {
                    startPointForWall = x;
                }
                
                wallLength++;
            } else if (wallLength > 0) {
                CGPoint wallOrigin = CGPointMake(startPointForWall, y);
                CGSize wallSize = CGSizeMake(wallLength * self.tileSize, self.tileSize);
                [self addCollisionWallAtPosition:[self convertMapCoordinateToWorldCoordinate:wallOrigin] withSize:wallSize];
                startPointForWall = 0;
                wallLength = 0;
            }
        }
    }
}

- (NSInteger)randomNumberBetweenMin:(NSInteger)min andMax:(NSInteger)max
{
    return min + arc4random() % (max - min);
}

- (CGPoint)convertMapCoordinateToWorldCoordinate:(CGPoint)mapCoordinate
{
    return CGPointMake(mapCoordinate.x * self.tileSize, (self.tiles.gridSize.height - mapCoordinate.y) * self.tileSize);
}

@end
