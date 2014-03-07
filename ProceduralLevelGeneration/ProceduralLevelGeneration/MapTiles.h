//
//  MapTiles.h
//  ProceduralLevelGeneration
//
//  Created by Scott Gardner on 3/7/14.
//  Copyright (c) 2014 Kim Pedersen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MapTileType)
{
    MapTileTypeInvalid = -1,
    MapTileTypeNone,
    MapTileTypeFloor,
    MapTileTypeWall
};

@interface MapTiles : NSObject

@property (assign, nonatomic, readonly) NSUInteger count;
@property (assign, nonatomic, readonly) CGSize gridSize;

- (instancetype)initWithGridSize:(CGSize)size;
- (MapTileType)tileTypeAt:(CGPoint)tileCoordinate;
- (void)setTileType:(MapTileType)type at:(CGPoint)tileCoordinate;
- (BOOL)isEdgeTileAt:(CGPoint)tileCoordinate;
- (BOOL)isValidTileCoordinateAt:(CGPoint)tileCoordinate;

@end
